//
//  ToolsView.swift
//  Nugget
//
//  Created by lemin on 9/9/24.
//

import SwiftUI

struct ToolsView: View {
    @StateObject var applyHandler = ApplyHandler.shared
    
    struct GeneralOption: Identifiable {
        var id = UUID()
        var page: TweakPage
        var view: AnyView
        var title: String
        var imageName: String
        var minVersion: Version = Version(string: "1.0")
    }
    
    struct ToolCategory: Identifiable {
        var id = UUID()
        var title: String
        var icon: String
        var pages: [GeneralOption]
    }
    
    @State var tools: [ToolCategory] = [
        .init(title: "Feature Enablers", icon: "sparkles", pages: [
            .init(page: .MobileGestalt, view: AnyView(GestaltView()), title: NSLocalizedString("MobileGestalt", comment: "Title of tool"), imageName: "platter.filled.top.and.arrow.up.iphone"),
            .init(page: .FeatureFlags, view: AnyView(FeatureFlagsView()), title: NSLocalizedString("Feature Flags", comment: "Title of tool"), imageName: "checklist", minVersion: Version(string: "18.0")),
            .init(page: .Eligibility, view: AnyView(EligibilityView()), title: NSLocalizedString("Apple Intelligence", comment: "Title of tool"), imageName: "apple.intelligence", minVersion: Version(string: "18.1")/*Version(string: "17.4")*/),
        ]),
        .init(title: "Basic Tweaks", icon: "doc.badge.gearshape.fill", pages: [
            .init(page: .StatusBar, view: AnyView(StatusBarView()), title: NSLocalizedString("Status Bar", comment: "Title of tool"), imageName: "wifi"),
            .init(page: .SpringBoard, view: AnyView(SpringboardTweaksView()), title: NSLocalizedString("SpringBoard", comment: "Title of tool"), imageName: "app.badge"),
            .init(page: .Internal, view: AnyView(InternalOptionsView()), title: NSLocalizedString("Internal", comment: "Title of tool"), imageName: "internaldrive"),
        ])
        
    ]
    
    let userVersion = Version(string: UIDevice.current.systemVersion)
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .padding(.trailing, 6)
                            .font(.system(size: 24, weight: .regular, design: .default))
                            .foregroundStyle(.black)
                        Text("**Warning:** If you do not know what an option does, do **not** enable it.")
                            .font(.system(size: 17))
                            .foregroundStyle(.black)
                    }
                    .listRowBackground(Color.yellow)
                    .padding(.vertical, 4)
                }
                ForEach($tools) { category in
                    Section {
                        ForEach(category.pages) { option in
                            if option.minVersion.wrappedValue <= userVersion {
                                NavigationLink(destination: option.view.wrappedValue) {
                                    HStack {
                                        Image(systemName: option.imageName.wrappedValue)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 24, height: 24)
                                        Text(option.title.wrappedValue)
                                            .padding(.horizontal, 8)
                                        if applyHandler.isTweakEnabled(option.page.wrappedValue) {
                                            // show that it is enabled
                                            Spacer()
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(Color(.green))
                                        }
                                    }
                                }
                            }
                        }
                    } header: {
                        HStack {
                            Image(systemName: category.icon.wrappedValue)
                            Text(category.title.wrappedValue)
                        }
                        .padding(.leading, -4)
                    }
                }
            }
            .navigationTitle("Tweaks")
        }
    }
}
