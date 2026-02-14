//  HomeView.swift
//  koetann
//
//  Created by 田中志門 on 12/21/25.
//

//  HomeView.swift
//  koetann
import SwiftUI

struct HomeView: View {
    @ObservedObject private var viewModel = HomeViewModel()
    @State private var showingEditor = false
    @State private var showModeSelection = false
    @State private var targetBook: WordBook? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Top hero section
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
                    filteredWordBooks: viewModel.filteredWordBooks,
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
                
                WordBookEditorView(onSave: { newOrUpdatedBook in
                    if viewModel.editingBook != nil {
                        viewModel.update(book: newOrUpdatedBook)
                    } else {
                        viewModel.add(book: newOrUpdatedBook)
                    }
                    showingEditor = false
                })
            }
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
    
#Preview {
    HomeView()
}
