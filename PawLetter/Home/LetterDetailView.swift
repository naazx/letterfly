//
//  LetterDetailView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 16.07.2026.
//

import MapKit
import SwiftUI

struct LetterDetailView: View {
    @AppStorage("useHandwritingFont") var useHandwritingFont: Bool = true
    @Environment(\.dismiss) var dismiss
    @State private var showDeleteConfirmation: Bool = false
    @State private var showError: Bool = false
    @State private var isShowingEdit: Bool = false
    @State private var selectedReaction: ReactionType?
    @State private var audioRecorder = AudioRecorderService()
    @State private var hasInitializedReaction: Bool = false
    @State private var isShowingCard: Bool = false
    
    let letter: Letter
    let pairID: String
    var letterServices = LetterServices()
    var currentUserID: String?
    var partnerName: String?
    var locationService: LocationService
    var onOpenLocationInMap: (CLLocationCoordinate2D) -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                if letter.photoURL != nil {
                    photoView
                }
                
                Text(letter.subject)
                    .font(.title2.bold())
                
                moodSurpriseBadges
                
                Divider()
                
                metaInfoSection
                
                Divider()
                
                if let text = letter.text {
                    Text(text)
                        .lineSpacing(6)
                        .textSelection(.enabled)
                } else if letter.audioURL != nil {
                    voicePlayerSection
                }
                
                locationDisplaySection
                
                reactionSection
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
        .navigationTitle("Letter")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard let id = letter.id else { return }
            if !letter.isRead &&  letter.authorID != currentUserID{
                try? await letterServices.markAsRead(pairID: pairID, letterID: id)
            }
            selectedReaction = letter.reaction
            hasInitializedReaction = true
            
            if let audioURLString = letter.audioURL {
                await audioRecorder.loadRemoteRecording(from: audioURLString)
            }
        }
        .toolbar{
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Show Card", systemImage: "pencil.and.scribble") {
                        isShowingCard = true
                    }
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
                        try await letterServices.deleteLetter(pairID: pairID, letterID: id, photoURL: letter.photoURL, audioURL: letter.audioURL)
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
            NewLetterView(
                existingLetter: letter,
                pairID: pairID, authorID:
                    letter.authorID,
                locationService: locationService
            )
        }
        .sheet(isPresented: $isShowingCard) {
            LetterCardView(
                letter: letter,
                currentUserID: currentUserID,
                partnerName: partnerName
            )
        }
        .onChange(of: selectedReaction) { oldValue, newValue in
            guard hasInitializedReaction else { return }
            guard let id = letter.id else { return }
            Task {
                try? await letterServices.setReaction(pairID: pairID, letterID: id, reaction: newValue, previousReaction: oldValue)
            }
        }
    }
    
    private var moodSurpriseBadges: some View {
        Group {
            if letter.mood != nil || letter.surprise != nil {
                HStack(spacing: 10) {
                    if let mood = letter.mood {
                        HStack(spacing: 4) {
                            Text(mood.emoji)
                            Text(mood.title)
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accentColor)
                        .clipShape(Capsule())
                    }
                    if let surprise = letter.surprise {
                        HStack(spacing: 4) {
                            Text(surprise.emoji)
                            Text(surprise.title)
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }
    
    private var metaInfoSection: some View {
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
    }
    
    private var reactionSection: some View {
        Group {
            if let currentUserID {
                Divider()
                
                if letter.authorID == currentUserID {
                    if let reaction = letter.reaction {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("REACTION")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.secondary)
                            
                            HStack(spacing: 4) {
                                Text(reaction.emoji)
                                Text(reaction.title)
                            }
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.accentColor)
                            .clipShape(Capsule())
                            
                            if let formattedReactionEditedAt = letter.formattedReactionEditedAt {
                                Text("\(partnerName ?? "Partner") changed their reaction \(formattedReactionEditedAt)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            } else if let formattedReactedAt = letter.formattedReactedAt {
                                Text("\(partnerName ?? "Partner") reacted \(formattedReactedAt)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("YOUR REACTION")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                        
                        ChipPicker<ReactionType>(selection: $selectedReaction, options: ReactionType.allCases)
                    }
                }
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
                    PawLoadingView()
                }

            } else {
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 280)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
    }
    private var voicePlayerSection: some View {
        HStack(spacing: 16) {
            Button {
                audioRecorder.isPlaying ? audioRecorder.stopPlayback() : audioRecorder.startPlayback()
            } label: {
                Image(systemName: audioRecorder.isPlaying ? "pause.fill" : "play.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .padding(14)
                    .background(Color.accentColor)
                    .clipShape(Circle())
            }
            
            Text(audioRecorder.formattedDuration)
                .font(.headline.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }
    private var locationDisplaySection: some View {
        Group {
            if let location = letter.location {
                Divider()
                let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                
                VStack(alignment: .leading, spacing: 8) {
                    Map(position: .constant(.region(
                        MKCoordinateRegion(center: coordinate, latitudinalMeters: 1500, longitudinalMeters: 1500)
                    ))) {
                        Marker("", coordinate: coordinate)
                            .tint(Color.accentColor)
                    }
                    .allowsHitTesting(false)
                    .frame(height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .contentShape(RoundedRectangle(cornerRadius: 16))
                    .onTapGesture {
                        onOpenLocationInMap(coordinate)
                    }
                    
                    if let placeName = location.placeName {
                        Label(placeName, systemImage: "mappin")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
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
            pairID: "qJ23Kdi6EMFLYmtnWgiD",
            locationService: LocationService(),
            onOpenLocationInMap: { _ in }
        )
    }
}
