//
//  ChatViewModel.swift
//  LLMTest
//
//  Created by Harshith Harijeevan on 1/4/26.
//

import Foundation
import Observation

@Observable
class ChatViewModel {
    var messages: [LLMModels.ChatMessage] = []
    var curInput: String = ""
    var isThinking: Bool = false
    var errorMessage: String? = nil
    
    var isStreamingEnabled: Bool = true
    private var streamingTask: Task<Void, Never>? = nil
    
    @MainActor
    func sendMessage() async {
        let trimInput = curInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimInput.isEmpty else { return }
        
        let newMessage = LLMModels.ChatMessage(role: "user", content: trimInput)
        messages.append(newMessage)
        curInput = ""
        isThinking = true
        errorMessage = nil
        
        if isStreamingEnabled {
            // Create an empty assistant placeholder and capture its auto-generated id
            let placeholder = LLMModels.ChatMessage(role: "assistant", content: "")
            messages.append(placeholder)
            let placeholderID = placeholder.id
            
            streamingTask = Task {
                do {
                    let stream = NetworkService.streamChat(messages: Array(messages.dropLast()))
                    for try await token in stream {
                        if Task.isCancelled { break }
                        isThinking = false
                        
                        if token.hasPrefix("METADATA_SOURCE:") {
                            let sourceContent = token.replacingOccurrences(of: "METADATA_SOURCE:", with: "")
                            if let index = messages.firstIndex(where: { $0.id == placeholderID }) {
                                // Since ChatMessage.content is let, we need to replace the whole message with updated content
                                let updated = LLMModels.ChatMessage(
                                    role: messages[index].role,
                                    content: messages[index].content, // Keep existing content
                                    source: sourceContent             // Set the new source
                                    )
                                // Preserve stable ordering by replacing in place
                                messages[index] = updated
                            }
                        } else {
                            if let index = messages.firstIndex(where: { $0.id == placeholderID }) {
                                let updated = LLMModels.ChatMessage(
                                    role: messages[index].role,
                                    content: messages[index].content + token,
                                    source: messages[index].source // Keep the source intact!
                                )
                                messages[index] = updated
                            }
                        }
                    }
                } catch {
                    errorMessage = "Streaming failed: \(error.localizedDescription)"
                }
                isThinking = false
                streamingTask = nil
            }
        }
        else {
            do {
                // Serialize the chat history into a single String since ChatRequest expects String
                let historyText = messages
                    .map { "\($0.role): \($0.content)" }
                    .joined(separator: "\n")
                
                let request = LLMModels.ChatRequest(messages: historyText)
                let response: LLMModels.RAGResponse = try await NetworkService.post(
                    endpoint: .chat,
                    body: request
                )
                let assistantMessage = LLMModels.ChatMessage(role: "assistant", content: response.answer)
                messages.append(assistantMessage)
            } catch {
                print("Chat Error: \(error)")
                errorMessage = error.localizedDescription
            }
        }
        isThinking = false
    }
    
    func stopGeneration() {
        streamingTask?.cancel()
        streamingTask = nil
        isThinking = false
    }
}
