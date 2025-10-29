//
//  TriviaGameView.swift
//  TriviaGame
//
//  Created by Rezwan Mahmud on 10/29/25.
//

import SwiftUI

struct TriviaGameView: View {

    let numberOfQuestions: Int
    let categoryId: Int
    let difficulty: String
    let type: String
    let timeLimit: Int

    @StateObject private var viewModel = TriviaViewModel()

    @State private var showScoreAlert = false
    @State private var localLoaded = false    // make sure we only load once
    @State private var timerStarted = false   // make sure we only start timer once

    var body: some View {
        VStack {

            // Countdown label
            Text("Time remaining: \(viewModel.timeRemaining)s")
                .font(.headline)
                .padding(.top, 12)

            Group {
                if viewModel.questions.isEmpty && !viewModel.didSubmit {
                    // Loading state
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Loading questions...")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                } else {
                    // Questions list
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            ForEach(viewModel.questions) { question in
                                QuestionCard(
                                    question: question,
                                    selectedAnswer: viewModel.selectedAnswers[question.id],
                                    didSubmit: viewModel.didSubmit
                                ) { picked in
                                    viewModel.chooseAnswer(for: question, answer: picked)
                                    print("👉 Selected '\(picked)' for '\(question.question)'")
                                }
                            }
                        }
                        .padding()
                    }
                }
            }

            // Submit button
            Button {
                handleManualSubmit()
            } label: {
                Text("Submit")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.green)
                    )
                    .padding(.horizontal)
            }
            .padding(.bottom, 16)
        }
        .navigationBarTitleDisplayMode(.inline)

        // 1. Load trivia ONCE, staged. Do not mutate @Published inside this task.
        .task {
            guard !localLoaded else { return }

            let result = await viewModel.loadQuestions(
                amount: numberOfQuestions,
                category: categoryId,
                difficulty: difficulty,
                type: type,
                timeLimit: timeLimit
            )

            guard let result else {
                localLoaded = true
                return
            }

            // 2. Defer applying the loaded data into the @Published props.
            //    We also start the timer (once) AFTER applying game state.
            DispatchQueue.main.async {
                viewModel.applyLoadedGame(
                    questions: result.questions,
                    timeLimit: result.timeLimit
                )

                localLoaded = true

                if !timerStarted {
                    timerStarted = true

                    // Start ticking. When time ends, we auto submit safely.
                    viewModel.startTimer {
                        handleTimeExpired()
                    }
                }
            }
        }

        // Score Alert
        .alert(isPresented: $showScoreAlert) {
            Alert(
                title: Text("Quiz Complete"),
                message: Text("Your score: \(viewModel.score)/\(viewModel.questions.count)"),
                dismissButton: .default(Text("OK"))
            )
        }

        .background(
            Color.green.opacity(0.1)
                .ignoresSafeArea()
        )
    }

    // MARK: - Submission helpers

    /// User tapped "Submit"
    private func handleManualSubmit() {
        submitAndShowAlert()
    }

    /// Timer hit 0
    private func handleTimeExpired() {
        submitAndShowAlert()
    }

    /// Shared path: compute score, then defer publishing submission + showing alert.
    private func submitAndShowAlert() {
        // compute score now (pure, no @Published mutation)
        let computedScore = viewModel.gradeQuiz()

        // now defer mutations into @Published + alert trigger.
        DispatchQueue.main.async {
            viewModel.applySubmission(score: computedScore)
            showScoreAlert = true
        }
    }
}
