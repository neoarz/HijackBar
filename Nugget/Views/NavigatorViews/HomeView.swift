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
                            // apply all tweaks button
                            HStack {
                                Button(action: {
                                    applyChanges(reverting: false)
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "hammer.fill")
                                        Text("Apply")
                                    }
                                }
                                .mask { RoundedRectangle(cornerRadius: 12, style: .continuous) }
                                .buttonStyle(TintedButton(color: .blue, fullwidth: true))
                                .buttonStyle(TintedButton(material: .systemMaterial, fullwidth: false))
                            }
                            // remove all tweaks button
                            HStack {
                                Button(action: {
                                    showRevertPage.toggle()
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "trash.fill")
                                        Text("Revert")
                                    }
                                }
                                .mask { RoundedRectangle(cornerRadius: 12, style: .continuous) }
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
                                            Text("Select Pairing File")
                                        }
                                    }
                                    .mask { RoundedRectangle(cornerRadius: 12, style: .continuous) }
                                    .buttonStyle(TintedButton(color: .orange, fullwidth: true))
                                    .buttonStyle(TintedButton(material: .systemMaterial, fullwidth: false))
                                }
                            } else {
                                Button(action: {
                                    pairingFile = nil
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "doc.fill.badge.plus")
                                        Text("Reset Pairing File")
                                    }
                                }
                                .mask { RoundedRectangle(cornerRadius: 12, style: .continuous) }
                                .buttonStyle(TintedButton(color: .green, fullwidth: true))
                            }
                        }
                    }
                    .padding(.vertical, 5)
                    .padding(.horizontal, -1)
                } header: {
                    Label("Tweak Options", systemImage: "gearshape.fill")
                        .padding(.leading, -4)
                }
                Section {
                    VStack(spacing: 14) {
                        // auto reboot option
                        HStack {
                            Image(systemName: "power")
                            Toggle(isOn: $autoReboot) {
                                Text("Reboot after apply")
                                    .minimumScaleFactor(0.5)
                            }
                        }
                        // skip setup
                        Toggle(isOn: $skipSetup) {
                            HStack {
                                Image(systemName: "restart.circle.fill")
                                Text("Traditional Skip Setup")
                                    .minimumScaleFactor(0.5)
                            }
                        }
                    }
                } header: {
                    Label("Application Options", systemImage: "hammer.fill")
                        .padding(.leading, -4)
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
                                Button("OK") {}
                            } message: {
                                Text(lastError ?? "???")
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
            .navigationTitle("Nugget Revamped")
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
                UIApplication.shared.alert(body: "You do not have any tweaks enabled! Go to the tools page to select some.")
            } else if ApplyHandler.shared.isExploitOnly() {
                path.append(reverting ? "RevertChanges" : "ApplyChanges")
            } else if !ApplyHandler.shared.trollstore {
                // if applying non-exploit files, warn about setup
                UIApplication.shared.confirmAlert(title: "Warning!", body: "You are applying non-exploit related files. This will make the setup screen appear. Click Cancel if you do not wish to proceed.\n\nWhen setting up, you MUST click \"Do not transfer apps & data\".\n\nIf you see a screen that says \"iPhone Partially Set Up\", DO NOT tap the big blue button. You must click \"Continue with Partial Setup\".", onOK: {
                    path.append(reverting ? "RevertChanges" : "ApplyChanges")
                }, noCancel: false)
            }
        } else if pairingFile == nil {
            lastError = "Please select your pairing file to continue."
            showErrorAlert.toggle()
        } else {
            lastError = "minimuxer is not ready. Ensure you have WiFi and WireGuard VPN set up."
            showErrorAlert.toggle()
        }
    }
    
    struct LinkCell: View {
        var imageName: String
        var url: String
        var title: String
        var contribution: String
        var systemImage: Bool = false
        var circle: Bool = false
        
        var body: some View {
            HStack(alignment: .center) {
                Group {
                    if systemImage {
                        Image(systemName: imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        if imageName != "" {
                            Image(imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                }
                .cornerRadius(circle ? .infinity : 0)
                .frame(width: 24, height: 24)
                
                VStack {
                    HStack {
                        Button(action: {
                            if url != "" {
                                UIApplication.shared.open(URL(string: url)!)
                            }
                        }) {
                            Text(title)
                                .fontWeight(.bold)
                        }
                        .padding(.horizontal, 6)
                        Spacer()
                    }
                    HStack {
                        Text(contribution)
                            .padding(.horizontal, 6)
                            .font(.footnote)
                        Spacer()
                    }
                }
            }
            .foregroundColor(.blue)
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
