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

struct CustomTabBar: View {
    @Binding var selectedTab: SelectableTab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(SelectableTab.allCases, id: \.rawValue) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack {
                        Image(systemName: tab == .home ? "house.fill" : "wrench.and.screwdriver.fill")
                            .font(.system(.title2))
                            .padding(.vertical, 4)
                            .padding(.horizontal, 30)
                    }
                    .foregroundColor(selectedTab == tab ? .blue : .gray)
                    //.frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .background(.ultraThinMaterial)
        .overlay(RoundedRectangle(cornerRadius: 18)
            .stroke(Color(.secondarySystemFill), lineWidth: 1)
            )
        .clipShape(RoundedRectangle(cornerRadius: 18))
        //.border(Color(.secondarySystemFill))
        .padding(.horizontal)
        .shadow(radius: 0)
    }
}

struct RootView: View {
    @State public var selectedTab: SelectableTab = .home
    
    init() {
        // Hide default tab bar background
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().isTranslucent = true
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        //Label("Home", systemImage: "house.fill")
                    }
                    .tag(SelectableTab.home)
                ToolsView()
                    .tabItem {
                        //Label("Tweaks", systemImage: "wrench.and.screwdriver.fill")
                    }
                    .tag(SelectableTab.tweaks)
            }
            
            CustomTabBar(selectedTab: $selectedTab)
                .padding(.bottom, 20)
        }
        .padding(.bottom, 5)
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    RootView()
}
