//
//  HomeView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 10.07.2026.
//

import MapKit
import SwiftUI

struct HomeView: View {
    @State private var isShowingNewLetter: Bool = false
    @State private var letterServices = LetterServices()
    @State private var sortOption: SortOption = .dateSent
    @State private var searchText: String = ""
    var homeViewModel: HomeViewModel
    var pairID: String
    var currentUserID: String?
    var partnerName: String?
    var locationService: LocationService
    
    var onOpenLocationInMap: (CLLocationCoordinate2D) -> Void
    
    private var sortedLetters: [Letter] {
        switch sortOption {
        case .dateSent:
            return  homeViewModel.letters.sorted { letter1, letter2 in
                return letter1.createdAt > letter2.createdAt
            }
        case .name:
            return homeViewModel.letters.sorted { letter1, letter2 in
                return letter1.subject.lowercased() < letter2.subject.lowercased()
            }
        }
    }
    
    private var displayedLetters: [Letter] {
        if searchText.isEmpty {
            sortedLetters
        } else {
            sortedLetters.filter { $0.subject.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            Group{
                if homeViewModel.letters.isEmpty {
                    emptyState
                } else if displayedLetters.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List {
                        ForEach(displayedLetters) { letter in
                            NavigationLink(value: letter) {
                                LetterRowView(letter: letter, currentUserID: currentUserID, loadedImage: homeViewModel.loadedImages[letter.id ?? ""])
                            }
                            .onAppear {
                                Task {
                                    await homeViewModel.loadImageIfNeeded(for: letter)
                                }
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(
                                EdgeInsets(
                                    top: 8,
                                    leading: 20,
                                    bottom: 8,
                                    trailing: 20
                                )
                            )
                        }
                        .onDelete{ indexSet in
                            for index in indexSet {
                                let letter = displayedLetters[index]
                                guard let id = letter.id else { continue }
                                Task {
                                    try? await letterServices.deleteLetter(pairID: pairID, letterID: id, photoURL: letter.photoURL, audioURL: letter.audioURL)
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color(.systemGroupedBackground))
                    .toolbar{
                        Menu {
                            Section("Sort By") {
                                ForEach(SortOption.allCases, id: \.self) { option in
                                    Button {
                                        sortOption = option
                                    } label: {
                                        if option == sortOption {
                                            Label(option.title, systemImage: "checkmark")
                                        } else {
                                            Text(option.title)
                                        }
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                        }
                        
                        Button("New Letter", systemImage: "square.and.pencil"){
                            isShowingNewLetter = true
                        }
                    }
                    .navigationTitle("Letters")
                    .navigationBarTitleDisplayMode(.large)
                }
            }
            .searchable(text: $searchText, prompt: "Search...")
            .sheet(isPresented: $isShowingNewLetter) {
                if let  currentUserID {
                    NewLetterView(
                        existingLetter: nil,
                        pairID: pairID,
                        authorID: currentUserID,
                        locationService: locationService
                    )
                }
            }
            .navigationDestination(for: Letter.self) { letter in
                LetterDetailView(
                    letter: letter,
                    pairID: pairID,
                    currentUserID: currentUserID,
                    partnerName: partnerName,
                    locationService: locationService,
                    onOpenLocationInMap: onOpenLocationInMap
                )
            }
        }
    }
   private var emptyState: some View {
        ContentUnavailableView {
            Label("No Letters Yet", systemImage: "envelope")
        } description: {
            Text("Write your first letter and start creating memories together.")
        } actions: {
            Button("Write First Letter") {
                isShowingNewLetter = true
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
#Preview {
    HomeView(homeViewModel: HomeViewModel(),
             pairID: "qJ23Kdi6EMFLYmtnWgiD",
             currentUserID: nil,
             locationService: LocationService(),
             onOpenLocationInMap: { _ in })
}
