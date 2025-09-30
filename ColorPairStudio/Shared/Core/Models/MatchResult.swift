//
//  MatchResult.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

import Foundation
import ColorPairCore

enum MatchResult {
    case approximated(ApproximatedOutput)
    case derived(DerivedPair)
}
