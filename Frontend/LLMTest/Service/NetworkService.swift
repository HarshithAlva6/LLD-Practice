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
        case chat = "/chat"
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
    
    static func streamChat(messages: [LLMModels.ChatMessage]) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                guard let url = URL(string: baseURL + Endpoint.chat.rawValue) else {
                    continuation.finish(throwing: URLError(.badURL))
                    return
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let bodyDict: [String: Any] = [
                    "messages": messages.map { ["role": $0.role, "content": $0.content] },
                    "stream": true
                ]
                
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: bodyDict)
                    
                    let (bytes, response) = try await URLSession.shared.bytes(for: request)
                    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                        continuation.finish(throwing: URLError(.badServerResponse))
                        return
                    }
                    for try await line in bytes.lines {
                        guard line.hasPrefix("data: ") else { continue }
                        
                        let token = line.replacingOccurrences(of: "data: ", with: "")

                        if token.trimmingCharacters(in: .whitespaces) == "[DONE]" {
                            continuation.finish()
                            return
                        }
                        if token.hasPrefix("SOURCE|"){
                            let cleanSource = line.replacingOccurrences(of: "SOURCE|", with: "")
                            continuation.yield("METADATA_SOURCE:" + cleanSource)
                        } else {
                            continuation.yield(token)
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
