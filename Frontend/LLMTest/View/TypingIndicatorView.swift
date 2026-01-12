//
//  TypingIndicatorView.swift
//  LLMTest
//
//  Created by Harshith Harijeevan on 1/11/26.
//
import SwiftUI

struct TypingIndicatorView: View {
    @State private var anim = false

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { i in
                Circle()
                    .frame(width: 7, height: 7)
                    .opacity(anim ? 1 : 0.2)
                    .animation(.easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.2), value: anim)
            }
        }
        .padding(10)
        .onAppear { anim = true }
    }
}
