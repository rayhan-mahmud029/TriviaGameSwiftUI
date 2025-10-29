//
//  TriviaModels.swift
//  TriviaGame
//
//  Created by Rezwan Mahmud on 10/29/25.
//

import Foundation

// MARK: - Top-level API response

/// Matches the top-level response from the OpenTDB API.
/// Example:
/// {
///   "response_code": 0,
///   "results": [ ... questions ... ]
/// }
struct TriviaResponse: Codable {
    let results: [TriviaQuestion]
}

// MARK: - Individual trivia question

/// Represents a single trivia question from OpenTDB.
/// We generate our own `id` for SwiftUI and we pre-shuffle answers once
/// so the UI shows a stable order.
struct TriviaQuestion: Codable, Identifiable, Equatable {

    // Local UUID for SwiftUI identification
    let id: UUID

    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]

    /// Stable, already-shuffled answers for UI.
    /// Computed once in init so answer order won't reshuffle
    /// every SwiftUI redraw.
    let shuffledAnswers: [String]

    /// Convenience alias so the rest of the code can keep using `question.allAnswers`
    /// without having to rename everything.
    var allAnswers: [String] {
        shuffledAnswers
    }

    // Coding keys that match the OpenTDB API
    private enum CodingKeys: String, CodingKey {
        case category
        case type
        case difficulty
        case question
        case correct_answer
        case incorrect_answers
    }

    // MARK: - Custom decoder
    //
    // We decode the question fields from the API, generate our own UUID,
    // and build a shuffledAnswers array exactly once.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.category = try container.decode(String.self, forKey: .category)
        self.type = try container.decode(String.self, forKey: .type)
        self.difficulty = try container.decode(String.self, forKey: .difficulty)
        self.question = try container.decode(String.self, forKey: .question)
        self.correct_answer = try container.decode(String.self, forKey: .correct_answer)
        self.incorrect_answers = try container.decode([String].self, forKey: .incorrect_answers)

        self.id = UUID()

        var answers = incorrect_answers + [correct_answer]
        answers.shuffle()
        self.shuffledAnswers = answers
    }

    // MARK: - Manual initializer
    //
    // This is handy for previews/tests.
    init(
        category: String,
        type: String,
        difficulty: String,
        question: String,
        correct_answer: String,
        incorrect_answers: [String]
    ) {
        self.category = category
        self.type = type
        self.difficulty = difficulty
        self.question = question
        self.correct_answer = correct_answer
        self.incorrect_answers = incorrect_answers

        self.id = UUID()

        var answers = incorrect_answers + [correct_answer]
        answers.shuffle()
        self.shuffledAnswers = answers
    }
}

// MARK: - Safe HTML / entity decoding
//
// OpenTDB returns text like:
//   "Which player scored the most goals in &quot;La Liga&quot; 2016-17?"
// Sometimes it includes numeric entities like &#039;
// The previous approach using NSAttributedString(html:) can SIGABRT
// in newer runtimes when the HTML is malformed.
//
// So: we do a manual decode that CANNOT crash.

extension String {

    /// Public helper used in the UI.
    /// Turns things like `&quot;Hello&#039;s&quot;` into `\"Hello's\"`.
    /// Always safe.
    var htmlStripped: String {
        manualEntityDecode(self)
    }

    /// Manual replacements for common HTML / numeric entities from OpenTDB.
    /// No Foundation HTML parser. No UIKit. Zero crash risk.
    fileprivate func manualEntityDecode(_ text: String) -> String {
        var out = text

        // 1. Replace common named entities.
        // Feel free to add more if you see them in the API.
        let namedReplacements: [String: String] = [
            "&quot;": "\"",
            "&ldquo;": "\"",
            "&rdquo;": "\"",
            "&apos;": "'",
            "&rsquo;": "'",
            "&lsquo;": "'",
            "&amp;": "&",
            "&hellip;": "…",
            "&lt;": "<",
            "&gt;": ">"
        ]

        for (entity, char) in namedReplacements {
            out = out.replacingOccurrences(of: entity, with: char)
        }

        // 2. Replace numeric entities like &#039; -> '
        // Pattern: &#(one or more digits);
        let pattern = "&#(\\d+);"

        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            // We walk matches in reverse so we're not invalidating ranges as we replace.
            let matches = regex.matches(
                in: out,
                options: [],
                range: NSRange(out.startIndex..., in: out)
            ).reversed()

            for match in matches {
                guard match.numberOfRanges == 2 else { continue }

                // whole "&#...;" range
                guard let fullRange = Range(match.range(at: 0), in: out) else { continue }
                // just the number
                guard let numRange = Range(match.range(at: 1), in: out) else { continue }

                let numString = String(out[numRange])

                if let codePoint = UInt32(numString),
                   let scalar = UnicodeScalar(codePoint) {
                    let replacement = String(scalar)
                    out.replaceSubrange(fullRange, with: replacement)
                }
            }
        }

        return out
    }
}
