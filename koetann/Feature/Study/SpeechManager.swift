import Foundation
import AVFoundation
import Speech
import Combine

/// Manages Text-to-Speech (TTS) and Speech-to-Text (STT) for the study flow.
final class SpeechManager: NSObject, ObservableObject {
    // MARK: - Public published states
    @Published var isSpeaking: Bool = false
    @Published var isListening: Bool = false
    @Published var lastTranscription: String = ""
    
    // MARK: - Private properties
    private let audioEngine = AVAudioEngine()
    private var speechRecognizer: SFSpeechRecognizer?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let synthesizer = AVSpeechSynthesizer()
    
    // Configure for specific locale if needed (nil uses system default)
    init(localeIdentifier: String? = nil) {
        if let id = localeIdentifier {
            self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: id))
        } else {
            self.speechRecognizer = SFSpeechRecognizer()
        }
        super.init()
        synthesizer.delegate = self
    }
    
    // MARK: - Permissions
    /// Request both microphone and speech recognition permissions.
    func requestPermissions() async throws {
        let micGranted = await requestMicPermission()
        guard micGranted else { throw NSError(domain: "SpeechManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Microphone permission denied"]) }
        let speechAuth = await requestSpeechAuthorization()
        guard speechAuth == .authorized else { throw NSError(domain: "SpeechManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Speech recognition not authorized"]) }
    }

    private func requestMicPermission() async -> Bool {
        await withCheckedContinuation { cont in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                cont.resume(returning: granted)
            }
        }
    }
    
    private func requestSpeechAuthorization() async -> SFSpeechRecognizerAuthorizationStatus {
        await withCheckedContinuation { cont in
            SFSpeechRecognizer.requestAuthorization { status in
                cont.resume(returning: status)
            }
        }
    }
    
    // MARK: - TTS
    /// Speak the given text out loud.
    func speak(_ text: String, language: String? = nil, rate: Float = AVSpeechUtteranceDefaultSpeechRate) {
        let utterance = AVSpeechUtterance(string: text)
        if let lang = language { utterance.voice = AVSpeechSynthesisVoice(language: lang) }
        utterance.rate = rate
        isSpeaking = true
        synthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }
    
    // MARK: - STT
    /// Begin streaming recognition.
    func startListening() throws {
        guard !audioEngine.isRunning else { return }
        lastTranscription = ""
        try configureAudioSession()
        try startAudioEngine()
        startRecognitionTask()
        isListening = true
    }
    
    func stopListening() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        request?.endAudio()
        recognitionTask?.cancel()
        isListening = false
    }
    
    private func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .spokenAudio, options: [.duckOthers, .defaultToSpeaker, .allowBluetooth])
        try session.setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    private func startAudioEngine() throws {
        request = SFSpeechAudioBufferRecognitionRequest()
        guard let request = request else { throw NSError(domain: "SpeechManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to create request"]) }
        request.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.request?.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    private func startRecognitionTask() {
        guard let recognizer = speechRecognizer, recognizer.isAvailable else { return }
        guard let request = request else { return }
        
        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self = self else { return }
            if let result = result {
                self.lastTranscription = result.bestTranscription.formattedString
                // Stop automatically when result is final
                if result.isFinal {
                    self.stopListening()
                }
            }
            if error != nil {
                self.stopListening()
            }
        }
    }
    
    // MARK: - Utils
    /// Case-insensitive comparison between user transcription and any of the answers.
    func isMatch(transcription: String, answers: [String]) -> Bool {
        let normalized = transcription.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return answers.map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }.contains(normalized)
    }
}

extension SpeechManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { self.isSpeaking = false }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { self.isSpeaking = false }
    }
}
