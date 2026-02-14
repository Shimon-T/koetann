//
//  Card.swift
//  koetann
//
//  Created by 田中志門 on 2/1/26.
//

import Foundation

struct Card: Identifiable, Codable {
    let id: UUID
    var question: String
    var answers: [String]
    var memo: String?
    
    init(id: UUID = UUID(), question: String, answers: [String], memo: String) {
        self.id = id
        self.question = question
        self.answers = answers
        self.memo = memo
    }
}
