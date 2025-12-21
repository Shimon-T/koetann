//
//  Home.swift
//  koetann
//
//  Created by 田中志門 on 12/21/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
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
                HomeScrollView(subjectOptions: viewModel.subjectOptions, selectedSubject: viewModel.selectedSubject, start: viewModel.select)
                
                // Books list
                HomeCardListView(filteredWordBooks: viewModel.filteredWordBooks, start: viewModel.start, edit: viewModel.edit)
                
            }
            .onAppear {
                print("HomeView appeared")
                print("subjectOptions:", viewModel.subjectOptions)
                print("selectedSubject:", String(describing: viewModel.selectedSubject))
                print("filteredWordBooks count:", viewModel.filteredWordBooks.count)
            }
            .navigationTitle("単語帳")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.addNewBook()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
