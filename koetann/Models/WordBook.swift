//
//  WordBook.swift
//  koetann
//
//  Created by 田中志門 on 2/1/26.
//

import Foundation
import SwiftData

@Model
final class WordBook {
    @Attribute(.unique) var id: UUID
    var title: String
    var subjectRawValue: String
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade)
    var cards: [Card]

    var subject: Subject {
        get { Subject(rawValue: subjectRawValue) ?? .other }
        set { subjectRawValue = newValue.rawValue }
    }

    init(id: UUID = UUID(), title: String, subject: Subject, createdAt: Date = Date(), cards: [Card] = []) {
        self.id = id
        self.title = title
        self.subjectRawValue = subject.rawValue
        self.createdAt = createdAt
        self.cards = cards
    }
}
