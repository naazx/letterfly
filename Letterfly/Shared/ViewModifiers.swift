//
//  ViewModifiers.swift
//  Letterfly
//
//  Created by Nazar Dydyn on 12.09.2026.
//

import Foundation
import SwiftUI

struct PressScaleEffect: ViewModifier {
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.96 : 1)
            .animation(.easeOut(duration: 0.15), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}

extension View {
    func pressScaleEffect() -> some View {
        modifier(PressScaleEffect())
    }
}
