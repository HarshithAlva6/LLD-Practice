//
//  UploadView.swift
//  LLMTest
//
//  Created by Harshith Harijeevan on 1/1/26.
//

import SwiftUI

struct UploadView: View {
    @State private var viewModel = UploadViewModel()
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextEditor(text: $viewModel.document)
                    .frame(height: 200)
                    .border(Color.gray.opacity(0.2))
                    .cornerRadius(0.2)
                Button {
                    Task { await viewModel.uploadDoc() }
                } label: {
                    if viewModel.isUploading {
                        ProgressView()
                    } else {
                        Text("Index Document")
                            .bold()
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                Text(viewModel.success)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .navigationTitle("Upload Documents")
        }
    }
}
