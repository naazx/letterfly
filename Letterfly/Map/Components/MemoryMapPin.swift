//
//  MemoryMapPin.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 14.08.2026.
//

import SwiftUI

struct MemoryMapPin: View {
    let isSelected: Bool
    let mood: MoodType?
    let surprise: SurpriseType?
    let appearDelay: Double
    
    @State private var hasAppeared = false

    var body: some View {
        VStack(spacing: 0) {
            if let surprise {
                Text(surprise.emoji)
                    .font(.system(size: 16))
                    .offset(y: 4)
            }

            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(
                        width: isSelected ? 52 : 44,
                        height: isSelected ? 52 : 44
                    )
                    .shadow(
                        color: .black.opacity(0.15),
                        radius: 4, x: 0, y: 2
                    )
                    .overlay {
                        if isSelected {
                            Circle()
                                .stroke(Color.accentColor, lineWidth: 4)
                        }
                    }
                    .animation(
                        .easeInOut(duration: 0.3),
                        value: isSelected
                    )

                if let mood {
                    Text(mood.emoji)
                        .font(.system(size: 18))
                } else {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.accentColor)
                }
            }
        }
        .scaleEffect(hasAppeared ? 1 : 0.3)
                .opacity(hasAppeared ? 1 : 0)
                .onAppear {
                    guard !hasAppeared else { return }
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.65).delay(appearDelay)) {
                        hasAppeared = true
                    }
                }
    }
}

#Preview {
    VStack(spacing: 20) {
        MemoryMapPin(isSelected: false, mood: nil, surprise: nil, appearDelay: 0)
        MemoryMapPin(isSelected: false, mood: .love, surprise: nil, appearDelay: 0.1)
        MemoryMapPin(isSelected: false, mood: nil, surprise: .flower, appearDelay: 0.2)
        MemoryMapPin(isSelected: true, mood: .happy, surprise: .chocolate, appearDelay: 0.3)
    }
}
