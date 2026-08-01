//
//  HomeView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 10.07.2026.
//

import SwiftUI

struct HomeView: View {
    @State private var isShowingNewLetter: Bool = false
    @State private var letterServices = LetterServices()
    var homeViewModel: HomeViewModel
    var pairID: String
    var currentUserID: String?
    
    var body: some View {
        NavigationStack {
            Group{
                if homeViewModel.letters.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(homeViewModel.letters) { letter in
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
                                let letter = homeViewModel.letters[index]
                                guard let id = letter.id else { continue }
                                Task {
                                    try? await letterServices.deleteLetter(pairID: pairID, letterID: id, photoURL: letter.photoURL)
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color(.systemGroupedBackground))
                    .toolbar{
                        Button("New Letter", systemImage: "square.and.pencil"){
                            isShowingNewLetter = true
                        }
                    }
                    .navigationTitle("Letters")
                    .navigationBarTitleDisplayMode(.large)
                }
            }
            .sheet(isPresented: $isShowingNewLetter) {
                if let  currentUserID {
                    NewLetterView(existingLetter: nil, pairID: pairID, authorID: currentUserID)
                }
            }
            .navigationDestination(for: Letter.self) { letter in
                LetterDetailView(letter: letter, pairID: pairID, currentUserID: currentUserID)
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
    HomeView(homeViewModel: HomeViewModel(), pairID: "qJ23Kdi6EMFLYmtnWgiD", currentUserID: nil)
}
