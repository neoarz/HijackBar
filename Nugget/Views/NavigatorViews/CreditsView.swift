//
//  CreditsView.swift
//  Nugget
//
//  Created by lunginspector on 3/7/25.
//

import SwiftUI

extension Color {
    init(hex: String) {
        var cleanHexCode = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        cleanHexCode = cleanHexCode.replacingOccurrences(of: "#", with: "")
        print(cleanHexCode)
        var rgb: UInt64 = 0
        
        Scanner(string: cleanHexCode).scanHexInt64(&rgb)
        
        let redValue = Double((rgb >> 16) & 0xFF) / 255.0
        let greenValue = Double((rgb >> 8) & 0xFF) / 255.0
        let blueValue = Double(rgb & 0xFF) / 255.0
        self.init(red: redValue, green: greenValue, blue: blueValue)
    }
}

struct CreditsView: View {
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image("tender")
                            .resizable()
                            .scaledToFit()
                            .clipShape(.rect(cornerRadius: 12))
                            .frame(width: 85, height: 85)
                            .padding(.trailing, 5)
                        VStack(alignment: .leading) {
                            Text("Tender")
                                .font(.system(.title, weight: .bold))
                                .lineLimit(1)
                            Text("Originally built by **leminlimez**, improved by **lunginspector**, made for **jailbreak.party.**")
                                //.font(.system(.body, weight: .bold))
                                .multilineTextAlignment(.leading)
                                //.lineLimit(2)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .listRowBackground(
                        LinearGradient(gradient: Gradient(colors: [Color(hex: "#4800FF"), Color(hex: "#FF8400"),]), startPoint: .top, endPoint: .bottom).opacity(0.3)
                    )
                    HStack {
                        Image("jailbreak.party")
                            .resizable()
                            .scaledToFit()
                            .clipShape(.rect(cornerRadius: 8))
                            .frame(width: 32, height: 32)
                            .padding(.trailing, 6)
                        Link("jailbreak.party Discord", destination: URL(string: "https://discord.gg/XPj66zZ4gT")!)
                            .fontWeight(.bold)
                    }
                } header: {
                    Label("Version \(Bundle.main.releaseVersionNumber ?? "UNKNOWN") (\(Int(buildNumber) != 0 ? "\(buildNumber)" : NSLocalizedString("Release", comment:"")))", systemImage: "info.circle.fill")
                }
                Section {
                    // app credits
                    LinkCell(imageName: "LeminLimez", url: "https://x.com/leminlimez", title: "leminlimez", contribution: NSLocalizedString("Original Developer", comment: "leminlimez's contribution"), circle: true)
                    LinkCell(imageName: "lunginspector", url: "https://x.com/lunginspector", title: "lunginspector", contribution: NSLocalizedString("Improved Nugget", comment: "lunginspector's contribution"), circle: true)
                    LinkCell(imageName: "khanhduytran", url: "https://github.com/khanhduytran0/SparseBox", title: "khanhduytran0", contribution: "SparseBox", circle: true)
                    LinkCell(imageName: "jjtech", url: "https://github.com/JJTech0130/TrollRestore", title: "JJTech0130", contribution: "SparseRestore", circle: true)
                    LinkCell(imageName: "disfordottie", url: "https://x.com/disfordottie", title: "disfordottie", contribution: "Some Global Flag Features", circle: true)
                    LinkCell(imageName: "f1shy-dev", url: "https://gist.github.com/f1shy-dev/23b4a78dc283edd30ae2b2e6429129b5#file-eligibility-plist", title: "f1shy-dev", contribution: "AI Enabler", circle: true)
                    LinkCell(imageName: "plus.circle.dashed", url: "https://sidestore.io/", title: "SideStore", contribution: "em_proxy and minimuxer", systemImage: true, circle: true)
                    LinkCell(imageName: "cable.connector", url: "https://libimobiledevice.org", title: "libimobiledevice", contribution: "Restore Library", systemImage: true, circle: true)
                } header: {
                    Label("Credits", systemImage: "star.fill")
                }
            }
        }
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
            .clipShape(.rect(cornerRadius: 8))
            .frame(width: 32, height: 32)
            
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

