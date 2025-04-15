//
//  ContentView.swift
//  Nugget
//
//  Created by lemin on 9/9/24.
//

import SwiftUI

internal enum SelectableTab: Int, CaseIterable {
    case home, tweaks
}

struct RootView: View {
    @State public var selectedTab: SelectableTab = .home

    var body: some View {
        VStack {
            TabView(selection: $selectedTab) {
                Group {
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
                }
            }
        }
    }
}
