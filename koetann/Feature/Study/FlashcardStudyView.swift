//
//  FlashcardStudyView.swift
//  koetann
//
//  Created by 田中志門 on 2/15/26.
//

import SwiftUI

struct FlashcardStudyView: View {
    @StateObject var viewModel: StudyViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isFinished {
                    StudyResultView(viewModel: viewModel)
                } else {
                    ForEach(Array(viewModel.wordBook.cards.enumerated()).reversed(), id: \.element.id) { index, card in
                        if index >= viewModel.currentIndex {
                            CardView(card: card) { isMemorized in
                                viewModel.swipeCard(isMemorized: isMemorized)
                            }
                            .stacked(at: index, in: viewModel.wordBook.cards.count)
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
        }
    }
}

struct CardView: View {
    let card: Card
    var onSwipe: (Bool) -> Void
    @State private var isFlipped = false
    @State private var offset = CGSize.zero

    var body: some View {
        ZStack {
            // カード本体
            RoundedRectangle(cornerRadius: 25)
                .fill(cardBackgroundColor) // スワイプで色が変わる
                .shadow(color: .black.opacity(0.1), radius: 10)
                .overlay(
                    ZStack {
                        if isFlipped {
                            Text(card.answers.joined(separator: ", ")).foregroundColor(.white)
                        } else {
                            Text(card.question).foregroundColor(offset.width == 0 ? .black : .white)
                        }
                    }
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding()
                )
                // 記号のオーバーレイ
                .overlay(
                    Group {
                        if offset.width > 50 {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.white).font(.system(size: 80))
                                .opacity(Double(offset.width / 150))
                        } else if offset.width < -50 {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white).font(.system(size: 80))
                                .opacity(Double(-offset.width / 150))
                        }
                    }
                )
        }
        .frame(width: 320, height: 500)
        .offset(x: offset.width, y: offset.height * 0.4)
        .rotationEffect(.degrees(Double(offset.width / 20)))
        .gesture(
            DragGesture()
                .onChanged { offset = $0.translation }
                .onEnded { _ in
                    if offset.width > 120 {
                        onSwipe(true)
                    } else if offset.width < -120 {
                        onSwipe(false)
                    } else {
                        withAnimation(.spring()) { offset = .zero }
                    }
                }
        )
        .onTapGesture {
            withAnimation(.spring()) { isFlipped.toggle() }
        }
    }

    // スワイプ量に応じてカードの色を計算
    private var cardBackgroundColor: Color {
        if offset.width > 0 {
            return Color.white.opacity(1 - Double(offset.width/150))
                .overlay(Color.green.opacity(Double(offset.width/150)))
                .asColor
        } else if offset.width < 0 {
            return Color.white.opacity(1 - Double(-offset.width/150))
                .overlay(Color.red.opacity(Double(-offset.width/150)))
                .asColor
        }
        return .white
    }
}

// Color合成用のヘルパー
extension View {
    var asColor: Color { return self as? Color ?? .clear }
}

