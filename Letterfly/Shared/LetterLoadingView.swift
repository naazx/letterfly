//
//  PawLoadingView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 27.07.2026.
//

import SwiftUI

struct LetterLoadingView: View {
    @State private var isFloating = false
    @State private var isRotating = false

    var body: some View {
        Image(systemName: "envelope.fill")
            .font(.system(size: 36))
            .foregroundStyle(.accent)
            .shadow(color: .accentColor.opacity(0.35), radius: isFloating ? 12 : 4, y: isFloating ? 8 : 2)
            .offset(y: isFloating ? -8 : 8)
            .rotationEffect(.degrees(isRotating ? 4 : -4))
            .animation(
                .easeInOut(duration: 1.4)
                .repeatForever(autoreverses: true),
                value: isFloating
            )
            .animation(
                .easeInOut(duration: 1.8)
                .repeatForever(autoreverses: true),
                value: isRotating
            )
            .onAppear {
                isFloating = true
                isRotating = true
            }
    }
}

#Preview {
    LetterLoadingView()
}
