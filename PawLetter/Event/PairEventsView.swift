//
//  PairEventsView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 19.08.2026.
//

import SwiftUI

struct PairEventsView: View {
    var eventsViewModel: PairEventsViewModel
    var pairID: String
    var currentUserID: String?
    
    @State private var isShowingNewEvent = false
    @State private var eventToEdit: PairEvent?
    var pairEventServices = PairEventServices()
    
    var sortedEvents: [PairEvent] {
        eventsViewModel.events.sorted(by: { $0.nextOccurrence < $1.nextOccurrence })
    }
    
    var body: some View {
        List {
            ForEach(sortedEvents) { event in
                HStack(spacing: 12) {
                    Image(systemName: event.isRecurring ? "repeat" : "calendar")
                        .foregroundStyle(Color.accentColor)
                        .frame(width: 32, height: 32)
                        .background(Color.accentColor.opacity(0.15))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.title)
                            .font(.body.weight(.medium))
                        Text(event.nextOccurrence.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 4)
                .onTapGesture {
                    eventToEdit = event
                }
            }
            .onDelete{ indexSet in
                for index in indexSet {
                    let event = sortedEvents[index]
                    guard let id = event.id else { continue }
                    Task {
                        try? await pairEventServices.deleteEvent(pairID: pairID, eventID: id)
                    }
                }
            }
        }
        .navigationTitle("Events")
        .toolbar {
            Button("Add Event", systemImage: "plus") {
                isShowingNewEvent = true
            }
        }
    }
}

#Preview {
    PairEventsView(
        eventsViewModel: PairEventsViewModel(),
        pairID: "123456789",
        currentUserID: "naatia 67"
    )
}
