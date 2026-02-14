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
    
    // 現在のカードのインデックス
    @Published var currentIndex = 0
    // 入力モード用の回答テキスト
    @Published var inputText = ""
    // 正誤判定後の状態
    @Published var isCorrect: Bool? = nil
    // 学習完了フラグ
    @Published var isFinished = false
    
    // 統計（何枚覚えたかなど）
    @Published var memorizedCount = 0
    @Published var notMemorizedCount = 0

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
        // 答えの配列のいずれかと一致すれば正解
        let cleanedInput = inputText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if card.answers.map({ $0.lowercased() }).contains(cleanedInput) {
            isCorrect = true
            memorizedCount += 1
        } else {
            isCorrect = false
            notMemorizedCount += 1
        }
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
    
    // スワイプ判定（学習モード用）
    func swipeCard(isMemorized: Bool) {
        if isMemorized {
            memorizedCount += 1
        } else {
            notMemorizedCount += 1
        }
        nextCard()
    }
}
