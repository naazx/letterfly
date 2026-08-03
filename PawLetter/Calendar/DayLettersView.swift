//
//  DayLettersView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 11.07.2026.
//

import SwiftUI

struct DayLettersView: View {
    var date: Date
    var letters: [Letter]
    
    var pairID: String
    var currentUserID: String?
    var homeViewModel: HomeViewModel
    var partnerName: String?
    
    var body: some View {
        NavigationStack{
            List(letters){ letter in
                NavigationLink(value: letter){
                    LetterRowView(letter: letter, currentUserID: currentUserID, loadedImage: homeViewModel.loadedImages[letter.id ?? ""])
                }
                .onAppear {
                    Task {
                        await homeViewModel.loadImageIfNeeded(for: letter)
                    }
                }
            }
            .navigationDestination(for: Letter.self) { letter in
                LetterDetailView(letter: letter, pairID: pairID, currentUserID: currentUserID, partnerName: partnerName)
            }
            .navigationTitle(date.formatted(.dateTime.day().month().year()))
        }
    }
}

#Preview {
    let sampleLetters: [Letter] = [
        Letter(
            authorID: "previewUser1",
            subject: "how are you?", text: "Привіт, любий! Як твій день?",
            createdAt: .now
        ),
    ]
    
    DayLettersView(date: .now, letters: sampleLetters, pairID: "123456789", currentUserID: nil , homeViewModel: HomeViewModel(), partnerName: "Nastia")
}
