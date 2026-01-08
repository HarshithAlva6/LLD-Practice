//
//  Item.swift
//  LLMTest
//
//  Created by Harshith Harijeevan on 12/31/25.
//

import Foundation

struct LLMModels {
    struct MatchRequest: Encodable { let text1: String; let text2: String }
    struct QueryRequest: Encodable { let query: String }
    
    struct SimilarityResponse: Decodable { let similarity_score: Double }
    struct RAGResponse: Decodable {
        let answer: String
        let sourceDoc: String?
        let metadata: [String: String]?
        let distance: Double
    }
}


