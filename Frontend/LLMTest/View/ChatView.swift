//
//  ChatView.swift
//  LLMTest
//
//  Created by Harshith Harijeevan on 1/5/26.
//
import SwiftUI

struct ChatView: View {
    @State private var viewModel = ChatViewModel()
    @Namespace var bottomID
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            ChatBotView(message: message)
                                .id(message.id)
                        }
                        if viewModel.isThinking {
                            HStack {
                                TypingIndicatorView()
                                    .padding(.leading)
                                Spacer()
                            }
                            .id("typingIndicator")
                        }
                        Color.clear.frame(height: 1).id(bottomID)
                    }
                    .padding(.top)
                }
                .onChange(of: viewModel.messages.count) {_ in
                    scrollBottom(proxy)
                }
                .onChange(of: viewModel.isThinking) {_ in
                    scrollBottom(proxy)
                }
            }
            divider
            inputArea
        }
        .navigationTitle("AI Assistant")
    }
    
    private func scrollBottom(_ proxy: ScrollViewProxy) {
        withAnimation(.spring()) {
            if viewModel.isThinking {
                proxy.scrollTo("typingIndicator", anchor: .bottom)
            } else if let lastID = viewModel.messages.last?.id {
                proxy.scrollTo(lastID, anchor: .bottom)
            }
        }
    }
    
    private var inputArea: some View {
        HStack(spacing: 12) {
            TextField("Message...", text: $viewModel.curInput)
                .padding(10)
                .background(Color(.systemGray2))
                .cornerRadius(20)
                .onSubmit { Task { await viewModel.sendMessage() }}
            
            if viewModel.isThinking {
                Button {
                    viewModel.stopGeneration()
                } label: {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.red)
                }
            } else {
                Button {
                    Task { await viewModel.sendMessage() }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(viewModel.curInput.isEmpty ? .gray: .blue)
                }
                .disabled(viewModel.curInput.isEmpty || viewModel.isThinking)
            }
        }
        .padding()
    }
    
    private var divider: some View {
        Rectangle()
            .fill(Color.cyan.opacity(0.2))
            .frame(height: 1)
    }
}
