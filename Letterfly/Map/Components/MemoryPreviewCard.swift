//
//  MemoryPreviewCard.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 14.08.2026.
//

import Kingfisher
import SwiftUI

struct MemoryPreviewCard: View {
    @State private var openTapped = false
    let letter: Letter
    let onOpen: () -> Void

    var formattedDate: String {
        letter.createdAt.formatted(
            .dateTime
                .month(.abbreviated)
                .day()
                .year()
        )
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let photoURL = letter.photoURL, let url = URL(string: photoURL) {
                KFImage(url)
                    .placeholder {
                        Color.gray.opacity(0.2)
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                ZStack {
                    Circle()
                        .stroke(Color.accentColor, lineWidth: 4)
                    Image(systemName: "envelope.fill")
                        .foregroundStyle(Color.accentColor)
                }
                .frame(width: 44, height: 44)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(letter.subject)
                    .font(.subheadline.bold())
                    .lineLimit(1)

                Text(formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 6) {
                    if let mood = letter.mood {
                        Text(mood.emoji)
                            .font(.caption2)
                    }
                    if letter.audioURL != nil {
                        Image(systemName: "waveform")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Button {
                onOpen()
                openTapped.toggle()
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: openTapped)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
#Preview {
    MemoryPreviewCard(letter: Letter(authorID: "1234", subject: "nastia", createdAt: .now), onOpen: {})
}
