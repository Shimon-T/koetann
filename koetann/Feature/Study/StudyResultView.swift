//
//  StudyResultView.swift
//  koetann
//
//  Created by 田中志門 on 2/15/26.
//

import SwiftUI

struct StudyResultView: View {
    @ObservedObject var viewModel: StudyViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("学習完了！")
                .font(.largeTitle.bold())
                .padding(.top)
            
            // スコア表示
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 15)
                    .frame(width: 150, height: 150)
                
                VStack {
                    Text("\(viewModel.memorizedCards.count)")
                        .font(.system(size: 50, weight: .bold))
                    Text("/ \(viewModel.wordBook.cards.count)")
                        .foregroundColor(.secondary)
                }
            }
            
            // リスト表示
            List {
                if !viewModel.wrongCards.isEmpty {
                    Section(header: Text("復習が必要な単語").foregroundColor(.red)) {
                        ForEach(viewModel.wrongCards) { card in
                            HStack {
                                Text(card.question)
                                Spacer()
                                Text(card.answers.first ?? "").foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Section(header: Text("覚えた単語").foregroundColor(.green)) {
                    ForEach(viewModel.memorizedCards) { card in
                        Text(card.question)
                    }
                }
            }
            
            Button("ホームに戻る") {
                dismiss()
            }
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(viewModel.wordBook.subject.themeColor)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding()
        }
    }
}
