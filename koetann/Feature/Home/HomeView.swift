//
//  Home.swift
//  koetann
//
//  Created by 田中志門 on 12/21/25.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var viewModel = HomeViewModel()
    @State private var showingEditor = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Top hero section (placeholder)
                ZStack(alignment: .leading) {
                    LinearGradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    Text("声で学ぶ 単語帳")
                        .font(.title2.bold())
                        .padding()
                }
                .padding(.horizontal)
                
                // Category buttons
                HomeScrollView(
                    subjectOptions: viewModel.subjectOptions,
                    selectedSubject: viewModel.selectedSubject,
                    start: { subject in
                        viewModel.select(subject: subject)
                    }
                )
                
                // Books list
                HomeCardListView(
                    filteredWordBooks: viewModel.filteredWordBooks,
                    start: { book in
                        viewModel.start(book: book)
                    },
                    edit: { book in
                        viewModel.edit(book: book)
                    }
                )
                
            }
            .onAppear {
                print("HomeView appeared")
                print("subjectOptions:", viewModel.subjectOptions)
                print("selectedSubject:", String(describing: viewModel.selectedSubject))
                print("filteredWordBooks count:", viewModel.filteredWordBooks.count)
            }
            .padding(.top, 30)
            .overlay(alignment: .bottomTrailing) {
                // Floating Add (+) Button
                Button {
                    showingEditor = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding()
                        .background(Circle().fill(Color.accentColor))
                        .shadow(radius: 4)
                }
                .padding()
            }
            .sheet(isPresented: $showingEditor) {
                WordBookEditorView(onSave: { newBook in
                    viewModel.add(book: newBook)
                    showingEditor = false
                })
            }
        }
    }
}
    
//#Preview {
//    HomeView()
//}
