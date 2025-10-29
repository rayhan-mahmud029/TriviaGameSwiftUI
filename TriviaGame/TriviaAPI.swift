//
//  TriviaAPI.swift
//  TriviaGame
//
//  Created by Rezwan Mahmud on 10/29/25.
//

import Foundation

struct TriviaAPI {

    static func fetchTrivia(
        amount: Int,
        category: Int?,
        difficulty: String?,
        type: String?
    ) async throws -> [TriviaQuestion] {

        var components = URLComponents(string: "https://opentdb.com/api.php")!
        var items: [URLQueryItem] = [
            URLQueryItem(name: "amount", value: "\(amount)")
        ]

        if let category = category {
            items.append(URLQueryItem(name: "category", value: "\(category)"))
        }
        if let difficulty = difficulty, !difficulty.isEmpty {
            items.append(URLQueryItem(name: "difficulty", value: difficulty))
        }
        if let type = type, !type.isEmpty {
            items.append(URLQueryItem(name: "type", value: type))
        }

        components.queryItems = items

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        print("📡 Fetching trivia from URL:", url.absoluteString)

        let (data, response) = try await URLSession.shared.data(from: url)

        if let http = response as? HTTPURLResponse {
            print("📡 HTTP status:", http.statusCode)
        }

        // Debug: show raw JSON length
        print("📡 Got \(data.count) bytes from server")

        // Try to decode
        let decoded = try JSONDecoder().decode(TriviaResponse.self, from: data)

        print("✅ Decoded \(decoded.results.count) questions from API")

        return decoded.results
    }
}
