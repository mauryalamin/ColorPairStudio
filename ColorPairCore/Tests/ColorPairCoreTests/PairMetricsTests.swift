//
//  File.swift
//  ColorPairCore
//
//  Created by Maury Alamin on 9/30/25.
//

import Testing
import Foundation
@testable import ColorPairCore

struct PairMetricsTests {
    @Test
    func metrics_bothPass_summary() {
        let t = RGBA(r: 0.30, g: 0.50, b: 0.70, a: 1)
        let p = DerivedPairEngine.derive(from: t, policy: .guardrailed)
        let m = DerivedPairEngine.metrics(for: p)
        #expect(m.overallPass)
        #expect(m.overallSummary == "Both PASS")
    }

    @Test
    func metrics_reportsFirstFailingReason() {
        // Construct a pair that will fail dark text first
        let pair = DerivedPair(
            target: RGBA(r: 0.3, g: 0.5, b: 0.7, a: 1),
            light:  RGBA.white,                       // white (text on white fails)
            dark:   RGBA(r: 0.5, g: 0.5, b: 0.5, a: 1), // mid-gray (white text may still fail AA)
            wcagPass: false
        )
        let m = DerivedPairEngine.metrics(for: pair)
        #expect(!m.overallPass)
        #expect(m.overallSummary.hasPrefix("Both FAIL —")) // Don’t assert the exact numeric
    }
}
