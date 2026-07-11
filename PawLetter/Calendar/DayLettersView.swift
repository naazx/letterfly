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
    
    var body: some View {
        NavigationStack{
            List(letters){ letter in
                Text(letter.text)
            }
            .navigationTitle(date.formatted(.dateTime.day().month().year()))
        }
    }
}

#Preview {
    let sampleLetters: [Letter] = [
        Letter(
            authorID: "previewUser1",
            text: "Привіт, любий! Як твій день?",
            createdAt: .now
        ),
    ]
    
    DayLettersView(date: .now, letters: sampleLetters)
}
