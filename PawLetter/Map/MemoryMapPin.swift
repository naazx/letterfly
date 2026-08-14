//
//  MemoryMapPin.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 14.08.2026.
//

import SwiftUI

struct MemoryMapPin: View {
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(
                    width: isSelected ?  52 : 44,
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
            
            Image(systemName: "envelope.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.accentColor)
        }
    }
}

#Preview {
    MemoryMapPin(isSelected: false)
}
