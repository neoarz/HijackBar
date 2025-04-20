//
//  SpringboardTweaksView.swift
//  Nugget
//
//  Created by lemin on 9/13/24.
//

import SwiftUI

struct SpringboardTweaksView: View {
    @StateObject var manager: BasicPlistTweaksManager = BasicPlistTweaksManager.getManager(for: .SpringBoard)!

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
                        if tweak.tweakType == .text {
                            TextField(tweak.placeholder, text: $manager.tweakGroups[manager.tweakGroups.firstIndex(where: { $0.id == group.id })!].tweaks[group.tweaks.firstIndex(where: { $0.id == tweak.id })!].stringValue)
                                .onChange(of: tweak.stringValue) { newValue in
                                    do {
                                        try manager.setTweakValue(tweak, newVal: newValue)
                                    } catch {
                                        UIApplication.shared.alert(body: error.localizedDescription)
                                    }
                                }
                        } else if tweak.tweakType == .toggle {
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
        }
        .navigationTitle("SpringBoard")
        .tweakToggle(for: .SpringBoard)
    }
}
