//
//  WordBookListViewModel.swift
//  koetann
//
//  Created by 田中志門 on 2/1/26.
//

import Foundation
import Combine
import SwiftUI
import SwiftData

enum StudyMode {
    case speech, input, flashcard
}

final class HomeViewModel: ObservableObject {
    @Published private(set) var allWordBooks: [WordBook]
    @Published var selectedSubject: Subject? = nil
    @Published var studyingBook: WordBook? = nil
    @Published var selectedMode: StudyMode? = nil
    @Published var editingBook: WordBook? = nil
    
    var filteredWordBooks: [WordBook] {
        guard let subject = selectedSubject else { return allWordBooks }
        return allWordBooks.filter { $0.subject == subject }
    }
    
    var subjectOptions: [Subject?] {
        return [nil] + Subject.allCases.map { Optional($0) }
    }
    
    var currentThemeColor: Color {
        selectedSubject?.themeColor ?? .orange
    }
    
    func select(subject: Subject?) {
        selectedSubject = subject
    }
    
    init(wordBooks: [WordBook] = []) {
        if wordBooks.isEmpty {
            self.allWordBooks = Self.mock()
        } else {
            self.allWordBooks = wordBooks
        }
    }
    
    func add(book: WordBook, context: ModelContext) {
        context.insert(book)
        try? context.save()
    }
    
    func addNewBook() {
        let new = WordBook(title: "New Book", subject: .other, createdAt: Date(), cards: [])
        allWordBooks.insert(new, at: 0)
    }
    
    func remove(book: WordBook, context: ModelContext) {
        context.delete(book)
        try? context.save()
    }
    
    func start(book: WordBook, mode: StudyMode) {
        self.selectedMode = mode
        self.studyingBook = book
    }
    
    func edit(book: WordBook) {
        self.editingBook = book
    }
    
    func update(book: WordBook, context: ModelContext) {
        try? context.save()
        self.editingBook = nil
    }
    
    func delete(book: WordBook, context: ModelContext) {
        context.delete(book)
        do {
            try context.save()
        } catch {
            print("削除に失敗しました: \(error)")
        }
    }
    
}

private extension HomeViewModel {
    static func mock() -> [WordBook] {
        let cards1 = [
            Card(question: "Capital of France?", answers: ["Paris"], memo: ""),
            Card(question: "2+2?", answers: ["4", "four"], memo: "")
        ]
        let cards2 = [
            Card(question: "iPhoneのOS?", answers: ["iOS"], memo: "")
        ]
        return [
            WordBook(title: "世界の基礎", subject: .social, createdAt: Date().addingTimeInterval(-3600*24*2), cards: cards1),
            WordBook(title: "テクノロジー基礎", subject: .other, createdAt: Date().addingTimeInterval(-3600*24*5), cards: cards2),
            WordBook(title: "英単語 初級", subject: .english, createdAt: Date(), cards: [])
        ]
    }
}

