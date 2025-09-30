//
//  PreferencesView.swift
//  XcodeColorMatch
//
//  Created by Maury Alamin on 8/29/25.
//

// PreferencesView.swift
import SwiftUI

struct PreferencesView: View {
    // Updated the look of the panel to make it look better and more hopeful messing around
    @AppStorage(Analytics.optInKey) private var analyticsOptIn = false

    var body: some View {
        Form {
            Section("Privacy") {
                Toggle("Share anonymous usage analytics", isOn: $analyticsOptIn)
                            .toggleStyle(.switch)
                Text("Off by default. No personal data, no\ridentifiers, and no color values are sent.")
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
