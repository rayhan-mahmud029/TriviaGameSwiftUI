//
//  OptionsView.swift
//  TriviaGame
//
//  Created by Rezwan Mahmud on 10/29/25.
//

import SwiftUI

struct OptionsView: View {

    // MARK: - Quiz configuration state
    @State private var numberOfQuestions: Int = 5
    @State private var selectedCategoryId: Int = 21 // e.g. Sports
    @State private var selectedDifficulty: String = "easy"
    @State private var selectedType: String = "multiple"
    @State private var timerDuration: Int = 60

    // MARK: - Navigation trigger
    @State private var showGame = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                Form {
                    Section(header: Text("Trivia Settings")) {
                        Stepper(
                            "Number of Questions: \(numberOfQuestions)",
                            value: $numberOfQuestions,
                            in: 1...20
                        )

                        Picker("Category", selection: $selectedCategoryId) {
                            Text("Sports").tag(21)
                            Text("General Knowledge").tag(9)
                            Text("Geography").tag(22)
                            Text("History").tag(23)
                        }

                        Picker("Difficulty", selection: $selectedDifficulty) {
                            Text("Easy").tag("easy")
                            Text("Medium").tag("medium")
                            Text("Hard").tag("hard")
                        }

                        Picker("Type", selection: $selectedType) {
                            Text("Multiple Choice").tag("multiple")
                            Text("True / False").tag("boolean")
                        }

                        Picker("Timer Duration", selection: $timerDuration) {
                            Text("30 seconds").tag(30)
                            Text("60 seconds").tag(60)
                            Text("90 seconds").tag(90)
                        }
                    }
                }
                .scrollContentBackground(.hidden)

                // Start button that triggers navigation
                Button {
                    showGame = true
                } label: {
                    Text("Start Trivia")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.green],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                }
                .padding(.bottom, 24)
            }
            .navigationTitle("Trivia Game")

            // NEW in iOS 16+:
            // When showGame == true, push TriviaGameView
            .navigationDestination(isPresented: $showGame) {
                TriviaGameView(
                    numberOfQuestions: numberOfQuestions,
                    categoryId: selectedCategoryId,
                    difficulty: selectedDifficulty,
                    type: selectedType,
                    timeLimit: timerDuration
                )
            }
        }
    }
}

#Preview {
    OptionsView()
}
