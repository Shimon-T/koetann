//
//  StudyView.swift
//  koetann
//
//  Created by 田中志門 on 2/14/26.
//

import SwiftUI

struct StudyView: View {
    let wordBook: WordBook
    @Environment(\.dismiss) private var dismiss
    
    // 現在何問目か
    @State private var currentIndex = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                // プログレスバー
                ProgressView(value: Double(currentIndex + 1), total: Double(wordBook.cards.count))
                    .padding()

                if !wordBook.cards.isEmpty {
                    let card = wordBook.cards[currentIndex]
                    
                    VStack(spacing: 20) {
                        Text("問題")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text(card.question)
                            .font(.system(size: 40, weight: .bold))
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    Spacer()
                    
                    // 音声認識の代わりに、今はタップで次へ進めるようにします
                    Button {
                        if currentIndex < wordBook.cards.count - 1 {
                            currentIndex += 1
                        } else {
                            dismiss() // 最後まで行ったら閉じる
                        }
                    } label: {
                        VStack(spacing: 12) {
                            Image(systemName: "mic.circle.fill")
                                .font(.system(size: 80))
                            Text("答える（タップで次へ）")
                                .font(.headline)
                        }
                        .foregroundStyle(wordBook.subject.themeColor)
                    }
                }
                
                Spacer()
            }
            .navigationTitle(wordBook.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("終了") { dismiss() }
                }
            }
        }
    }
}
