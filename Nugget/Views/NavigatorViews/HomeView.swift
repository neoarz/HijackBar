//
//  HomeView.swift
//  Nugget
//
//  Created by lemin on 9/9/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct HomeView: View {
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""

    @State var showRevertPage = false
    @State var showPairingFileImporter = false
    @State var showErrorAlert = false
    @State var lastError: String?
    @State var path = NavigationPath()
    @State private var appliedTweaks: [String] = []
    
    // Prefs
    @AppStorage("AutoReboot") var autoReboot: Bool = true
    @AppStorage("PairingFile") var pairingFile: String?
    @AppStorage("SkipSetup") var skipSetup: Bool = true
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                // MARK: Tweak Options
                Section {
                    VStack {
                        HStack {
                            HStack {
                                Button(action: {
                                    applyChanges(reverting: false)
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "hammer.fill")
                                        Text("Apply")
                                    }
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .buttonStyle(TintedButton(color: .blue, fullwidth: true))
                                .buttonStyle(TintedButton(material: .systemMaterial, fullwidth: false))
                            }
                            HStack {
                                Button(action: {
                                    showRevertPage.toggle()
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "trash.fill")
                                        Text("Revert")
                                    }
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .buttonStyle(TintedButton(color: .red, fullwidth: true))
                                .sheet(isPresented: $showRevertPage, content: {
                                    RevertTweaksPopoverView(revertFunction: applyChanges(reverting:))
                                })
                                .buttonStyle(TintedButton(material: .systemMaterial, fullwidth: false))
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                        // select pairing file button
                        if !ApplyHandler.shared.trollstore {
                            if pairingFile == nil {
                                HStack {
                                    Button(action: {
                                        showPairingFileImporter.toggle()
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "doc.fill")
                                            Text("Import Pairing File")
                                        }
                                    }
                                    .frame(maxHeight: 45)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .buttonStyle(TintedButton(color: .orange, fullwidth: true))
                                    .buttonStyle(TintedButton(material: .systemMaterial, fullwidth: false))
                                }
                            } else {
                                Button(action: {
                                    pairingFile = nil
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "doc.fill.badge.plus")
                                        Text("Remove Pairing File")
                                    }
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .buttonStyle(TintedButton(color: .green, fullwidth: true))
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .padding()
                } header: {
                    Label("Tweak Options", systemImage: "hammer.fill")
                }
                // MARK: Preferences
                Section {
                    Toggle(isOn: $skipSetup) {
                        HStack {
                            Image(systemName: "arrow.down.doc")
                                .frame(width: 20)
                            Text("Traditional Skip Setup")
                                .minimumScaleFactor(0.5)
                        }
                    }
                    Toggle(isOn: $autoReboot) {
                        HStack {
                            Image(systemName: "goforward")
                                .frame(width: 20)
                            Text("Reboot After Applying")
                        }
                    }
                } header: {
                    Label("Preferences", systemImage: "gearshape.fill")
                } footer : {
                    Text("**Traditional Skip Setup**: If you use configuration profiles, please turn this off.\n\nSkip Setup will only be applied when restoring **Status Bar** Tweaks.")
                }
                .fileImporter(isPresented: $showPairingFileImporter, allowedContentTypes: [UTType(filenameExtension: "mobiledevicepairing", conformingTo: .data)!, UTType(filenameExtension: "mobiledevicepair", conformingTo: .data)!], onCompletion: { result in
                    switch result {
                    case .success(let url):
                        do {
                            pairingFile = try String(contentsOf: url)
                            startMinimuxer()
                        } catch {
                            lastError = error.localizedDescription
                            showErrorAlert.toggle()
                        }
                    case .failure(let error):
                        lastError = error.localizedDescription
                        showErrorAlert.toggle()
                    }
                })
                .alert("Error", isPresented: $showErrorAlert) {
                    Button("Continue") {}
                } message: {
                    Text(lastError ?? "???")
                }
                // MARK: Credits
                Section {
                    NavigationLink(destination: LogView(resetting: false, autoReboot: false, skipSetup: false)) {
                        HStack(spacing: 10) {
                            Image(systemName: "apple.terminal.fill")
                                .frame(width: 20)
                                .font(.system(size: 16))
                            Text("Show Logs")
                        }
                    }
                    NavigationLink(destination: CreditsView()) {
                        HStack(spacing: 10) {
                            Image(systemName: "star.fill")
                                .frame(width: 20)
                            Text("Credits")
                        }
                    }
                    Button(action: {
                        if let url = URL(string: "https://gist.github.com/lunginspector/3d7ea2496b3180ee88bad1ac7fdf5e2a") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "info.circle.fill")
                                .frame(width: 20)
                            Text("How To Use")
                        }
                    }
                } header: {
                    Label("Version \(Bundle.main.releaseVersionNumber ?? "UNKNOWN") (\(Int(buildNumber) != 0 ? "\(buildNumber)" : NSLocalizedString("Release", comment:"")))", systemImage: "info.circle.fill")
                }
            }
            .onOpenURL(perform: { url in
                // for opening the mobiledevicepairing file
                if url.pathExtension.lowercased() == "mobiledevicepairing" {
                    do {
                        pairingFile = try String(contentsOf: url)
                        startMinimuxer()
                    } catch {
                        lastError = error.localizedDescription
                        showErrorAlert.toggle()
                    }
                }
            })
            .onAppear {
                _ = start_emotional_damage("127.0.0.1:51820")
                if let altPairingFile = Bundle.main.object(forInfoDictionaryKey: "ALTPairingFile") as? String, altPairingFile.count > 5000, pairingFile == nil {
                    pairingFile = altPairingFile
                } else if pairingFile == nil, FileManager.default.fileExists(atPath: URL.documents.appendingPathComponent("pairingfile.mobiledevicepairing").path) {
                    pairingFile = try? String(contentsOf: URL.documents.appendingPathComponent("pairingfile.mobiledevicepairing"))
                }
                startMinimuxer()
            }
            .navigationTitle("Tender")
            .navigationDestination(for: String.self) { view in
                if view == "ApplyChanges" {
                    LogView(resetting: false, autoReboot: autoReboot, skipSetup: skipSetup)
                } else if view == "RevertChanges" {
                    LogView(resetting: true, autoReboot: autoReboot, skipSetup: skipSetup)
                }
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK") {}
            } message: {
                Text(lastError ?? "???")
            }
        }
    }
    
    init() {
        // Fix file picker
        if let fixMethod = class_getInstanceMethod(UIDocumentPickerViewController.self, Selector(("fix_initForOpeningContentTypes:asCopy:"))), let origMethod = class_getInstanceMethod(UIDocumentPickerViewController.self, #selector(UIDocumentPickerViewController.init(forOpeningContentTypes:asCopy:))) {
            method_exchangeImplementations(origMethod, fixMethod)
        }
    }
    
    func applyChanges(reverting: Bool) {
        if ApplyHandler.shared.trollstore || ready() {
            if !reverting && ApplyHandler.shared.allEnabledTweaks().isEmpty {
                // if there are no enabled tweaks then tell the user
                UIApplication.shared.alert(body: "You do not have any tweaks enabled. Go to the tweaks page to select some.")
            } else if ApplyHandler.shared.isExploitOnly() {
                path.append(reverting ? "RevertChanges" : "ApplyChanges")
            } else if !ApplyHandler.shared.trollstore {
                // if applying non-exploit files, warn about setup
                UIApplication.shared.confirmAlert(title: "Warning!", body: "You are applying non-exploit related files. This will make the setup screen appear. Click Cancel if you do not wish to proceed.\n\nWhen setting up, you MUST click \"Do not transfer apps & data\".\n\nIf you see a screen that says \"iPhone Partially Set Up\", DO NOT tap the big blue button. You must click \"Continue with Partial Setup\".", onOK: {
                    path.append(reverting ? "RevertChanges" : "ApplyChanges")
                }, noCancel: false)
            }
        } else if pairingFile == nil {
            lastError = "Please import your pairing file to apply any tweaks."
            showErrorAlert.toggle()
        } else {
            lastError = "Minimuxer is not responding. Ensure that StosVPN is enabled and connected."
            showErrorAlert.toggle()
        }
    }
    
    func startMinimuxer() {
        guard pairingFile != nil else {
            return
        }
        target_minimuxer_address()
        do {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].absoluteString
            try start(pairingFile!, documentsDirectory)
        } catch {
            lastError = error.localizedDescription
            showErrorAlert.toggle()
        }
    }
    
    public func withArrayOfCStrings<R>(
        _ args: [String],
        _ body: ([UnsafeMutablePointer<CChar>?]) -> R
    ) -> R {
        var cStrings = args.map { strdup($0) }
        cStrings.append(nil)
        defer {
            cStrings.forEach { free($0) }
        }
        return body(cStrings)
    }
}
