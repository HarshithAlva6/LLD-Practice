//
//  Untitled.swift
//  LLMTest
//
//  Created by Harshith Harijeevan on 1/3/26.
//
import SwiftUI
import Foundation

struct CitationView: View {
    let answer: String
    let source: String?
    let metadata: [String: String]?
    let confidence: Double
    @State private var showFullSource = false
    var body: some View {
        VStack(alignment: .leading, spacing: 12){
            GroupBox(label: Label("AI Answer", systemImage: "sparkles")){
                Text(answer)
                    .font(.body).italic()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .backgroundStyle(Color.blue.opacity(0.05))
            
            if let sourceName = metadata?["source"] {
                VStack(alignment: .leading, spacing: 8){
                    HStack{
                        Label("Source: \(sourceName)", systemImage: "doc.text")
                            .font(.caption).bold()
                        Spacer()
                        Text("\(confidence)% match")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(5)
                            .onTapGesture {
                                withAnimation {showFullSource.toggle()}
                            }
                        Text(showFullSource ? "Tap to collapse":"Tap to see full Context")
                            .font(.system(size: 10))
                            .foregroundColor(.cyan)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
            }
        }
    }
}
