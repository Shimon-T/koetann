//
//  WordBook.swift
//  koetann
//
//  Created by 田中志門 on 2/1/26.
//

import Foundation

struct WordBook: Codable, Identifiable {
      var id: UUID
      var title: String
      var subject: Subject
      var createdAt: Date
      var cards: [Card]

      init(id: UUID = UUID(), title: String, subject: Subject, createdAt: Date, cards: [Card]) {
          self.id = id
          self.title = title
          self.subject = subject
          self.createdAt = createdAt
          self.cards = cards
      }
  }
