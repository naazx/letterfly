//
//  DayLettersView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 11.07.2026.
//

import MapKit
import SwiftUI

struct DayLettersView: View {
    var date: Date
    var letters: [Letter]
    
    var pairID: String
    var currentUserID: String?
    var homeViewModel: HomeViewModel
    var partnerName: String?
    var locationService: LocationService
    var eventsViewModel: PairEventsViewModel
    var onOpenLocationInMap: (CLLocationCoordinate2D) -> Void
    
    var body: some View {
        NavigationStack{
            List(letters){ letter in
                NavigationLink(value: letter){
                    LetterRowView(
                        letter: letter,
                        currentUserID: currentUserID,
                        photoURL: letter.photoURL
                    )
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
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
            .navigationTitle(date.formatted(.dateTime.day().month().year()))
        }
    }
}

#Preview {
    let sampleLetters: [Letter] = [
        Letter(
            authorID: "previewUser1",
            subject: "how are you?",
            text: "Hi, dear! How are you?",
            createdAt: .now
        ),
    ]
    
    DayLettersView(
        date: .now,
        letters: sampleLetters,
        pairID: "123456789",
        currentUserID: nil ,
        homeViewModel: HomeViewModel(),
        partnerName: "nastia",
        locationService: LocationService(),
        eventsViewModel: PairEventsViewModel(),
        onOpenLocationInMap: { _ in })
}
