//
//  QuestionCard.swift
//  TriviaGame
//
//  Created by Rezwan Mahmud on 10/29/25.
//

import SwiftUI

struct QuestionCard: View {

    let question: TriviaQuestion
    let selectedAnswer: String?
    let didSubmit: Bool
    let onSelectAnswer: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Metadata row (category + difficulty)
            VStack(alignment: .leading, spacing: 4) {
                Text(question.category)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)

                Text(question.difficulty.capitalized)
                    .font(.caption2)
                    .foregroundColor(.secondary.opacity(0.8))
            }

            // Question text
            Text(question.question.htmlStripped)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)

            // Answers
            VStack(spacing: 10) {
                ForEach(question.allAnswers, id: \.self) { answer in
                    AnswerRow(
                        text: answer.htmlStripped,
                        isCorrect: didSubmit && (answer == question.correct_answer),
                        isWrongChoice: didSubmit && (answer == selectedAnswer && answer != question.correct_answer),
                        isSelected: !didSubmit && (answer == selectedAnswer)
                    ) {
                        // This only runs on tap, not during render.
                        onSelectAnswer(answer)
                    }
                    .disabled(didSubmit)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(
                    color: .black.opacity(0.08),
                    radius: 6,
                    x: 0,
                    y: 4
                )
        )
    }
}

struct AnswerRow: View {
    let text: String
    let isCorrect: Bool
    let isWrongChoice: Bool
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(alignment: .top, spacing: 12) {
                // A little selection bullet / status marker
                Circle()
                    .strokeBorder(lineColor, lineWidth: 2)
                    .background(Circle().fill(fillCircle))
                    .frame(width: 20, height: 20)

                Text(text)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primary)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(backgroundColor)
            .cornerRadius(10)
        }
        .buttonStyle(.plain) // <-- prevent default link-style blue tint
    }

    // MARK: - Visual state helpers

    private var backgroundColor: Color {
        if isCorrect {
            // correct after submit
            return Color.green.opacity(0.25)
        }
        if isWrongChoice {
            // your picked answer but wrong
            return Color.red.opacity(0.25)
        }
        if isSelected {
            // current selection before submit
            return Color.blue.opacity(0.15)
        }
        // neutral
        return Color.gray.opacity(0.1)
    }

    private var lineColor: Color {
        if isCorrect { return .green }
        if isWrongChoice { return .red }
        if isSelected { return .blue }
        return .gray.opacity(0.6)
    }

    private var fillCircle: Color {
        if isCorrect { return .green.opacity(0.4) }
        if isWrongChoice { return .red.opacity(0.4) }
        if isSelected { return .blue.opacity(0.4) }
        return .clear
    }
}

#Preview {
    QuestionCard(
        question: TriviaQuestion(
            category: "Sports",
            type: "multiple",
            difficulty: "easy",
            question: "Which country won the 2018 FIFA World Cup?",
            correct_answer: "France",
            incorrect_answers: ["Brazil", "Germany", "Argentina"]
        ),
        selectedAnswer: "Brazil",
        didSubmit: true,
        onSelectAnswer: { _ in }
    )
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
