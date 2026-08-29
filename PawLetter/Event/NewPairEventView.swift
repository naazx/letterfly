//
//  NewPairEventView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 19.08.2026.
//

import SwiftUI

struct NewPairEventView: View {
    @Environment(\.dismiss) var dismiss
    var pairID: String
    var currentUserID: String
    var existingEvent: PairEvent?
    
    @State private var title: String = ""
    @State private var date: Date = .now
    @State private var isRecurring: Bool = false
    @State private var eventSaved = false
    @State private var eventCancelled = false
    var pairEventServices = PairEventServices()
    
    init(pairID: String, currentUserID: String, existingEvent: PairEvent?) {
        self.pairID = pairID
        self.currentUserID = currentUserID
        self.existingEvent = existingEvent
        self._title = State(initialValue: existingEvent?.title ?? "")
        self._date = State(initialValue: existingEvent?.date ?? .now)
        self._isRecurring = State(initialValue: existingEvent?.isRecurring ?? false)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                DatePicker("Date", selection: $date, displayedComponents: .date)
                Toggle("Repeats every year", isOn: $isRecurring)
            }
            .navigationTitle(existingEvent == nil ? "New Event" : "Edit Event")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        eventCancelled.toggle()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        eventSaved.toggle()
                        Task {
                            let normalizedDate = Calendar.current.startOfDay(for: date)
                            if let existingEvent, let id = existingEvent.id {
                                try? await pairEventServices.updateEvent(pairID: pairID, eventID: id, title: title, date: normalizedDate, isRecurring: isRecurring)
                            } else {
                                let reference = pairEventServices.newEventReference(pairID: pairID)
                                try? await pairEventServices.createEvent(reference: reference, title: title, date: normalizedDate, isRecurring: isRecurring, createdBy: currentUserID)
                            }
                            dismiss()
                        }
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: eventSaved)
        .sensoryFeedback(.impact(weight: .light), trigger: eventCancelled)
    }
}

#Preview {
    NewPairEventView(
        pairID: "123456789",
        currentUserID: "previewUser",
        existingEvent: nil
    )
}

#Preview("Edit") {
    NewPairEventView(
        pairID: "123456789",
        currentUserID: "previewUser",
        existingEvent: PairEvent(
            title: "Anniversary",
            date: .now,
            isRecurring: true,
            createdBy: "previewUser"
        )
    )
}
