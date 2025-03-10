//
//  BasicPlistTweaksManager.swift
//  Nugget
//
//  Created by lemin on 9/13/24.
//

import Foundation

enum PlistTweakType {
    case toggle
    case text
}

struct PlistTweak: Identifiable {
    var id = UUID()
    var key: String
    var title: String
    var fileLocation: FileLocation
    var tweakType: PlistTweakType
    
    var boolValue: Bool = false
    var invertValue: Bool = false
    
    var stringValue: String = ""
    var placeholder: String = ""
}

struct TweakGroup: Identifiable {
    var id = UUID()
    var name: String
    var icon: String?
    var tweaks: [PlistTweak]
}

class BasicPlistTweaksManager: ObservableObject {
    static var managers: [BasicPlistTweaksManager] = [
        .init(page: .SpringBoard, tweakGroups: [
            TweakGroup(name: "Test", icon: "house", tweaks: [
                PlistTweak(key: "LockScreenFootnote", title: "Lock Screen Footnote Text", fileLocation: .footnote, tweakType: .text, placeholder: "Footnote Text"),
                PlistTweak(key: "SBDontLockAfterCrash", title: "Disable Lock After Respring", fileLocation: .springboard, tweakType: .toggle),
                PlistTweak(key: "SBDontDimOrLockOnAC", title: "Disable Screen Dimming While Charging", fileLocation: .springboard, tweakType: .toggle),
                PlistTweak(key: "SBHideLowPowerAlerts", title: "Disable Low Battery Alerts", fileLocation: .springboard, tweakType: .toggle),
                PlistTweak(key: "SBNeverBreadcrumb", title: "Disable Breadcrumb", fileLocation: .springboard, tweakType: .toggle),
                PlistTweak(key: "SBShowSupervisionTextOnLockScreen", title: "Show Supervision Text on Lock Screen", fileLocation: .springboard, tweakType: .toggle),
                PlistTweak(key: "SBCoverSheetPrelaunchCameraOnSwipe", title: "Disable Camera Prelaunch", fileLocation: .springboard, tweakType: .toggle),
                PlistTweak(key: "SBSupressAppShortcutTruncation", title: "Suppress App Shortcut Truncation", fileLocation: .springboard, tweakType: .toggle),
                PlistTweak(key: "SBSuppressNoSimAlert", title: "Suppress No SIM Alert", fileLocation: .springboard, tweakType: .toggle),
                PlistTweak(key: "SBShowStatusBarOverridesForRecording", title: "Enable Status Bar Demo", fileLocation: .springboard, tweakType: .toggle),
                PlistTweak(key: "SBDisableProximity", title: "Disable Proximity UI features", fileLocation: .springboard, tweakType: .toggle),
                PlistTweak(key: "CCSPresentationGesture", title: "Disable CC Presentation Gesture", fileLocation: .springboard, tweakType: .toggle, invertValue: true),
                PlistTweak(key: "SBExtendedDisplayOverrideSupportForAirPlayAndDontFileRadars", title: "Enable AirPlay support for Stage Manager", fileLocation: .springboard, tweakType: .toggle),
                PlistTweak(key: "DiscoverableMode", title: "Permanently Allow Receiving AirDrop from Everyone", fileLocation: .airdrop, tweakType: .toggle)
            ]),
            TweakGroup(name: "Test2", icon: "house", tweaks: [
                PlistTweak(key: "SBShowStatusBarOverridesForRecording", title: "Enable Status Bar Demo", fileLocation: .springboard, tweakType: .toggle),
            ])
        ]),
        .init(page: .Internal, tweakGroups: [
            TweakGroup(name: "SpringBoard", icon: "house", tweaks: [
                .init(key: "UIStatusBarShowBuildVersion", title: "Show Build Version in Status Bar", fileLocation: .globalPreferences, tweakType: .toggle),
                .init(key: "NSForceRightToLeftWritingDirection", title: "Force Right-to-Left Layout", fileLocation: .globalPreferences, tweakType: .toggle),
                .init(key: "MetalForceHudEnabled", title: "Enable Metal HUD Debug", fileLocation: .globalPreferences, tweakType: .toggle),
                .init(key: "AccessoryDeveloperEnabled", title: "Enable Accessory Debugging", fileLocation: .globalPreferences, tweakType: .toggle),
                .init(key: "iMessageDiagnosticsEnabled", title: "Enable iMessage Debugging", fileLocation: .globalPreferences, tweakType: .toggle),
                .init(key: "IDSDiagnosticsEnabled", title: "Enable Continuity Debugging", fileLocation: .globalPreferences, tweakType: .toggle),
                .init(key: "VCDiagnosticsEnabled", title: "Enable FaceTime Debugging", fileLocation: .globalPreferences, tweakType: .toggle),
                .init(key: "debugGestureEnabled", title: "Enable App Store Debug Gesture", fileLocation: .appStore, tweakType: .toggle),
                .init(key: "DebugModeEnabled", title: "Enable Notes App Debug Mode", fileLocation: .notes, tweakType: .toggle),
                .init(key: "BKDigitizerVisualizeTouches", title: "Show Touches With Debug Info", fileLocation: .backboardd, tweakType: .toggle),
                .init(key: "BKHideAppleLogoOnLaunch", title: "Hide Respring Icon", fileLocation: .backboardd, tweakType: .toggle),
                .init(key: "EnableWakeGestureHaptic", title: "Vibrate on Raise-to-Wake", fileLocation: .coreMotion, tweakType: .toggle),
                .init(key: "PlaySoundOnPaste", title: "Play Sound on Paste", fileLocation: .pasteboard, tweakType: .toggle),
                .init(key: "AnnounceAllPastes", title: "Show Notifications for System Pastes", fileLocation: .pasteboard, tweakType: .toggle)
            ]),
            TweakGroup(name: "Photos", icon: "photo", tweaks: [
                .init(key: "VCDiagnosticsEnabled", title: "Enable FaceTime Debugging", fileLocation: .globalPreferences, tweakType: .toggle),
            ])
        ])
    ]
    
