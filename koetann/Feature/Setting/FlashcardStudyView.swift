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
                ForEach(Array(viewModel.wordBook.cards.enumerated()).reversed(), id: \.element.id) { index, card in
                    if index >= viewModel.currentIndex {
                        CardView(card: card) { isMemorized in
                            withAnimation(.spring()) {
                                viewModel.swipeCard(isMemorized: isMemorized)
                            }
                        }
                        .stacked(at: index, in: viewModel.wordBook.cards.count)
                    }
                }
            }
            .navigationTitle(viewModel.wordBook.title)
            .onChange(of: viewModel.isFinished) { _ in dismiss() }
        }
    }
}

// 縦長カードのコンポーネント
struct CardView: View {
    let card: Card
    var onSwipe: (Bool) -> Void
    
    @State private var isFlipped = false
    @State private var offset = CGSize.zero

    var body: some View {
        ZStack {
            // 裏面（答え）
            CardContent(text: card.answers.joined(separator: ", "), color: .green)
                .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
                .opacity(isFlipped ? 1 : 0)

            // 表面（問題）
            CardContent(text: card.question, color: .white)
                .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                .opacity(isFlipped ? 0 : 1)
        }
        .frame(width: 300, height: 500)
        .offset(x: offset.width, y: offset.height * 0.4)
        .rotationEffect(.degrees(Double(offset.width / 20)))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded { _ in
                    if offset.width > 100 {
                        onSwipe(true) // 右：覚えた
                    } else if offset.width < -100 {
                        onSwipe(false) // 左：覚えてない
                    } else {
                        offset = .zero // 戻る
                    }
                }
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isFlipped.toggle()
            }
        }
    }
}

struct CardContent: View {
    let text: String
    let color: Color
    var body: some View {
        Text(text)
            .font(.largeTitle.bold())
            .frame(width: 300, height: 500)
            .background(RoundedRectangle(cornerRadius: 25).fill(color).shadow(radius: 10))
            .multilineTextAlignment(.center)
            .padding()
    }
}

extension View {
    func stacked(at index: Int, in total: Int) -> some View {
        let offset = Double(total - index)
        return self.offset(x: 0, y: offset * 10)
    }
}
