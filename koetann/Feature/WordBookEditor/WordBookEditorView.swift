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
    @State private var showValidationAlert = false

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
            .alert("未入力の項目があります", isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("すべての問題と答えを入力してください。")
            }
        }
    }
}

extension WordBookEditorView {

    @ViewBuilder
    private var content: some View {
        switch step {
        case .words:
            wordInputSection
        case .metadata:
            metadataSection
        }
    }
}

extension WordBookEditorView {

    private var wordInputSection: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(words.indices, id: \.self) { index in
                    HStack(alignment: .center, spacing: 12) {

                        VStack(spacing: 0) {
                            TextField("問題（表）", text: $words[index].question)
                                .padding()

                            Divider()

                            TextField("答え（裏）", text: $words[index].answer)
                                .padding()
                                .background(Color.secondary.opacity(0.05))
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(lineWidth: 1)
                        )

                        Button(role: .destructive) {
                            words.remove(at: index)
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .padding(10)
                        }
                        .disabled(words.count <= 1)
                        .opacity(words.count <= 1 ? 0.4 : 1)
                    }
                }
                Button(action: {
                    words.append(("", ""))
                }) {
                    Image(systemName: "plus")
                        .font(.title3.weight(.bold))
                        .foregroundColor(.white)
                        .padding(14)
                        .background(Circle().fill(Color.accentColor))
                        .shadow(radius: 3)
                }
                .padding(.top, 8)
            }
            .padding()
        }
    }
}

extension WordBookEditorView {

    private var metadataSection: some View {
        Form {
            Section("タイトル") {
                TextField("単語帳のタイトル", text: $title)
            }

            Section("科目") {
                Picker("科目", selection: $subject) {
                    Text("未設定").tag(Subject?.none)
                    ForEach(Subject.allCases, id: \.self) {
                        Text($0.displayName).tag(Optional($0))
                    }
                }
            }
        }
    }
}

extension WordBookEditorView {

    private var bottomButton: some View {
        Button {
            handleBottomButton()
        } label: {
            Text(step == .words ? "次へ" : "作成する")
                .frame(maxWidth: .infinity)
                .padding()
                .font(.headline)
                .background(canProceed ? (subject?.themeColor ?? Color.accentColor) : Color.gray.opacity(0.3))
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .padding()
        .disabled(!canProceed)
    }

    private var canProceed: Bool {
        switch step {
        case .words:
            return !words.isEmpty && words.allSatisfy { !$0.question.isEmpty && !$0.answer.isEmpty }
        case .metadata:
            return !title.isEmpty
        }
    }
}

extension WordBookEditorView {

    private func handleBottomButton() {
        switch step {
        case .words:
            if !words.isEmpty && words.allSatisfy({ !$0.question.isEmpty && !$0.answer.isEmpty }) {
                step = .metadata
            } else {
                showValidationAlert = true
            }

        case .metadata:
            let cards: [Card] = words.map {
                Card(
                    question: $0.question,
                    answers: [$0.answer],
                    memo: ""
                )
            }

            let newBook = WordBook(
                title: title,
                subject: subject ?? .japanese,
                createdAt: Date(),
                cards: cards
            )

            onSave(newBook)
            dismiss()
        }
    }

    private func handleCancel() {
        let hasInput = words.contains {
            !$0.question.isEmpty || !$0.answer.isEmpty
        } || !title.isEmpty

        if hasInput {
            showCancelAlert = true
        } else {
            dismiss()
        }
    }
}

