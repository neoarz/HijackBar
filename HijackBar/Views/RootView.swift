//
//  ContentView.swift
//  Nugget
//
//  Created by lemin on 9/9/24.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Apply", systemImage: "hammer.fill")
                }
            AnyView(StatusBarView())
                .tabItem {
                    Label("Status Bar", systemImage: "wifi")
                }
        }
    }
}

#Preview {
    RootView()
}
