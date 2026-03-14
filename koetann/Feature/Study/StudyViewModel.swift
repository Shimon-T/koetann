//  StudyViewModel.swift
import Foundation
import SwiftUI
import Combine

final class StudyViewModel: ObservableObject {
    // @Published を付けて、データの変更を View に通知できるようにする
    @Published var wordBook: WordBook
    let mode: StudyMode
    
    @Published var currentIndex = 0
    @Published var inputText = ""
    @Published var isCorrect: Bool? = nil
    @Published var isFinished = false
    @Published var memorizedCards: [Card] = []
    @Published var wrongCards: [Card] = []
    @Published var memorizedCount = 0
    @Published var notMemorizedCount = 0
    
    init(wordBook: WordBook, mode: StudyMode) {
        self.wordBook = wordBook
        self.mode = mode
    }
    
    // 計算プロパティにして、常に最新の cards 配列を返すようにする
    var cards: [Card] {
        wordBook.cards
    }
    
    func refresh(){
        objectWillChange.send()
    }
    
    var currentCard: Card? {
        guard currentIndex < cards.count else { return nil }
        return cards[currentIndex]
    }
    
    var progress: Double {
        guard !cards.isEmpty else { return 0 }
        return Double(currentIndex) / Double(cards.count)
    }
  
    
    // 入力モードの判定
    func checkAnswer() {
        guard let card = currentCard else { return }
        let cleanedInput = inputText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        if card.answers.map({ $0.lowercased() }).contains(cleanedInput) {
            isCorrect = true
            memorizedCount += 1
            memorizedCards.append(card)
        } else {
            isCorrect = false
            notMemorizedCount += 1
            wrongCards.append(card)
        }
    }
    
    func refreshFromWordBook() {
            objectWillChange.send()
    }
    
    var currentCorrectAnswers: String {
            currentCard?.answers.joined(separator: ", ") ?? ""
    }
    
    func skipAnswer() {
        if let card = currentCard {
            wrongCards.append(card)
        }
        isCorrect = false
        notMemorizedCount += 1
        nextCard()
    }
    
    func swipeCard(isMemorized: Bool) {
        guard let card = currentCard else { return }
        if isMemorized {
            memorizedCards.append(card)
            memorizedCount += 1
        } else {
            wrongCards.append(card)
            notMemorizedCount += 1
        }
        nextCard()
    }
    
    // 次のカードへ
    func nextCard() {
        if currentIndex < cards.count - 1 {
            currentIndex += 1
            inputText = ""
            isCorrect = nil
        } else {
            isFinished = true
        }
    }
}
