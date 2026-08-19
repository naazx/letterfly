//
//  CalendarView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 10.07.2026.
//


import MapKit
import SwiftUI

struct CalendarView: View {
    @State private var viewModel = CalendarViewModel()
    @State private var eventsViewModel = PairEventsViewModel()
    @State private var isShowingDayDetail: Bool = false
    
    
    var letters: [Letter]
    var pairID: String
    var currentUserID: String?
    var partnerName: String?
    var homeViewModel: HomeViewModel
    var locationService: LocationService
    var onOpenLocationInMap: (CLLocationCoordinate2D) -> Void
    
    private var currentMonth: Date {
        CalendarGridHelper.firstDayOfMonth(containing: .now)
    }
    
    private var months: [Date] {
        let calendar = Calendar.current
        let defaultPastBound = calendar.date(byAdding: .month, value: -12, to: currentMonth)!
        let earliestLetterMonth = letters.map(\.createdAt).min().map {
            CalendarGridHelper.firstDayOfMonth(containing: $0)
        }
        
        let pastBound = [defaultPastBound, earliestLetterMonth].compactMap { $0 }.min()!
        let futureBound = calendar.date(byAdding: .month, value: 12, to: currentMonth)!
        
        var result: [Date] = []
        var cursor = pastBound
        while cursor <= futureBound {
            result.append(cursor)
            guard let next = calendar.date(byAdding: .month, value: 1, to: cursor) else { break }
            cursor = next
        }
        return result
    }
    
    private var nearestEvent: PairEvent? {
        eventsViewModel.events.min(by: { $0.nextOccurrence < $1.nextOccurrence })
    }
    
    private var daysUntil: Int? {
        guard let nearestEvent else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: nearestEvent.nextOccurrence).day
    }
    
    var body: some View {
        let grouped = viewModel.groupedLetters(letters)
        
        NavigationStack {
            ScrollViewReader{ proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                            NavigationLink {
                                PairEventsView(
                                    eventsViewModel: eventsViewModel,
                                    pairID: pairID,
                                    currentUserID: currentUserID
                                )
                            } label: {
                            if let nearestEvent, let daysUntil {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(nearestEvent.title)
                                            .font(.subheadline.weight(.semibold))
                                        Text(daysUntil == 0 ? "Today" : "In \(daysUntil) day\(daysUntil == 1 ? "" : "s")")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.secondary)
                                }
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .padding(.horizontal)
                                .padding(.bottom, 12)
                            } else {
                                HStack {
                                    Image(systemName: "calendar.badge.plus")
                                    Text("Add your first event")
                                    Spacer()
                                }
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .padding(.horizontal)
                                .padding(.bottom, 12)
                            }
                        }
                        
                        ForEach(months, id: \.self) { month in
                            VStack(alignment: .leading, spacing: 8) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(month.formatted(.dateTime.month(.wide)))
                                        .font(.title2.bold())

                                    Text(month.formatted(.dateTime.year()))
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                                    ForEach(CalendarGridHelper.weekdaySymbols, id: \.self) { symbol in
                                        Text(symbol)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                                    let leading = CalendarGridHelper.leadingEmptyDays(for: month)
                                    let totalDays = CalendarGridHelper.numberOfDays(in: month)
                                    
                                    ForEach(0..<(leading + totalDays), id: \.self) { index in
                                        if index < leading {
                                            Color.clear
                                                .frame(height: 40)
                                        } else {
                                            let day = index - leading + 1
                                            let dayDate = Calendar.current.date(byAdding: .day, value: day - 1, to: month)!
                                            let dayKey = Calendar.current.startOfDay(for: dayDate)
                                            let dayLetters = grouped[dayKey] ?? []
                                            let hasContent = !dayLetters.isEmpty
                                            
                                            let isToday = Calendar.current.isDateInToday(dayDate)
                                            
                                            VStack {
                                                Text("\(day)")
                                                    .font(.headline)
                                                    .foregroundStyle(isToday ? .white : .primary)
                                                    .frame(width: 32, height: 32)
                                                    .background {
                                                        if isToday {
                                                            Circle().fill(Color.accentColor)
                                                        }
                                                    }
                                                    .overlay(alignment: .bottomTrailing) {
                                                        if hasContent {
                                                            Text(dayLetters.count > 9 ? "9+" : "\(dayLetters.count)")
                                                                .font(.system(size: 8, weight: .bold))
                                                                .foregroundStyle(.white)
                                                                .frame(minWidth: 13, minHeight: 13)
                                                                .padding(1)
                                                                .background(Color.accentColor)
                                                                .clipShape(Capsule())
                                                                .offset(x: 4, y: 4)
                                                        }
                                                    }
                                            }
                                            .frame(height: 40)
                                            .onTapGesture {
                                                guard hasContent else { return }
                                                
                                                withAnimation(.snappy) {
                                                        viewModel.selectedDate = dayKey
                                                    }
                                                isShowingDayDetail = true
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.bottom, 24)
                        }
                    }
                }
                .navigationTitle("Calendar")
                .onAppear {
                    DispatchQueue.main.async {
                        withAnimation(.snappy(duration: 0.5)){
                            proxy.scrollTo(currentMonth, anchor: .center)
                        }
                    }
                    
                    eventsViewModel.startListening(pairID: pairID)
                }
                .onDisappear{
                    eventsViewModel.stopListening()
                }
            }
        }
        .sheet(isPresented: $isShowingDayDetail) {
            DayLettersView(
                date: viewModel.selectedDate!,
                letters: grouped[viewModel.selectedDate!] ?? [],
                pairID: pairID,
                currentUserID: currentUserID,
                homeViewModel: homeViewModel,
                partnerName: partnerName,
                locationService: locationService,
                onOpenLocationInMap: onOpenLocationInMap
            )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
    }
}
#Preview {
    let sampleLetters: [Letter] = [
        Letter(
            authorID: "previewUser1",
            subject: "i love you", text: "Hi, dear! How are you?",
            createdAt: .now
        ),
        Letter(
            authorID: "previewUser2",
            subject: "i love you 2", text: "Miss you, my love",
            createdAt: Calendar.current.date(byAdding: .day, value: -7, to: .now)!
        ),
        Letter(
            authorID: "previewUser1",
            subject: "i love you 3", text: "Another letter this day",
            createdAt: Calendar.current.date(byAdding: .day, value: -7, to: .now)!
        )
    ]

    CalendarView(
        letters: sampleLetters,
        pairID: "123456789",
        currentUserID: nil,
        partnerName: "nastia",
        homeViewModel: HomeViewModel(),
        locationService: LocationService(),
        onOpenLocationInMap: { _ in })
}
