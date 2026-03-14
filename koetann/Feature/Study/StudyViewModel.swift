//
//  StudyViewModel.swift
//  koetann
//
//  Created by 田中志門 on 2/15/26.
//

import Foundation
import SwiftUI
import Combine

final class StudyViewModel: ObservableObject {
    let wordBook: WordBook
    let mode: StudyMode
    
    @Published var currentIndex = 0
    @Published var inputText = ""
    @Published var isCorrect: Bool? = nil
    @Published var isFinished = false
    @Published var memorizedCards: [Card] = []
    @Published var wrongCards: [Card] = []
    @Published var memorizedCount = 0
    @Published var notMemorizedCount = 0
    
    // 現在のカードの正解（複数可）
    var currentCorrectAnswers: [String] {
        currentCard?.answers ?? []
    }
    
    // 判定済みかどうか（正誤が確定しているか）
    var hasJudged: Bool {
        isCorrect != nil
    }
    
    init(wordBook: WordBook, mode: StudyMode) {
        self.wordBook = wordBook
        self.mode = mode
    }
    
    var currentCard: Card? {
        guard currentIndex < wordBook.cards.count else { return nil }
        return wordBook.cards[currentIndex]
    }
    
    var progress: Double {
        guard !wordBook.cards.isEmpty else { return 0 }
        return Double(currentIndex) / Double(wordBook.cards.count)
    }
    
    // 入力モードの判定
    func checkAnswer() {
        guard let card = currentCard else { return }
        let cleanedInput = inputText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        if card.answers.map({ $0.lowercased() }).contains(cleanedInput) {
            isCorrect = true
            memorizedCount += 1
        } else {
            isCorrect = false
            notMemorizedCount += 1
        }
    }
    
    func skipAnswer() {
        isCorrect = false
        notMemorizedCount += 1
        // UI 側で正解を表示し、ユーザー操作で次へ進む
    }
    
    func swipeCard(isMemorized: Bool) {
        guard let card = currentCard else { return }
        if isMemorized {
            memorizedCards.append(card)
        } else {
            wrongCards.append(card)
        }
        nextCard()
    }
    
    // 次のカードへ
    func nextCard() {
        if currentIndex < wordBook.cards.count - 1 {
            currentIndex += 1
            inputText = ""
            isCorrect = nil
        } else {
            isFinished = true
        }
    }
    
    // 最新の WordBook 状態に合わせて進行状況を補正
    func refreshFromWordBook() {
        let count = wordBook.cards.count
        if count == 0 {
            currentIndex = 0
            isFinished = true
            inputText = ""
            isCorrect = nil
            return
        }
        if currentIndex >= count {
            currentIndex = max(0, count - 1)
            isFinished = false
        }
        // 進行中の判定状態は維持
    }
}
