//
//  LetterDetailView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 16.07.2026.
//

import SwiftUI

struct LetterDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showDeleteConfirmation: Bool = false
    @State private var showError: Bool = false
    @State private var isShowingEdit: Bool = false
    let letter: Letter
    let pairID: String
    var letterServices = LetterServices()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                if letter.photoURL != nil {
                    photoView
                }

                Text(letter.subject)
                    .font(.largeTitle.bold())

                Divider()

                VStack(alignment: .leading, spacing: 8) {

                    Label(
                        letter.createdAt.formatted(date: .long, time: .omitted),
                        systemImage: "calendar"
                    )

                    if let formattedEditedDate = letter.formattedEditedDate {
                        Label(
                            "Edited \(formattedEditedDate)",
                            systemImage: "pencil"
                        )
                    }

                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Divider()

                Text(letter.text)
                    .font(.body)
                    .lineSpacing(6)
                    .textSelection(.enabled)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
        .navigationTitle("Letter")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard let id = letter.id else { return }
            if !letter.isRead {
                try? await letterServices.markAsRead(pairID: pairID, letterID: id)
            }
        }
        .toolbar{
            ToolbarItem(placement: .topBarTrailing) {
                Menu {

                    Button("Edit", systemImage: "pencil") {
                        isShowingEdit = true
                    }

                    Button("Delete", systemImage: "trash", role: .destructive) {
                        showDeleteConfirmation = true
                    }

                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .confirmationDialog("Options", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                guard let id = letter.id else { return }
                Task {
                    do{
                        try await letterServices.deleteLetter(pairID: pairID, letterID: id, photoURL: letter.photoURL)
                        dismiss()
                    }catch{
                        showError = true
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Your letter was not deleted", isPresented: $showError) {
            Button("Ok") {}
        } message:{
            Text("Something went wrong")
        }
        .sheet(isPresented: $isShowingEdit) {
            NewLetterView(existingLetter: letter, pairID: pairID, authorID: letter.authorID)
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
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 280)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
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
