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
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle("Letter details")
        .task {
            guard let id = letter.id else { return }
            if !letter.isRead {
                try? await letterServices.markAsRead(pairID: pairID, letterID: id)
            }
        }
        .toolbar{
            ToolbarItem(placement: .topBarTrailing) {
                Button("Delete", systemImage: "trash"){
                    showDeleteConfirmation = true
                }
                .tint(.red)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit", systemImage: "pencil"){
                    isShowingEdit = true
                }
                .tint(.orange)
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
