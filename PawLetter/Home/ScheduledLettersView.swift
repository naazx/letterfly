//
//  ScheduledLettersView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 20.08.2026.
//

import MapKit
import SwiftUI

struct ScheduledLettersView: View {
    var letters: [Letter]
    var pairID: String
    var currentUserID: String?
    var partnerName: String?
    var locationService: LocationService
    var eventsViewModel: PairEventsViewModel
    var onOpenLocationInMap: (CLLocationCoordinate2D) -> Void

    private var sortedLetters: [Letter] {
        letters.sorted {
            ($0.unlockDate ?? .distantFuture) < ($1.unlockDate ?? .distantFuture)
        }
    }

    var body: some View {
        Group {
            if letters.isEmpty {
                ContentUnavailableView(
                    "No Scheduled Letters",
                    systemImage: "lock",
                    description: Text("Letters you schedule for later will appear here")
                )
            } else {
                List {
                    ForEach(sortedLetters) { letter in
                        NavigationLink(value: letter) {
                            row(for: letter)
                        }
                    }
                }
            }
        }
        .navigationTitle("Scheduled")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Letter.self) { letter in
            LetterDetailView(
                letter: letter,
                pairID: pairID,
                currentUserID: currentUserID,
                partnerName: partnerName,
                locationService: locationService,
                eventsViewModel: eventsViewModel,
                onOpenLocationInMap: onOpenLocationInMap
            )
        }
    }

    private func row(for letter: Letter) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .foregroundStyle(Color.accentColor)
                .frame(width: 32, height: 32)
                .background(Color.accentColor.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text("Locked Letter")
                    .font(.body.weight(.medium))

                if let unlockDate = letter.unlockDate {
                    Text("Unlocks \(unlockDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        ScheduledLettersView(
            letters: [
                Letter(
                    authorID: "previewUser1",
                    subject: "Happy Anniversary",
                    text: "Can't wait for you to read this!",
                    createdAt: .now,
                    unlockDate: Calendar.current.date(byAdding: .day, value: 10, to: .now)
                )
            ],
            pairID: "123456789",
            currentUserID: "previewUser2",
            partnerName: "nastia",
            locationService: LocationService(),
            eventsViewModel: PairEventsViewModel(),
            onOpenLocationInMap: { _ in }
        )
    }
}
