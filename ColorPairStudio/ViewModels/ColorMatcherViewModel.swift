//
//  ColorMatcherViewModel.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

import Foundation
import SwiftUI

final class ColorMatcherViewModel: ObservableObject {
    @Published var hexText: String = "#4C6FAF"
    @Published var rgbText: String = "76,111,175"
    @Published var pickedColor: Color = Color(red: 76/255, green: 111/255, blue: 175/255)
    @Published var bias: Double = 0.0
    @Published var input: RGBA = RGBA(r: 76/255, g: 111/255, b: 175/255, a: 1) {
        didSet {
            guard !isSyncing else { return }
            let newHex = input.hexString
            let newRGB = input.asRGBText
            if hexText != newHex { hexText = newHex }
            if rgbText != newRGB { rgbText = newRGB }
        }
    }
    @Published var mode: MatchMode = .approximator
    
    private var isSyncing = false
    
    @Published var result: MatchResult? = nil
    
    // Engine dependencies (very simple placeholders for week‑3 demo)
    private let engine = ApproximatorEngine()
    
    
    
    func generate() {
        let rgba = RGBA.fromHexString(hexText)
        ?? RGBA.fromRGBText(rgbText)
        ?? RGBA(r: 76/255, g: 111/255, b: 175/255, a: 1)
        
        let props: [String: Any]
        
        switch mode {
        case .approximator:
            let approx = engine.approximate(to: rgba)
            result = .approximated(approx)
            props = ["mode": mode.rawValue, "feature": "Approximator"]
            
        case .derivedPair:
            let pair = DerivedPairEngine.derive(from: rgba, bias: bias)
            result = .derived(pair)
            let roundedBias = (bias * 100).rounded() / 100   // optional nicety for logs
            props = ["mode": mode.rawValue, "feature": "DerivedPair", "bias": roundedBias]
        }
        
        Analytics.track("generate_clicked", props)
    }
    
    func exportSnippet() -> String {
        guard let result else { return "// Generate first" }
        switch result {
        case .approximated(let out):
            return Exporter.approximatorSnippet(output: out)
        case .derived(let pair):
            return Exporter.derivedPairSnippet(name: "BrandPrimary", pair: pair)
        }
    }
    
    func syncFromHex() {
        guard !isSyncing, let c = RGBA.fromHexString(hexText) else { return }
        isSyncing = true
        input = c
        //rgbText = c.asRGBText
        isSyncing = false
    }
    func syncFromRGB() {
        guard !isSyncing, let c = RGBA.fromRGBText(rgbText) else { return }
        isSyncing = true
        input = c
        //hexText = c.hexString
        isSyncing = false
    }
    func syncFromPicker() {
        guard !isSyncing else { return }
        // read NSColor from Color if you want exact; for demo, reuse input
        // or keep 'pickedColor' only as a visual and rely on HEX/RGB fields.
    }
    
}
