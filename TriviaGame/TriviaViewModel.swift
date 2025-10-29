//
//  TriviaViewModel.swift
//  TriviaGame
//
//  Created by Rezwan Mahmud on 10/29/25.
//

import SwiftUI
import Combine

@MainActor
class TriviaViewModel: ObservableObject {

    // Published game state
    @Published var questions: [TriviaQuestion] = []
    @Published var selectedAnswers: [UUID: String] = [:]
    @Published var timeRemaining: Int = 60
    @Published var didSubmit: Bool = false
    @Published var score: Int = 0

    // Internal config
    private var configuredTimeLimit: Int = 60

    // Timer
    private var cancellable: AnyCancellable?

    // MARK: - Loading trivia (staged: fetch first, then publish later)

    /// Fetch trivia from API, but DO NOT mutate @Published here.
    /// We return the decoded data so the view can decide when to apply it.
    func loadQuestions(
        amount: Int,
        category: Int?,
        difficulty: String?,
        type: String?,
        timeLimit: Int
    ) async -> (questions: [TriviaQuestion], timeLimit: Int)? {

        do {
            print("🔄 Loading questions...")
            let result = try await TriviaAPI.fetchTrivia(
                amount: amount,
                category: category,
                difficulty: difficulty,
                type: type
            )

            print("✅ ViewModel fetched \(result.count) questions")

            return (questions: result, timeLimit: timeLimit)

        } catch {
            print("❌ Failed to load trivia:", error)
            return nil
        }
    }

    /// Actually publish the round state into @Published properties.
    /// This MUST be called on the main actor, but we already are @MainActor.
    /// We call this from `DispatchQueue.main.async { ... }` in the View
    /// so SwiftUI isn't mid-layout when these changes land.
    func applyLoadedGame(questions: [TriviaQuestion], timeLimit: Int) {
        self.questions = questions
        self.selectedAnswers = [:]
        self.didSubmit = false
        self.score = 0

        self.configuredTimeLimit = timeLimit
        self.timeRemaining = timeLimit

        print("📦 Applied game into ViewModel: \(questions.count) questions, timer=\(timeLimit)")
    }

    // MARK: - Answer selection

    func chooseAnswer(for question: TriviaQuestion, answer: String) {
        guard !didSubmit else { return }
        selectedAnswers[question.id] = answer
    }

    // MARK: - Grading / submission (staged)

    /// Pure score calculation. DOES NOT modify any @Published.
    func gradeQuiz() -> Int {
        var total = 0
        for q in questions {
            if selectedAnswers[q.id] == q.correct_answer {
                total += 1
            }
        }
        return total
    }

    /// Apply the "quiz finished" state.
    /// We DO mutate @Published here, so this must be called in a deferred block
    /// (DispatchQueue.main.async in the view) to avoid the SwiftUI reentrancy crash.
    func applySubmission(score: Int) {
        stopTimer()

        self.score = score
        self.didSubmit = true

        print("🏁 Applied submission. Score = \(score)/\(questions.count)")
    }

    // MARK: - Timer

    /// Start countdown.
    /// Safe usage pattern:
    ///   - call this ONLY after `applyLoadedGame(...)`
    ///   - call it from a deferred context in the View (DispatchQueue.main.async)
    func startTimer(onExpire: @escaping () -> Void) {
        // Stop any previous timer
        stopTimer()

        // Reset countdown to configured limit (in case called manually)
        self.timeRemaining = configuredTimeLimit

        print("⏱ Starting timer for \(configuredTimeLimit)s")

        // Use a Combine publisher so we stay on main RunLoop.
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }

                if self.didSubmit {
                    // If the quiz is already submitted, stop ticking.
                    self.stopTimer()
                    return
                }

                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    print("⏱ Time expired, auto-submitting.")
                    self.stopTimer()
                    onExpire() // tell the view "time's up"
                }
            }
    }

    func stopTimer() {
        cancellable?.cancel()
        cancellable = nil
    }
}
