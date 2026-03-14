//  HomeView.swift
//  koetann
//
//  Created by 田中志門 on 12/21/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \WordBook.createdAt, order: .reverse) private var allWordBooks: [WordBook]
    @Environment(\.modelContext) private var modelContext
    
    @ObservedObject private var viewModel = HomeViewModel()
    
    @State private var showingEditor = false
    @State private var showModeSelection = false
    @State private var targetBook: WordBook? = nil
    
    var filteredWordBooks: [WordBook] {
        guard let subject = viewModel.selectedSubject else { return allWordBooks }
        return allWordBooks.filter { $0.subject == subject }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // 上部のヒーローセクション
                ZStack(alignment: .leading) {
                    LinearGradient(
                        colors: [viewModel.currentThemeColor.opacity(0.3), viewModel.currentThemeColor.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    
                    Text("声で学ぶ 単語帳")
                        .font(.title2.bold())
                        .padding()
                }
                .padding(.horizontal)
                
                HomeScrollView(
                    subjectOptions: viewModel.subjectOptions,
                    selectedSubject: viewModel.selectedSubject,
                    start: { subject in
                        viewModel.select(subject: subject)
                    }
                )
                
                HomeCardListView(
                    filteredWordBooks: filteredWordBooks,
                    viewModel: viewModel,
                    start: { book in
                        targetBook = book
                        showModeSelection = true
                    },
                    edit: { book in
                        viewModel.edit(book: book)
                        showingEditor = true
                    }
                )
            }
            .padding(.top, 30)
            .overlay(alignment: .bottomTrailing) {
                Button {
                    viewModel.editingBook = nil
                    showingEditor = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding()
                        .background(Circle().fill(viewModel.currentThemeColor))
                        .shadow(radius: 4)
                }
                .padding()
            }
            .sheet(isPresented: $showingEditor, onDismiss: {
                viewModel.editingBook = nil
            }) {
                WordBookEditorView(editingBook: viewModel.editingBook) { newOrUpdatedBook in
                    if viewModel.editingBook != nil {
                        viewModel.update(book: newOrUpdatedBook, context: modelContext)
                    } else {
                        modelContext.insert(newOrUpdatedBook)
                    }
                    try? modelContext.save()
                    showingEditor = false
                }
            }
            .confirmationDialog("学習モードを選択", isPresented: $showModeSelection, titleVisibility: .visible) {
                Button("音声モード") {
                    if let book = targetBook { viewModel.start(book: book, mode: .speech) }
                }
                Button("入力モード") {
                    if let book = targetBook { viewModel.start(book: book, mode: .input) }
                }
                Button("学習モード（カード）") {
                    if let book = targetBook { viewModel.start(book: book, mode: .flashcard) }
                }
                Button("キャンセル", role: .cancel) { }
            }
            // 学習画面の表示ロジックを最新データに対応

            // koetann/Feature/Home/HomeView.swift

            .fullScreenCover(item: $viewModel.studyingBook) { book in
                // Queryから常に最新のインスタンスを引き直す
                let latestBook = allWordBooks.first(where: { $0.id == book.id }) ?? book
                let mode = viewModel.selectedMode ?? .flashcard
                let studyVM = StudyViewModel(wordBook: latestBook, mode: mode)
                
                Group {
                    if mode == .speech {
                        SpeechStudyView(viewModel: studyVM)
                    } else if mode == .flashcard {
                        FlashcardStudyView(viewModel: studyVM)
                    } else {
                        InputStudyView(viewModel: studyVM)
                    }
                }
                // ここが重要！ IDが変わる（またはタイトルの更新など）とViewを強制リフレッシュする
                .id("\(latestBook.id)-\(latestBook.title)-\(latestBook.cards.count)")
            }
        }
    }
}
