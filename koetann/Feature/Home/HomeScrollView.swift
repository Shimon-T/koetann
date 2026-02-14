//
//  HomeScrollView.swift
//  koetann
//
//  Created by 田中志門 on 2/1/26.
//

import SwiftUI

struct HomeScrollView: View {
    let subjectOptions: [Subject?]
    let selectedSubject: Subject?
    let start: (Subject?) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(subjectOptions, id: \.self) { subject in
                    Button {
                        start(subject)
                    } label: {
                        Text(subject?.displayName ?? "All")
                            .font(.subheadline.weight(.semibold))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(
                                        subject == selectedSubject
                                        ? Color.accentColor.opacity(0.2)
                                        : Color.secondary.opacity(0.1)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }
}
