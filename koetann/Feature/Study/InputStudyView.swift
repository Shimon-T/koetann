//
//  InputStudyView.swift
//  koetann
//
//  Created by 田中志門 on 2/15/26.
//

import SwiftUI

struct InputStudyView: View {
    @StateObject var viewModel: StudyViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 1. ゲージ（一番上）
                ProgressView(value: viewModel.progress)
                    .tint(viewModel.wordBook.subject.themeColor)
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding(.top, 20)
                    .padding(.horizontal)

                if let card = viewModel.currentCard {
                    VStack(spacing: 40) {
                        // 2. 問題（少し下）
                        VStack(spacing: 8) {
                            Text("問題")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(card.question)
                                .font(.system(size: 36, weight: .bold))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 40)

                        // 3. 大きなTextField
                        TextField("答えを入力", text: $viewModel.inputText)
                            .font(.title2)
                            .padding(20)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(viewModel.wordBook.subject.themeColor.opacity(0.5), lineWidth: 2))
                            .padding(.horizontal)
                            .onSubmit { viewModel.checkAnswer() }
                        
                        // 正誤表示
                        if let correct = viewModel.isCorrect {
                            HStack {
                                Image(systemName: correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                                Text(correct ? "正解！" : "ちがうよ")
                            }
                            .font(.title.bold())
                            .foregroundColor(correct ? .green : .red)
                        }

                        // 4. 大きなボタン類
                        VStack(spacing: 16) {
                            Button(action: {
                                if viewModel.isCorrect == nil {
                                    viewModel.checkAnswer()
                                } else {
                                    viewModel.nextCard()
                                }
                            }) {
                                Text(viewModel.isCorrect == nil ? "判定する" : "次へ進む")
                                    .font(.title3.bold())
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                    .background(viewModel.inputText.isEmpty ? Color.gray : viewModel.wordBook.subject.themeColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                            }
                            .disabled(viewModel.inputText.isEmpty)

                            Button("わからない") {
                                viewModel.skipAnswer()
                            }
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding()
                        }
                        .padding(.horizontal)
                    }
                }
                Spacer()
            }
            .navigationTitle("入力学習")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("終了") { dismiss() }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("終了") { dismiss() }
                }
            }
        }
    }
}
