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
    @State private var addEventTapped = false
    @State private var eventTapped = false
    @State private var eventDeleted = false
    var pairEventServices = PairEventServices()
    
    var sortedEvents: [PairEvent] {
        eventsViewModel.events.sorted(by: { $0.nextOccurrence < $1.nextOccurrence })
    }
    
    var body: some View {
        Group {
            if sortedEvents.isEmpty {
                ContentUnavailableView(
                    "No Events Yet",
                    systemImage: "calendar.badge.plus",
                    description: Text("Add your first event to remember it together")
                )
            } else {
                List {
                    ForEach(sortedEvents) { event in
                        Button {
                            eventTapped.toggle()
                            eventToEdit = event
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: event.isRecurring ? "repeat" : "calendar")
                                    .foregroundStyle(Color.accentColor)
                                    .frame(width: 32, height: 32)
                                    .background(Color.accentColor.opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(event.title)
                                        .font(.body.weight(.medium))
                                        .foregroundStyle(.primary)
                                    Text(event.nextOccurrence.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete{ indexSet in
                        eventDeleted.toggle()
                        for index in indexSet {
                            let event = sortedEvents[index]
                            guard let id = event.id else { continue }
                            Task {
                                try? await pairEventServices.deleteEvent(pairID: pairID, eventID: id)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))
            }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: addEventTapped)
        .sensoryFeedback(.impact(weight: .light), trigger: eventTapped)
        .sensoryFeedback(.impact(weight: .medium), trigger: eventDeleted)
        .navigationTitle("Events")
        .toolbar {
            Button("Add Event", systemImage: "plus") {
                addEventTapped.toggle()
                isShowingNewEvent = true
            }
            .tint(.pink)
        }
        .sheet(isPresented: $isShowingNewEvent) {
            NewPairEventView(
                pairID: pairID,
                currentUserID: currentUserID ?? "",
                existingEvent: nil)
            
        }
        .sheet(item: $eventToEdit) { event in
            NewPairEventView(
                pairID: pairID,
                currentUserID: currentUserID ?? "",
                existingEvent: event
            )
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

