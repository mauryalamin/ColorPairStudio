//
//  ApproximatorEngineTests.swift
//  ColorPairCore
//
//  Created by Maury Alamin on 9/30/25.
//

import Testing
import Foundation
@testable import ColorPairCore

struct ApproximatorEngineTests {
    @Test
    func nearestToken_matchesExactBlueApprox() {
        let target = SystemColorToken.blue.rgbaApprox
        let out = ApproximatorEngine().approximate(to: target)
        #expect(out.base == .blue)
    }

    @Test
    func nearestToken_isStableNearIndigo() {
        // Slightly perturbed indigo; still should choose .indigo
        var t = SystemColorToken.indigo.rgbaApprox
        t = t.adjust(brightness: 0.01)
        let out = ApproximatorEngine().approximate(to: t)
        #expect(out.base == .indigo)
    }
}
