//
//  PawLoadingView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 27.07.2026.
//

import SwiftUI

struct PawLoadingView: View {
    @State private var isAnimating = false

    var body: some View {
        Image(systemName: "pawprint.fill")
            .font(.system(size: 36))
            .foregroundStyle(.accent)
            .scaleEffect(isAnimating ? 1.15 : 0.9)
            .opacity(isAnimating ? 1 : 0.6)
            .animation(
                .easeInOut(duration: 0.8)
                .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

#Preview {
    PawLoadingView()
}
