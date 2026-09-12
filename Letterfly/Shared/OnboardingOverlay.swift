//
//  OnboardingOverlay.swift
//  Letterfly
//
//  Created by Nazar Dydyn on 12.09.2026.
//

import SwiftUI

struct OnboardingOverlay: ViewModifier {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var isVisible = false

    let message: String
    let isLastScreen: Bool

    func body(content: Content) -> some View {
        content
            .overlay {
                if isVisible {
                    ZStack {
                        Color.black.opacity(0.6)
                            .ignoresSafeArea()

                        VStack(spacing: 16) {
                            Text(message)
                                .font(.body)
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)

                            Button("Зрозуміло") {
                                if isLastScreen {
                                    hasSeenOnboarding = true
                                }
                                isVisible = false
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .transition(.opacity)
                }
            }
            .onAppear {
                if !hasSeenOnboarding {
                    isVisible = true
                }
            }
    }
}

extension View {
    func onboardingOverlay(message: String, isLastScreen: Bool = false) -> some View {
        modifier(OnboardingOverlay(message: message, isLastScreen: isLastScreen))
    }
}
