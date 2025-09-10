//
//  FocusedActions.swift
//  ColorPairStudio
//
//  Created by Maury Alamin on 9/10/25.
//

import Foundation
import SwiftUI

// One place only for these keys:
struct ExportActionKey: FocusedValueKey { typealias Value = () -> Void }
struct ToggleMoreRangeKey: FocusedValueKey { typealias Value = () -> Void }

extension FocusedValues {
    var exportAction: (() -> Void)? {
        get { self[ExportActionKey.self] }
        set { self[ExportActionKey.self] = newValue }
    }
    var toggleMoreRange: (() -> Void)? {
        get { self[ToggleMoreRangeKey.self] }
        set { self[ToggleMoreRangeKey.self] = newValue }
    }
}
