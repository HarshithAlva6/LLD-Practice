//
//  LLMViewModel.swift
//  LLMTest
//
//  Created by Harshith Harijeevan on 12/31/25.
//

import Foundation
import Observation

@MainActor
@Observable
class MatchViewModel {
    var text1: String = ""
    var text2: String = ""
    var score: Double = 0.0
    var isLoading: Bool = false
    func compare() async {
        isLoading = true
        defer {isLoading = false}
        do {
            let response: LLMModels.SimilarityResponse = try await NetworkService.post(
                endpoint: .compare,
                body: LLMModels.MatchRequest(text1: text1, text2: text2)
            )
            self.score = response.similarity_score
        } catch {
            print("Match Error: \(error)")
        }
    }
    
}
