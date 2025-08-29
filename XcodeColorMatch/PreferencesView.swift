//
//  PreferencesView.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/29/25.
//

// PreferencesView.swift
import SwiftUI

struct PreferencesView: View {
    @AppStorage("analytics_opt_in") private var analytics = false

    var body: some View {
        Form {
            Section("Privacy") {
                Toggle("Share anonymous usage counts to improve the app", isOn: $analytics)
                Text("Off by default. No personal data, no identifiers, and no color values are sent.")
                    .font(.footnote).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .frame(width: 460)
    }
}

#Preview {
    PreferencesView()
}
