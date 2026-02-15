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
                    Color.clear // 背景確保

                    ForEach(Array(viewModel.wordBook.cards.enumerated()), id: \.element.id) { index, card in
                        if index >= viewModel.currentIndex {
                            CardView(card: card, themeColor: viewModel.wordBook.subject.themeColor) { isMemorized in
                                withAnimation(.spring()) {
                                    viewModel.swipeCard(isMemorized: isMemorized)
                                }
                            }
                            .zIndex(Double(viewModel.wordBook.cards.count - index))
                            .stacked(at: index, in: viewModel.wordBook.cards.count)
                            .allowsHitTesting(index == viewModel.currentIndex)
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
    let themeColor: Color
    var onSwipe: (Bool) -> Void
    
    @State private var isFlipped = false
    @State private var offset = CGSize.zero

    var body: some View {
        ZStack {
            if isFlipped {
                CardContent(text: card.answers.joined(separator: ", "),
                            backgroundColor: currentSwipeColor,
                            foregroundColor: offset.width == 0 ? themeColor : .white,
                            borderColor: themeColor)
            } else {
                CardContent(text: card.question,
                            backgroundColor: currentSwipeColor,
                            foregroundColor: offset.width == 0 ? themeColor : .white,
                            borderColor: themeColor)
            }
            
            if abs(offset.width) > 50 {
                Image(systemName: offset.width > 0 ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.white)
                    .opacity(min(Double(abs(offset.width) / 150), 0.8))
            }
        }
        .frame(width: 320, height: 500)
        .offset(x: offset.width, y: offset.height * 0.4)
        .rotationEffect(.degrees(Double(offset.width / 15)))
        .contentShape(RoundedRectangle(cornerRadius: 25))
        .gesture(
            DragGesture()
                .onChanged { offset = $0.translation }
                .onEnded { _ in
                    if offset.width > 120 {
                        completeSwipe(isMemorized: true)
                    } else if offset.width < -120 {
                        completeSwipe(isMemorized: false)
                    } else {
                        withAnimation(.spring()) { offset = .zero }
                    }
                }
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isFlipped.toggle()
            }
        }
    }

    // スワイプ中のカードの色を計算
    private var currentSwipeColor: Color {
        if offset.width > 0 {
            return Color.white.mix(with: .green, ratio: min(Double(offset.width / 150), 1.0))
        } else if offset.width < 0 {
            return Color.white.mix(with: .red, ratio: min(Double(-offset.width / 150), 1.0))
        }
        return .white
    }

    private func completeSwipe(isMemorized: Bool) {
        withAnimation(.easeOut(duration: 0.3)) {
            offset.width = isMemorized ? 1000 : -1000
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onSwipe(isMemorized)
        }
    }
}

// カードの見た目専用のView
struct CardContent: View {
    let text: String
    let backgroundColor: Color
    let foregroundColor: Color
    let borderColor: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: 32, weight: .bold))
            .foregroundColor(foregroundColor)
            .frame(width: 320, height: 500)
            .background(backgroundColor)
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(borderColor, lineWidth: 3)
            )
            .shadow(color: .black.opacity(0.15), radius: 10)
            .multilineTextAlignment(.center)
            .padding()
    }
}

//  FlashcardStudyView.swift の一番下

// MARK: - Extensions
extension View {
    func stacked(at index: Int, in total: Int) -> some View {
        let diff = Double(index)
        return self.offset(x: 0, y: diff * 4)
    }
}

extension Color {
    // iOS (UIColor) を使用して色を混ぜるメソッド
    func mix(with target: Color, ratio: Double) -> Color {
        let uiColor1 = UIColor(self)
        let uiColor2 = UIColor(target)
        
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        uiColor1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        uiColor2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return Color(
            red: Double(r1 * (1 - ratio) + r2 * ratio),
            green: Double(g1 * (1 - ratio) + g2 * ratio),
            blue: Double(b1 * (1 - ratio) + b2 * ratio),
            opacity: Double(a1 * (1 - ratio) + a2 * ratio)
        )
    }
    
    var asColor: Color {
        return self
    }
}
