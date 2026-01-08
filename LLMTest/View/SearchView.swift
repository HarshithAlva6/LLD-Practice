//
//  SearchView.swift
//  LLMTest
//
//  Created by Harshith Harijeevan on 1/1/26.
//
import SwiftUI

struct SearchView: View {
    @State private var viewModel = SearchViewModel()
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Ask your Company Documents...", text: $viewModel.query)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .onSubmit { Task { await viewModel.performSearch() } }
                Button {
                    Task { await viewModel.performSearch() }
                } label: {
                    Image(systemName: "magnifyingglass.circle.fill")
                        .font(.title)
                }
                if viewModel.isLoading {
                    ProgressView("Analyzing Documents...")
                        .padding(.top, 40)
                } else if !viewModel.answer.isEmpty {
                    CitationView(
                        answer: viewModel.answer,
                        source: viewModel.sourceDocument,
                        metadata: viewModel.metadata,
                        confidence: viewModel.confidenceScore
                    )
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else if !viewModel.errorMessage.isEmpty {
                    ContentUnavailableView(
                        "Error",
                        systemImage: "exclamationmark.triangle",
                        description: Text(viewModel.errorMessage)
                    )
                }
                
                if viewModel.answer.isEmpty && !viewModel.searchHistory.isEmpty {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Recent Searches")
                                .font(.caption).bold().foregroundColor(.secondary)
                            Spacer()
                            Button("Clear") {viewModel.clearHistory()}
                                .font(.caption)
                        }
                        ForEach(viewModel.searchHistory, id: \.self) {
                            historyItem in Button {
                                viewModel.query = historyItem
                                Task { await viewModel.performSearch() }
                            } label: {
                                HStack {
                                    Image(systemName: "clock.arrow.circlepath")
                                    Text(historyItem)
                                    Spacer()
                                    Image(systemName: "arrow.up.left")
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                            Divider()
                        }
                    }
                    .padding()
                }
                ScrollView {
                    Text(viewModel.searchResult)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemCyan))
                        .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("AI Search")
        }
    }
}
