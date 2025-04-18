//
//  InternalOptionsView.swift
//  Nugget
//
//  Created by lemin on 9/13/24.
//

import SwiftUI

struct InternalOptionsView: View {
    @StateObject var manager: BasicPlistTweaksManager = BasicPlistTweaksManager.getManager(for: .Internal)!

    var body: some View {
        List {
            ForEach(manager.tweakGroups) { group in
                Section(header: HStack {
                    if let icon = group.icon {
                        Image(systemName: icon)
                    }
                    Text(group.name)
                }) {
                    ForEach(group.tweaks) { tweak in
                        Toggle(tweak.title, isOn: $manager.tweakGroups[manager.tweakGroups.firstIndex(where: { $0.id == group.id })!].tweaks[group.tweaks.firstIndex(where: { $0.id == tweak.id })!].boolValue)
                            .onChange(of: tweak.boolValue) { newValue in
                                do {
                                    try manager.setTweakValue(tweak, newVal: newValue)
                                } catch {
                                    UIApplication.shared.alert(body: error.localizedDescription)
                                }
                            }
                    }
                }
            }
        }
        .navigationTitle("Internal")
        .tweakToggle(for: .Internal)
    }
}

