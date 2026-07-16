//
//  LetterDetailView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 16.07.2026.
//

import SwiftUI

struct LetterDetailView: View {
    let letter: Letter
    let pairID: String
    var letterServices = LetterServices()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if letter.photoURL != nil {
                    photoView
                        .padding(.bottom, 8)
                }

                Label(
                    letter.createdAt.formatted(date: .long, time: .omitted),
                    systemImage: "calendar"
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Subject")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(letter.subject)
                        .font(.headline)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Description")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(letter.text)
                }
            }
            .padding()
        }
        .navigationTitle("Letter details")
        .task {
            guard let id = letter.id else { return }
            if !letter.isRead {
                try? await letterServices.markAsRead(pairID: pairID, letterID: id)
            }
        }
    }
    private var photoView: some View {
        Group {
            if let photoURL = letter.photoURL,
               let url = URL(string: photoURL) {

                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }

            } else {
                ContentUnavailableView(
                    "No Photo",
                    systemImage: "photo"
                )
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 250)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    NavigationStack {
        LetterDetailView(
            letter: Letter(
                authorID: "3z34vv",
                subject: "Test subject",
                text: "This is a test letter to preview how the detail view looks.",
                createdAt: .now,
                photoURL: nil,
                isRead: false
            ),
            pairID: "qJ23Kdi6EMFLYmtnWgiD"
        )
    }
}
