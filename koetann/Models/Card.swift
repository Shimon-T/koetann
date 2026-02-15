//
//  Card.swift
//  koetann
//
//  Created by 田中志門 on 2/1/26.
//

import Foundation
import SwiftData

@Model
final class Card {
    @Attribute(.unique) var id: UUID
    var question: String
    var answers: [String]
    var memo: String?
    
    var wordBook: WordBook?

    init(id: UUID = UUID(), question: String, answers: [String], memo: String? = nil) {
        self.id = id
        self.question = question
        self.answers = answers
        self.memo = memo
    }
}
