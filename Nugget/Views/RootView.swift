//
//  ContentView.swift
//  Nugget
//
//  Created by lemin on 9/9/24.
//

import SwiftUI

internal enum SelectableTab: Int, CaseIterable {
    case home, tweaks, credits
}

struct RootView: View {
    @State public var selectedTab: SelectableTab = .home

    var body: some View {
        VStack {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(SelectableTab.home)
                
                ToolsView()
                    .tabItem {
                        Label("Tweaks", systemImage: "wrench.and.screwdriver.fill")
                    }
                    .tag(SelectableTab.tweaks)
                
                CreditsView()
                    .tabItem {
                        Label("Credits", systemImage: "star.fill")
                    }
                    .tag(SelectableTab.credits)
            }
        }
        .overlay(alignment: .bottom) {
            let color = Color.accentColor
            GeometryReader { geometry in
                let aThird = geometry.size.width / 3
                VStack {
                    Spacer()
                    Circle()
                        .background(color.blur(radius: 80))
                        .frame(width: aThird, height: 30)
                        .shadow(color: color, radius: 40)
                        .offset(
                            x: CGFloat(selectedTab.rawValue) * aThird,
                            y: 30
                        )
                }
                .animation(.spring(response: 0.45, dampingFraction: 0.6), value: selectedTab)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}
