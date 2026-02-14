//
//  StudyResultView.swift
//  koetann
//
//  Created by 田中志門 on 2/15/26.
//

//  StudyResultView.swift
import SwiftUI

struct StudyResultView: View {
    @ObservedObject var viewModel: StudyViewModel
    @Environment(\.dismiss) private var dismiss
    
    // 正答率の計算（0.0 〜 1.0）
    private var successRate: Double {
        guard !viewModel.wordBook.cards.isEmpty else { return 0 }
        return Double(viewModel.memorizedCards.count) / Double(viewModel.wordBook.cards.count)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("学習完了！")
                .font(.largeTitle.bold())
                .padding(.top)
            
            // スコア表示（円グラフ）
            ZStack {
                // 背景のグレーの円
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 15)
                    .frame(width: 160, height: 160)
                
                // 正解率を表す青い円（ProgressViewのスタイルを利用）
                Circle()
                    .trim(from: 0, to: successRate) // ここで正答率とマッチさせます
                    .stroke(
                        viewModel.wordBook.subject.themeColor,
                        style: StrokeStyle(lineWidth: 15, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90)) // 真上から始まるように回転
                    .animation(.easeOut(duration: 1.0), value: successRate) // アニメーション追加
                
                VStack {
                    Text("\(viewModel.memorizedCards.count)")
                        .font(.system(size: 50, weight: .bold))
                    Text("/ \(viewModel.wordBook.cards.count)")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 20)
            
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
