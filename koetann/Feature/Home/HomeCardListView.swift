//
//  HomeCardListView.swift
//  koetann
//
//  Created by 田中志門 on 2/1/26.
//


import SwiftUI
import SwiftData

struct HomeCardListView: View {
    let filteredWordBooks: [WordBook]
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.modelContext) private var modelContext
    
    // アクション用のクロージャ
    let start: (WordBook) -> Void
    let edit: (WordBook) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredWordBooks) { book in
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(book.title)
                                .font(.headline)
                            Text("\(book.subject.displayName) ・ \(book.createdAt, style: .date)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        // 再生ボタン
                        Button(action: { start(book) }) {
                            Image(systemName: "play.fill")
                                .foregroundStyle(.white)
                                .padding(10)
                                .background(Capsule().fill(book.subject.themeColor))
                        }
                        .accessibilityLabel("Start \(book.title)")
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color(.secondarySystemBackground))
                    )
                    // 長押しメニューの実装
                    .contextMenu {
                        Button {
                            edit(book)
                        } label: {
                            Label("編集", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            viewModel.delete(book: book, context: modelContext)
                        } label: {
                            Label("削除", systemImage: "trash")
                        }
                    }
                    // タップで編集画面へ
                    .onTapGesture {
                        edit(book)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, 4)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 16)
            }
        }
    }
}
