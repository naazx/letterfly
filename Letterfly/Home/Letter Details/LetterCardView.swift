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
    @State private var isAppeared = false
    @State private var cardDismissed = false
    
    var letter: Letter
    var currentUserID: String?
    var partnerName: String?
    
    var body: some View {
        ZStack {
            Image("letterCardBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Dear, \(partnerName ?? "partner")")
                        .font(.handwriting(size: 20, enabled: useHandwritingFont))
                    
                    Text(letter.subject)
                        .font(.handwriting(size: 28, enabled: useHandwritingFont))
                    
                    if let text = letter.text {
                        Text(text)
                            .font(.handwriting(size: 18, enabled: useHandwritingFont))
                    }
                   
                    Spacer()
                    
                    Text("With love,")
                        .font(.handwriting(size: 20, enabled: useHandwritingFont))
                    
                    Text(currentUserName ?? "your love")
                        .font(.handwriting(size: 20, enabled: useHandwritingFont))
                }
                .frame(maxWidth: 250, maxHeight: 400, alignment: .topLeading)
                .padding(24)
                .background(Color.accentColor.opacity(0.70))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .foregroundStyle(.black)
                
                Button {
                    cardDismissed.toggle()
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
                .pressScaleEffect()
            }
            .rotation3DEffect(
                .degrees(isAppeared ? 0 : 70),
                axis: (x: 1, y: 0, z: 0),
                anchor: .top,
                perspective: 0.5
            )
            .opacity(isAppeared ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    isAppeared = true
                }
            }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: cardDismissed)
        .task {
            guard let currentUserID else { return }
            if let result = try? await userServices.fetchUserProfile(uid: currentUserID) {
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
