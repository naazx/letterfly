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
                        Image(systemName: letter.authorID == currentUserID ? "paperplane.fill" : "envelope.fill")
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading) {
                    Text(letter.subject)
                        .fontWeight(letter.isRead ? .regular : .bold)
                    Text(letter.text)
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
                        Text(letter.formattedDate)
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }
            }
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
