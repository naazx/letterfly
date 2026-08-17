//
//  LetterCardView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 17.08.2026.
//

import SwiftUI

struct LetterCardView: View {
    @AppStorage("useHandwritingFont") private var useHandwritingFont: Bool = true
    @Environment(\.dismiss) var dismiss
    @State private var currentUserName: String?
    @State private var userServices = UserServices()
    
    var letter: Letter
    var currentUserID: String?
    var partnerName: String?
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(.systemBackground))
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(letter.subject)
                        .font(.handwriting(size: 28, enabled: useHandwritingFont))
                    
                    if let text = letter.text {
                        Text(text)
                            .font(.handwriting(size: 18, enabled: useHandwritingFont))
                    }
                }
                .frame(maxWidth: 250, minHeight: 250, alignment: .topLeading)
                .padding(24)
                .background(Color.accentColor.opacity(0.70))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundStyle(Color.accentColor)
                        .frame(width: 52, height: 52)
                        .overlay(
                            Circle()
                                .stroke(Color.accentColor, lineWidth: 1.5)
                        )
                        .padding(.top, 50)
                }
            }
        }
        .task {
            if let result = try? await userServices.fetchUserProfile(uid: currentUserID!) {
                currentUserName = result.displayName
            }
        }
    }
}

#Preview {
    LetterCardView(letter: Letter(
        authorID: "123456789",
        subject: "We have to talk",
        text: "i love you so much",
        createdAt: .now),
                   currentUserID: "Nazar lox",
                   partnerName: "nastia"
    )
}
