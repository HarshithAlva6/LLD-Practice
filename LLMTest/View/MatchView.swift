//
//  LLMView.swift
//  LLMTest
//
//  Created by Harshith Harijeevan on 12/31/25.
//
import SwiftUI

struct MatchView: View {
    @State private var viewModel = MatchViewModel()
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Enter the first Input:")
                TextEditor(text: $viewModel.text1)
                    .frame(height: 100)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.secondary))
                Text("Enter the second Input:")
                TextEditor(text: $viewModel.text2)
                    .frame(height: 100)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.secondary))

                Button(action: {
                    Task {
                        await viewModel.compare()
                    }
                }, label: {
                    HStack {
                        Text("Analyse Similarity")
                        if viewModel.isLoading {
                            Spacer()
                            ProgressView()
                        }
                    }
                })
                .disabled(viewModel.text1.isEmpty || viewModel.text2.isEmpty || viewModel.isLoading)

                Text("Similarity score: \(viewModel.score, specifier: "%.4f")")
                    .font(.headline)
                    .padding(.top, 8)

                Spacer()
            }
            .padding()
            .navigationTitle("LLM Similarity")
        }
    }
}