    var page: TweakPage
    @Published var tweakGroups: [TweakGroup]
    
    init(page: TweakPage, tweakGroups: [TweakGroup]) {
        self.page = page
        self.tweakGroups = tweakGroups
        
        for var group in self.tweakGroups {
            for (i, tweak) in group.tweaks.enumerated() {
                guard let data = try? Data(contentsOf: getURLFromFileLocation(tweak.fileLocation)) else { continue }
                guard let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else { continue }
                if let val = plist[tweak.key] {
                    if let val = val as? Bool {
                        group.tweaks[i].boolValue = val
                    } else if let val = val as? String {
                        group.tweaks[i].stringValue = val
                    }
                }
            }
        }
    }
    
    static func getManager(for page: TweakPage) -> BasicPlistTweaksManager? {
        for manager in managers {
            if manager.page == page {
                return manager
            }
        }
        return nil
    }
    
    func setTweakValue(_ tweak: PlistTweak, newVal: Any) throws {
        let fileURL = getURLFromFileLocation(tweak.fileLocation)
        let data = try? Data(contentsOf: fileURL)
        var plist: [String: Any] = [:]
        if let data = data, let readPlist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] {
            plist = readPlist
        }
        plist[tweak.key] = newVal
        let newData = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try newData.write(to: fileURL)
    }
    
    func apply() -> [FileLocation: Data] {
        var changes: [FileLocation: Data] = [:]
        for group in self.tweakGroups {
            for tweak in group.tweaks {
                if changes[tweak.fileLocation] == nil {
                    guard let data = try? Data(contentsOf: getURLFromFileLocation(tweak.fileLocation)) else { continue }
                    changes[tweak.fileLocation] = data
                }
            }
        }
        return changes
    }
    
    func reset() -> [FileLocation: Data] {
        var changes: [FileLocation: Data] = [:]
        for group in self.tweakGroups {
            for tweak in group.tweaks {
                changes[tweak.fileLocation] = Data()
            }
        }
        return changes
    }
    
    static func applyAll(resetting: Bool) -> [FileLocation: Data] {
        var changes: [FileLocation: Data] = [:]
        for manager in managers {
            changes.merge(resetting ? manager.reset() : manager.apply()) { (current, new) in
                do {
                    guard let currentPlist = try PropertyListSerialization.propertyList(from: current, options: [], format: nil) as? [String: Any] else { return current }
                    guard let newPlist = try PropertyListSerialization.propertyList(from: new, options: [], format: nil) as? [String: Any] else { return current }
                    let mergedPlist = HelperFuncs.deepMerge(currentPlist, newPlist)
                    return try PropertyListSerialization.data(fromPropertyList: mergedPlist, format: .binary, options: 0)
                } catch {
                    return current
                }
            }
        }
        return changes
    }
    
    static func applyPage(_ page: TweakPage, resetting: Bool) -> [FileLocation: Data] {
        for manager in self.managers {
            if manager.page == page {
                return resetting ? manager.reset() : manager.apply()
            }
        }
        return [:]
    }
}
