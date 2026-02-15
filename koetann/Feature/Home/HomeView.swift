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
    
    // 選択された科目に基いてリストをフィルタリング
    var filteredWordBooks: [WordBook] {
        guard let subject = viewModel.selectedSubject else { return allWordBooks }
        return allWordBooks.filter { $0.subject == subject }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
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
                
                // 科目選択のスライダー
                HomeScrollView(
                    subjectOptions: viewModel.subjectOptions,
                    selectedSubject: viewModel.selectedSubject,
                    start: { subject in
                        viewModel.select(subject: subject)
                    }
                )
                
                // 単語帳の一覧リスト
                HomeCardListView(
                    filteredWordBooks: filteredWordBooks,
                    viewModel: viewModel,
                    start: { book in
                        targetBook = book
                        showModeSelection = true
                    },
                    edit: { book in
                        // カードをタップした際に編集画面を開く
                        viewModel.edit(book: book)
                        showingEditor = true
                    }
                )
            }
            .padding(.top, 30)
            .overlay(alignment: .bottomTrailing) {
                // 新規作成ボタン
                Button {
                    viewModel.editingBook = nil // 編集状態をクリア
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
            // 単語帳作成・編集画面の表示
            .sheet(isPresented: $showingEditor, onDismiss: {
                viewModel.editingBook = nil
            }) {
                WordBookEditorView(editingBook: viewModel.editingBook) { newOrUpdatedBook in
                    if viewModel.editingBook != nil {
                        // 修正箇所：modelContext を引数に渡す
                        viewModel.update(book: newOrUpdatedBook, context: modelContext)
                    } else {
                        modelContext.insert(newOrUpdatedBook)
                    }
                    try? modelContext.save()
                    showingEditor = false
                }
            }
            // 学習モードの選択ダイアログ
            .confirmationDialog("学習モードを選択", isPresented: $showModeSelection, titleVisibility: .visible) {
                Button("音声モード（準備中）") { }
                Button("入力モード") {
                    if let book = targetBook { viewModel.start(book: book, mode: .input) }
                }
                Button("学習モード（カード）") {
                    if let book = targetBook { viewModel.start(book: book, mode: .flashcard) }
                }
                Button("キャンセル", role: .cancel) { }
            }
            // 学習画面のフルスクリーン表示
            .fullScreenCover(item: $viewModel.studyingBook) { book in
                let mode = viewModel.selectedMode ?? .flashcard
                let studyVM = StudyViewModel(wordBook: book, mode: mode)
                
                if mode == .flashcard {
                    FlashcardStudyView(viewModel: studyVM)
                } else {
                    InputStudyView(viewModel: studyVM)
                }
            }
        }
    }
}
