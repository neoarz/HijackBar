//
//  FeatureFlagsView.swift
//  Nugget
//
//  Created by lemin on 9/9/24.
//

import SwiftUI

struct FeatureFlagsView: View {
    @StateObject var ffManager = FeatureFlagManager.shared
    
    struct FeatureFlagOption: Identifiable {
        var id = UUID()
        var label: String
        var flag: FeatureFlag
        var active: Bool = false
    }
    
    struct FeatureFlagGroup: Identifiable {
        var id = UUID()
        var text: String
        var symbol: String
        var options: [FeatureFlagOption]
    }
    
    @State var featureFlagGroups: [FeatureFlagGroup] = [
        .init(text: "Apple Intelligence", symbol: "apple.intelligence", options: [
            .init(label: "Enable Apple Intelligence",
                  flag: .init(id: 3, category: .SpringBoard, flags: ["Domino", "SuperDomino"]))
        ]),
        .init(text: "Lock Screen", symbol: "lock.fill", options: [
            .init(label: "Toggle Lockscreen Clock Animation",
                  flag: .init(id: 0, category: .SpringBoard, flags: ["SwiftUITimeAnimation"])),
            .init(label: "Toggle Duplicate Lockscreen Button and Lockscreen Quickswitch",
                  flag: .init(id: 1, category: .SpringBoard, flags: ["AutobahnQuickSwitchTransition", "SlipSwitch", "PosterEditorKashida"])),
        ]),
        .init(text: "Photos", symbol: "photo", options: [
            .init(label: "Enable Old Photo UI",
                  flag: .init(id: 2, category: .Photos, flags: ["Lemonade"], is_list: false, inverted: true)),
        ])
    ]
    
    var body: some View {
        List {
            ForEach($featureFlagGroups) { group in
                Section(header: HStack {
                    Image(systemName: group.symbol.wrappedValue)
                    Text(group.text.wrappedValue)
                }) {
                    ForEach(group.options) { option in
                        Toggle(option.label.wrappedValue, isOn: option.active).onChange(of: option.active.wrappedValue, perform: { nv in
                            if nv {
                                ffManager.EnabledFlags.append(option.flag.wrappedValue)
                            } else {
                                for (i, flag) in ffManager.EnabledFlags.enumerated() {
                                    if option.flag.wrappedValue.id == flag.id {
                                        ffManager.EnabledFlags.remove(at: i)
                                        return
                                    }
                                }
                            }
                        })
                    }
                }
            }
            .onAppear {
                // get the enabled feature flags
                // O(n^2), should be improved
                let enabledFlags = ffManager.EnabledFlags
                for (i, group) in featureFlagGroups.enumerated() {
                    for (j, option) in group.options.enumerated() {
                        for enabledFlag in enabledFlags {
                            if enabledFlag.id == option.flag.id {
                                featureFlagGroups[i].options[j].active = true
                                break
                            }
                        }
                    }
                }
            }
        }
        // Move the modifers here please
        .tweakToggle(for: .FeatureFlags)
        .navigationTitle("Feature Flags")
        .navigationViewStyle(.stack)
    }
}
