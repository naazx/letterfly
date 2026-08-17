//
//  LetterCardView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 17.08.2026.
//

import SwiftUI

struct LetterCardView: View {
    @AppStorage("useHandwritingFont") private var useHandwritingFont: Bool = true
    var letter: Letter
    
    var body: some View {
        VStack {
            Text(letter.subject)
                .font(.handwriting(size: 28, enabled: useHandwritingFont))
            
            if let text = letter.text{
                Text(text)
                    .font(.handwriting(size: 18, enabled: useHandwritingFont))
            }
                
        }
    }
}

#Preview {
    LetterCardView(letter: Letter(
        authorID: "123456789",
        subject: "We have to talk",
        text: "i love you so much",
        createdAt: .now))
}
