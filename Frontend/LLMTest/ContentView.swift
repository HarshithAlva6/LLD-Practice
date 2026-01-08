//
//  ContentView.swift
//  LLMTest
//
//  Created by Harshith Harijeevan on 12/31/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            MatchView()
                .tabItem { Label("Matcher", systemImage: "arrow.left")}
            SearchView()
                .tabItem { Label("Knowledge", systemImage: "doc.text.magnifyingglass")}
            UploadView()
                .tabItem { Label("Upload", systemImage: "plus.app")}
        }
    }
}

#Preview {
    ContentView()
}
