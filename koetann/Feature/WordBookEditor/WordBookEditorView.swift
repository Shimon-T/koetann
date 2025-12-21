//
//  WordBookEditor.swift
//  koetann
//
//  Created by 田中志門 on 2/8/26.
//

import SwiftUI

// 作成ステップ管理
enum EditorStep {
    case words
    case metadata
}

struct WordBookEditorView: View {
    @Environment(\.dismiss) private var dismiss

    // MARK: - Step
    @State private var step: EditorStep = .words

    // MARK: - Word inputs
    @State private var words: [(question: String, answer: String)] = [
        ("", "")
    ]

    // MARK: - Metadata
    @State private var title: String = ""
    @State private var subject: Subject? = nil

    // MARK: - Alert
    @State private var showCancelAlert = false

    // MARK: - Callback
    let onSave: (WordBook) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                content
                bottomButton
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        handleCancel()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .alert("作成をキャンセルしますか？", isPresented: $showCancelAlert) {
                Button("キャンセル", role: .destructive) {
                    dismiss()
                }
                Button("続ける", role: .cancel) {}
            } message: {
                Text("入力した内容は保存されません。")
            }
        }
    }
}
