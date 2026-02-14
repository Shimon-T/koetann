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
            VStack(spacing: 30) {
                ProgressView(value: viewModel.progress)
                    .tint(viewModel.wordBook.subject.themeColor)
                    .padding()

                if let card = viewModel.currentCard {
                    Text(card.question)
                        .font(.system(size: 32, weight: .bold))
                        .padding()

                    TextField("答えを入力", text: $viewModel.inputText)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                        .onSubmit { viewModel.checkAnswer() }
                    
                    if let correct = viewModel.isCorrect {
                        Text(correct ? "正解！" : "惜しい！")
                            .font(.title.bold())
                            .foregroundColor(correct ? .green : .red)
                        
                        Text("正解: \(card.answers.joined(separator: ", "))")
                            .font(.subheadline)
                    }

                    Button(viewModel.isCorrect == nil ? "判定する" : "次へ") {
                        if viewModel.isCorrect == nil {
                            viewModel.checkAnswer()
                        } else {
                            viewModel.nextCard()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(viewModel.wordBook.subject.themeColor)
                }
            }
            .navigationTitle("入力モード")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: viewModel.isFinished) { _ in dismiss() }
        }
    }
}
