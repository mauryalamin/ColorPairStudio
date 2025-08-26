//
//  MatchMode.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/26/25.
//

import Foundation


enum MatchMode: String, CaseIterable, Identifiable {
    case approximator = "Approximator"
    case derivedPair = "Derived Pair"
    var id: String { rawValue }
}
