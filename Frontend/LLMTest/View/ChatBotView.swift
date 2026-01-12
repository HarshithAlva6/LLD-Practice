//
//  ChatBotView.swift
//  LLMTest
//
//  Created by Harshith Harijeevan on 1/5/26.
//
import SwiftUI

struct ChatBotView: View {
    let message: LLMModels.ChatMessage
    var isUser: Bool { message.role == "user" }
    var body: some View {
        HStack {
            if isUser { Spacer() }
            VStack(alignment: .leading, spacing: 6) {
                Text(message.content)
                    .padding(12)
                    .background(isUser ? Color.blue:Color(.systemCyan))
                    .foregroundColor(isUser ? .white : .primary)
                    .clipShape(UnevenRoundedRectangle(
                        topLeadingRadius: 16,
                        bottomLeadingRadius: 16,
                        bottomTrailingRadius: isUser ? 0:16,
                        topTrailingRadius: isUser ? 16:0
                    ))
                if let source = message.source, !source.isEmpty {
                    DisclosureGroup {
                        Text(source)
                            .font(.system(size:10, design: .monospaced))
                            .foregroundColor(.secondary)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(6)
                    } label: {
                        Text("View Source")
                            .font(.caption2.bold())
                            .foregroundColor(.yellow)
                    }
                    .frame(maxWidth: 200)
                }
            }
            if !isUser { Spacer() }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}
