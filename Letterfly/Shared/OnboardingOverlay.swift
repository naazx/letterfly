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
    let systemImage: String
    let isLastScreen: Bool

    func body(content: Content) -> some View {
        content
            .overlay {
                if isVisible {
                    ZStack(alignment: .bottom) {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture { dismiss() }

                        VStack(spacing: 16) {
                            HStack(alignment: .top, spacing: 14) {
                                Image(systemName: systemImage)
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(.pink)
                                    .padding(10)
                                    .background(Color.pink.opacity(0.12), in: Circle())

                                Text(message)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineSpacing(2)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            Button {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                dismiss()
                            } label: {
                                Text("Got it")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.pink, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                        }
                        .padding(18)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(.ultraThickMaterial)
                                .shadow(color: .black.opacity(0.18), radius: 24, y: 10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .zIndex(999)
                }
            }
            .onAppear {
                if !hasSeenOnboarding {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                        isVisible = true
                    }
                }
            }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.22)) {
            isVisible = false
        }
        if isLastScreen {
            hasSeenOnboarding = true
        }
    }
}

extension View {
    func onboardingOverlay(message: String, systemImage: String, isLastScreen: Bool = false) -> some View {
        modifier(OnboardingOverlay(message: message, systemImage: systemImage, isLastScreen: isLastScreen))
    }
}
