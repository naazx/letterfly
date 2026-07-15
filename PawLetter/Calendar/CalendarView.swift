//
//  CalendarView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 10.07.2026.
//

import SwiftUI

struct CalendarView: View {
    @State private var viewModel = CalendarViewModel()
    @State private var isShowingDayDetail: Bool = false
    
    var letters: [Letter]
    let months: [Date]
    let currentMonth: Date
    
    var body: some View {
        let grouped = viewModel.groupedLetters(letters)
        
        NavigationStack {
            ScrollViewReader{ proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(months, id: \.self) { month in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(month.formatted(.dateTime.month(.wide).year()))
                                
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
                                            
                                            VStack {
                                                Text("\(day)")
                                                if hasContent {
                                                    Circle().frame(width: 4, height: 4)
                                                }
                                            }
                                            .frame(height: 40)
                                            .onTapGesture {
                                                viewModel.selectedDate = dayKey
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
                        proxy.scrollTo(currentMonth, anchor: .center)
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingDayDetail) {
            DayLettersView(date: viewModel.selectedDate! , letters: grouped[viewModel.selectedDate!] ?? [])
        }
    }
    init(letters: [Letter]){
        let calendar = Calendar.current
        let currentFirstDay = CalendarGridHelper.firstDayOfMonth(containing: .now)
                
                self.months = (-12...12).compactMap { offset -> Date? in
                    guard let movedDate = calendar.date(byAdding: .month, value: offset, to: currentFirstDay) else {
                        return nil
                    }
                    return CalendarGridHelper.firstDayOfMonth(containing: movedDate)
                }
        self.currentMonth = currentFirstDay
        self.letters = letters
    }
}
#Preview {
    let sampleLetters: [Letter] = [
        Letter(
            authorID: "previewUser1",
            subject: "i love you", text: "Привіт, любий! Як твій день?",
            createdAt: .now
        ),
        Letter(
            authorID: "previewUser2",
            subject: "i love you 2", text: "Скучив за тобою",
            createdAt: Calendar.current.date(byAdding: .day, value: -7, to: .now)!
        ),
        Letter(
            authorID: "previewUser1",
            subject: "i love you 3", text: "Ще один лист того ж дня",
            createdAt: Calendar.current.date(byAdding: .day, value: -7, to: .now)!
        )
    ]

    CalendarView(letters: sampleLetters)
}
