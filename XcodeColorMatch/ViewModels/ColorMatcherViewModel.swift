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
    @Published var mode: MatchMode = .approximator
    
    @Published var result: MatchResult? = nil
    
    // Engine dependencies (very simple placeholders for week‑3 demo)
    private let engine = ApproximatorEngine()
    
    func generate() {
        // Prefer HEX → RGB → fallback to picker
        let rgba = RGBA.fromHexString(hexText)
        ?? RGBA.fromRGBText(rgbText)
        ?? RGBA(r: 76/255, g: 111/255, b: 175/255, a: 1)
        
        switch mode {
        case .approximator:
            let approx = engine.approximate(to: rgba)
            result = .approximated(approx)
        case .derivedPair:
            let pair = DerivedPairEngine.derive(from: rgba)
            result = .derived(pair)
        }
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
}
