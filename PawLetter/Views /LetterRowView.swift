//
//  LetterRowView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 19.07.2026.
//

import SwiftUI

struct LetterRowView: View {
    let letter: Letter
    let currentUserID: String?
    let loadedImage: UIImage?
    
    var body: some View {
            HStack {
                Group {
                    if let image = loadedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        placeholderView
                    }
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading) {
                    Text(letter.subject)
                        .fontWeight((!letter.isRead && letter.authorID != currentUserID) ? .bold : .regular)

                    Text(letter.text ?? "🎤 Voice Message")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    if letter.authorID == currentUserID {
                        Text("You")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    HStack(spacing: 2) {
                        if letter.editedAt != nil {
                            Image(systemName: "pencil")
                                .font(.caption2)
                        }
                        Text(displayDate)
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 6)
    }
    private var placeholderView: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.accentColor.opacity(0.2))
            .frame(width: 60, height: 60)
            .overlay {
                Text(letterPlaceholder)
                    .font(.title.weight(.bold))
                    .foregroundStyle(.accent)
            }
    }

    private var letterPlaceholder: String {
        let trimmed = letter.subject.trimmingCharacters(in: .whitespacesAndNewlines)

        return trimmed.first.map {
            String($0).uppercased()
        } ?? "✉️"
    }

    private var displayDate: String {
        if let unlockDate = letter.unlockDate, unlockDate > .now {
            return "Unlocks \(unlockDate.formatted(date: .abbreviated, time: .omitted))"
        }
        return letter.formattedDate
    }
}

#Preview {
    LetterRowView( letter: Letter(
        authorID: "3z34vv",
        subject: "Test subject",
        text: "This is a test letter to preview how the detail view looks.",
        createdAt: .now,
        photoURL: nil,
        isRead: false
    ),
                   currentUserID: nil,
                   loadedImage: nil)
}
