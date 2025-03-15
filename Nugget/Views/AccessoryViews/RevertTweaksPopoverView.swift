//
//  RevertTweaksPopoverView.swift
//  Nugget
//
//  Created by lemin on 9/17/24.
//

import SwiftUI

struct RevertTweaksPopoverView: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var applyHandler = ApplyHandler.shared
    let revertFunction: (_ reverting: Bool) -> Void
    
    struct TweakOption: Identifiable {
        var id = UUID()
        var page: TweakPage
        var enabled: Bool
    }
    
    @State var tweakOptions: [TweakOption] = []
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach($tweakOptions) { option in
                        Toggle(isOn: option.enabled) {
                            Text("\(option.page.wrappedValue.rawValue)")
                        }
                        .toggleStyle(.switch)
                        .onChange(of: option.enabled.wrappedValue) { nv in
                            if nv {
                                applyHandler.removingTweaks.insert(option.page.wrappedValue)
                            } else {
                                applyHandler.removingTweaks.remove(option.page.wrappedValue)
                            }
                        }
                    }
                }
                .navigationTitle("Select Tweaks to Revert")
                Section {
                    HStack {
                        // Cancel button
                        Button(action: {
                            dismiss()
                            revertFunction(true)
                        }) {
                            HStack(spacing: 9) {
                                Image(systemName: "arrow.left")
                                Text("Cancel")
                            }
                        }
                        .mask { RoundedRectangle(cornerRadius: 12, style: .continuous) }
                        .buttonStyle(TintedButton(color: .blue, fullwidth: true))
                        .buttonStyle(TintedButton(material: .systemMaterial, fullwidth: false))
                        // Revert button
                        Button(action: {
                            dismiss()
                            revertFunction(true)
                        }) {
                            HStack(spacing: 9) {
                                Image(systemName: "trash.fill")
                                Text("Revert")
                            }
                        }
                        .mask { RoundedRectangle(cornerRadius: 12, style: .continuous) }
                        .buttonStyle(TintedButton(color: .red, fullwidth: true))
                        .buttonStyle(TintedButton(material: .systemMaterial, fullwidth: false))
                    }
                    .padding(.vertical, 6)
                }
            }
            .onAppear {
                for page in TweakPage.allCases {
                    tweakOptions.append(.init(page: page, enabled: applyHandler.removingTweaks.contains(page)))
                }
            }
        }
    }
}
