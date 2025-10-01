//
//  ModeSegmentedControl.swift
//  ColorPairStudio
//
//  Created by Maury Alamin on 9/19/25.
//

import Foundation
import SwiftUI
import AppKit

@MainActor
struct ModeSegmentedControl: NSViewRepresentable {
    @Binding var selection: MatchMode

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeNSView(context: Context) -> NSView {
        let container = NSView()

        let control = NSSegmentedControl(
            labels: ["Approximator", "Derived Pair"],
            trackingMode: .selectOne,
            target: context.coordinator,
            action: #selector(Coordinator.changed(_:))
        )
        control.segmentDistribution = .fillEqually
        control.setSelected(true, forSegment: selection.index)

        control.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(control)
        NSLayoutConstraint.activate([
            control.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            control.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            control.topAnchor.constraint(equalTo: container.topAnchor),
            control.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        context.coordinator.control = control
        return container
    }

    func updateNSView(_ view: NSView, context: Context) {
        context.coordinator.control?.setSelected(true, forSegment: selection.index)
    }

    @MainActor
    final class Coordinator: NSObject {
        var parent: ModeSegmentedControl
        weak var control: NSSegmentedControl?
        init(_ parent: ModeSegmentedControl) { self.parent = parent }

        @objc func changed(_ sender: NSSegmentedControl) {
            parent.selection = (sender.selectedSegment == 0) ? .approximator : .derivedPair
        }
    }
}

private extension MatchMode {
    var index: Int { self == .approximator ? 0 : 1 }
}
