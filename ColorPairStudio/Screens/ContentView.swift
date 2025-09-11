//
//  ContentView.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

import SwiftUI

enum UI {
    static let row: CGFloat = 24; static let col: CGFloat = 24
}

struct ContentView: View {
    @StateObject private var vm = ColorMatcherViewModel()
    
    private struct ExportPayload: Identifiable {
        let id = UUID()
        let snippet: String
    }
    @State private var exportPayload: ExportPayload?
    
    private func presentExport(_ snippet: String) {
        exportPayload = ExportPayload(snippet: snippet)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            header
            inputRow
            modeRow
            Button("Generate", action: vm.generate)
                .keyboardShortcut(.return)
                .accessibilityLabel("Generate results")

            Divider()
            resultsSection
            Spacer()
        }
        .padding(20)
        .frame(minWidth: 820, minHeight: 640)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("Toggle Light/Dark Preview") { togglePreviewAppearance() }
                    .keyboardShortcut("l", modifiers: [.command])
                    .accessibilityLabel("Toggle Light or Dark preview")
                    .accessibilityHint("Switches the app window appearance for preview only")
            }
        }
        .sheet(item: $exportPayload) { payload in
            ExportSheet(snippet: payload.snippet)
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
        HStack(alignment: .top, spacing: 24) {
            ColorWellView(rgba: $vm.input)
                .frame(width: 120, height: 60)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(.quaternary))
                .accessibilityHidden(true)

            VStack(alignment: .leading) {
                HStack {
                    Text("HEX:")
                    TextField("#RRGGBB", text: $vm.hexText)
                        .onChange(of: vm.hexText) { vm.syncFromHex() }
                        .controlSize(.large)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                        .frame(width: 140)
                }
                HStack {
                    Text("RGB:")
                    TextField("r,g,b", text: $vm.rgbText)
                        .onChange(of: vm.rgbText) { vm.syncFromRGB() }
                        .controlSize(.large)
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
        VStack(alignment: .leading ,spacing: 8) {
            Picker("Mode", selection: $vm.mode) {
                Text("Approximator").tag(MatchMode.approximator)
                Text("Derived Pair").tag(MatchMode.derivedPair)
            }
            .pickerStyle(.segmented)
            .accessibilityLabel("Mode")
            .accessibilityValue(vm.mode == .approximator ? "Approximator" : "Derived Pair")
            .accessibilityHint(vm.mode.helpText)

            ModeHelp(text: vm.mode.helpText)
                .transition(.opacity.combined(with: .move(edge: .top)))
                .animation(.easeInOut(duration: 0.2), value: vm.mode)
                .padding(.top, 4)
        }
        .frame(maxWidth: 600)
    }
    

    @ViewBuilder
    private var resultsSection: some View {
        switch vm.result {
        case .none:
            EmptyState()
                .focusedSceneValue(\.exportAction, nil)

        case .some(.approximated(let out)):
            ApproximatorResultView(output: out, onExport: presentExport)

        case .some(.derived(let pair)):
            DerivedPairResultView(pair: pair, onExport: presentExport)
        }
    }
}

#Preview {
    ContentView()
}
