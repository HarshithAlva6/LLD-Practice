//
//  SearchViewModel.swift
//  LLMTest
//
//  Created by Harshith Harijeevan on 1/1/26.
//

import Foundation

@Observable
@MainActor
class SearchViewModel {
    var query: String = ""
    var searchResult: String = ""
    var isLoading: Bool = false
    var sourceDocument: String? = nil
    var metadata: [String: String]? = nil
    var confidenceScore: Double = 0.0
    var answer: String = ""
    var errorMessage: String = ""
    
    var searchHistory: [String] = UserDefaults.standard.stringArray(forKey: "searchHistory") ?? []
    
    func performSearch() async {
        guard !query.isEmpty else {return}
        
        if !searchHistory.contains(query) {
            searchHistory.insert(query, at: 0)
            if searchHistory.count > 5 {searchHistory.removeLast()}
            UserDefaults.standard.set(searchHistory, forKey: "searchHistory")
        }
        isLoading = true
        answer = ""
        defer {isLoading = false}
        do {
            let response: LLMModels.RAGResponse = try await NetworkService.post(
                endpoint: .query,
                body: LLMModels.QueryRequest(query: query)
            )
            self.answer = response.answer
            self.sourceDocument = response.sourceDoc
            self.metadata = response.metadata
            self.confidenceScore = max(0, 1.0 - (response.distance / 2.0)) * 100
        } catch {
            self.searchResult = "Connection Failed"
        }
        isLoading = false
    }
    
    func clearHistory() {
        searchHistory.removeAll()
        UserDefaults.standard.removeObject(forKey: "searchHistory")
    }
}
