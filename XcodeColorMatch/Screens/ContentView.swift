//
//  ContentView.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = ColorMatcherViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            inputRow
            modeRow
            Button("Generate", action: vm.generate)
                .keyboardShortcut(.return)
            
            Divider()
            resultsSection
            Spacer()
        }
        .padding(20)
        .frame(minWidth: 820, minHeight: 560)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("Toggle Light/Dark Preview") {
                    togglePreviewAppearance()
                }
                .keyboardShortcut("l", modifiers: [.command]) // ⌘L
            }
        }
        
    }
    
    private func togglePreviewAppearance() {
        if NSApp.appearance?.name == .aqua {
            NSApp.appearance = NSAppearance(named: .darkAqua)
        } else {
            NSApp.appearance = NSAppearance(named: .aqua)
        }
    }
    
    private var header: some View {
        HStack {
            Text("Custom → Native Color Matcher")
                .font(.title2).bold()
            Spacer()
        }
    }
    
    private var inputRow: some View {
        HStack(alignment: .center, spacing: 12) {
            ColorWellView(rgba: $vm.input)
                .frame(width: 120, height: 36)
            
            VStack(alignment: .leading) {
                HStack {
                    Text("HEX:")
                    TextField("#RRGGBB", text: $vm.hexText)
                        .onChange(of: vm.hexText) { vm.syncFromHex() }

                    // TextField("#RRGGBB", text: $vm.hexText)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                        .frame(width: 140)
                }
                HStack {
                    Text("RGB:")
                    TextField("r,g,b", text: $vm.rgbText)
                        .onChange(of: vm.rgbText) { vm.syncFromRGB() }

                    // TextField("r,g,b", text: $vm.rgbText)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                        .frame(width: 140)
                }
                Text("Paste HEX (#RRGGBB) or RGB (r,g,b)")
                    .foregroundStyle(.secondary)
                    .font(.footnote)
            }
            Spacer()
        }
    }
    
    private var modeRow: some View {
        HStack(spacing: 16) {
            Picker("Mode", selection: $vm.mode) {
                ForEach(MatchMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            Group {
                if vm.mode == .approximator {
                    Text("System base + tiny nudges (component fill only)")
                        .foregroundStyle(.secondary)
                } else {
                    Text("Creates Light/Dark twins saved as a named color asset")
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    private var resultsSection: some View {
        switch vm.result {
        case .none:
            EmptyState()
        case .some(.approximated(let out)):
            ApproximatorResultView(output: out, export: vm.exportSnippet)
        case .some(.derived(let pair)):
            DerivedPairResultView(pair: pair, export: vm.exportSnippet)
        }
    }
}

#Preview {
    ContentView()
}
