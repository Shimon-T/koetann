//
//  HomeCardListView.swift
//  koetann
//
//  Created by 田中志門 on 2/1/26.
//

import SwiftUI

struct HomeCardListView: View {
    let filteredWordBooks: [WordBook]
    let start: (WordBook) -> Void
    let edit: (WordBook) -> Void
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(filteredWordBooks.enumerated()), id: \.offset) { _, book in
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(book.title)
                                .font(.headline)
                            Text("\(book.subject.displayName) ・ \(book.createdAt, style: .date)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button(action: { start(book) }) {
                            Image(systemName: "play.fill")
                                .foregroundStyle(.white)
                                .padding(10)
                                .background(Capsule().fill(Color.accentColor))
                        }
                        .accessibilityLabel("Start \(book.title)")
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color(.secondarySystemBackground))
                    )
                    .onTapGesture { edit(book) }
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
