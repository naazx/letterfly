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
        NavigationStack{
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
            .toolbar{
                Button("Add new list", systemImage: "plus"){
                    isShowingNewLetter = true
                }
            }
            .sheet(isPresented: $isShowingNewLetter) {
                if let  currentUserID {
                    NewLetterView(existingLetter: nil, pairID: pairID, authorID: currentUserID)
                }
            }
            .navigationDestination(for: Letter.self) { letter in
                LetterDetailView(letter: letter, pairID: pairID)
            }
            .navigationTitle("Your lists")
        }
    }
}
#Preview {
    HomeView(homeViewModel: HomeViewModel(), pairID: "qJ23Kdi6EMFLYmtnWgiD", currentUserID: nil)
}
