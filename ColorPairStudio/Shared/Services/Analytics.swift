//
//  Analytics.swift
//  ColorPairStudio
//
//  Created by Maury Alamin on 9/17/25.
//

// Utilities/Analytics.swift
import Foundation

enum Analytics {
    /// Single source of truth for the opt-in key (used by @AppStorage and here)
    static let optInKey = "analytics_opt_in"

    static var enabled: Bool {
        UserDefaults.standard.bool(forKey: optInKey)
    }

    /// v0.1: local-only stub. Safe to call anywhere.
    static func track(_ event: String, _ props: [String: Any] = [:]) {
        guard enabled else { return }
        #if DEBUG
        print("ANALYTICS:", event, props)   // keep it simple for 0.1
        #endif
        // Later: write to a small ring buffer or swap to a real provider.
    }
}
