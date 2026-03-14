import SwiftUI
import AVFoundation
import Speech

struct SpeechStudyView: View {
    @StateObject var viewModel: StudyViewModel
    @StateObject private var speech = SpeechManager()
    @Environment(\.dismiss) private var dismiss

    @State private var bgFlash: Color = .clear
    @State private var isProcessing: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background flash for feedback
                bgFlash
                    .ignoresSafeArea()
                    .animation(.easeOut(duration: 0.35), value: bgFlash)

                if viewModel.isFinished {
                    StudyResultView(viewModel: viewModel)
                } else {
                    VStack(spacing: 24) {
                        ProgressView(value: viewModel.progress)
                            .tint(viewModel.wordBook.subject.themeColor)
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                            .padding(.horizontal)
                            .padding(.top, 24)

                        if let card = viewModel.currentCard {
                            VStack(spacing: 12) {
                                Text("問題")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(card.question)
                                    .font(.system(size: 36, weight: .bold))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .padding(.top, 24)
                        }

                        Spacer()

                        // Pulsing microphone during listening
                        MicView(isListening: speech.isListening, color: viewModel.wordBook.subject.themeColor)
                            .frame(width: 140, height: 140)
                            .padding(.bottom, 40)

                        // Last transcription (for debugging/visibility)
                        if !speech.lastTranscription.isEmpty {
                            Text(speech.lastTranscription)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.bottom, 8)
                        }
                    }
                }
            }
            .navigationTitle(viewModel.wordBook.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("終了") { dismiss() }
                }
            }
            .task { await startIfNeeded() }
        }
    }

    // MARK: - Flow control
    /// Starts the speech learning loop if not already running.
    private func startIfNeeded() async {
        guard !isProcessing else { return }
        isProcessing = true
        do {
            try await speech.requestPermissions()
            await runLoop()
        } catch {
            // If permissions fail, just stop processing.
            isProcessing = false
        }
    }

    /// Runs the automatic loop of: speak question -> listen -> transcribe -> judge -> feedback -> next card.
    private func runLoop() async {
        while !viewModel.isFinished {
            guard let card = viewModel.currentCard else { break }

            // 1) Speak question aloud
            await speak(card.question)

            // 2) Start listening for user answer
            do { try speech.startListening() } catch { break }

            // Wait until listening stops (final transcription ready)
            while speech.isListening { try? await Task.sleep(nanoseconds: 100_000_000) }

            let transcript = speech.lastTranscription

            // 3) Judge the user response against correct answers
            let correct = speech.isMatch(transcription: transcript, answers: card.answers)

            // 4) Show feedback flash for correctness
            await showFeedback(correct: correct)

            // 5) Update memorized/wrong cards and proceed to next card
            if correct {
                viewModel.memorizedCards.append(card)
            } else {
                viewModel.wrongCards.append(card)
            }
            viewModel.nextCard()

            // Short pause before next iteration
            try? await Task.sleep(nanoseconds: 250_000_000)
        }
        isProcessing = false
    }

    /// Speaks the given text and waits for speech completion.
    private func speak(_ text: String) async {
        await withCheckedContinuation { cont in
            speech.speak(text)
            Task {
                while speech.isSpeaking { try? await Task.sleep(nanoseconds: 50_000_000) }
                cont.resume()
            }
        }
    }

    /// Shows a background color flash as feedback for correctness.
    private func showFeedback(correct: Bool) async {
        await MainActor.run {
            bgFlash = correct ? .green.opacity(0.35) : .red.opacity(0.35)
        }
        try? await Task.sleep(nanoseconds: 400_000_000)
        await MainActor.run {
            bgFlash = .clear
        }
    }
}

// MARK: - MicView with pulsing animation and color feedback
private struct MicView: View {
    let isListening: Bool
    let color: Color

    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.15))
                .scaleEffect(scale)
                .animation(isListening ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true) : .default, value: scale)
            Circle()
                .fill(color)
            Image(systemName: "mic.fill")
                .font(.system(size: 56, weight: .bold))
                .foregroundColor(.white)
        }
        .onAppear { scale = 1.0 }
        .onChange(of: isListening) { _, newValue in
            if newValue {
                scale = 1.15
            } else {
                scale = 1.0
            }
        }
    }
}
