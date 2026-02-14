//
//  WordBookListViewModel.swift
//  koetann
//
//  Created by 田中志門 on 2/1/26.
//

import Foundation
import Combine
import SwiftUI
final class HomeViewModel: ObservableObject {
    @Published private(set) var allWordBooks: [WordBook]
    @Published var selectedSubject: Subject? = nil // nil = All

    var filteredWordBooks: [WordBook] {
        guard let subject = selectedSubject else { return allWordBooks }
        return allWordBooks.filter { $0.subject == subject }
    }

    var subjectOptions: [Subject?] {
        return [nil] + Subject.allCases.map { Optional($0) }
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
    
    func add(book: WordBook) {
        allWordBooks.insert(book, at: 0)
    }

    func addNewBook() {
        let new = WordBook(title: "New Book", subject: .other, createdAt: Date(), cards: [])
        allWordBooks.insert(new, at: 0)
    }

    func remove(at offsets: IndexSet) {
        allWordBooks.remove(atOffsets: offsets)
    }

    func start(book: WordBook) {
        // TODO: Wire up to the learning flow (voice recognition start)
        // This will likely navigate to a StudyView with the selected book.
        print("Start book: \(book.title)")
    }

    func edit(book: WordBook) {
        // TODO: Navigate to an edit screen for the selected book
        print("Edit book: \(book.title)")
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

