//
//  NetworkService.swift
//  LLMTest
//
//  Created by Harshith Harijeevan on 1/1/26.
//
import Foundation

@MainActor
class NetworkService {
    static let baseURL = "http://172.20.16.196:8000"
    
    enum Endpoint: String {
        case compare = "/compare"
        case query = "/query"
        case addCollection = "/addCollection"
    }
    
    static func post<T: Encodable, U: Decodable>(endpoint: Endpoint, body: T) async throws -> U {
        guard let url = URL(string: baseURL + endpoint.rawValue) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(U.self, from: data)
    }
}
