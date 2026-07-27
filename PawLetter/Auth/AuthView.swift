//
//  AuthView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 27.06.2026.
//

import SwiftUI
import AuthenticationServices

struct AuthView: View {
    var viewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

//                SignInWithAppleButton(.signIn) { request in
//                    viewModel.prepareAppleRequest(request)
//                } onCompletion: { result in
//                    Task {
//                        await viewModel.signInWithApple(result: result)
//                    }
//                }
//                .signInWithAppleButtonStyle(.black)
//                .frame(height: 50)
//                .padding(.horizontal)
//
//                 TODO: Google Sign-In кнопка — додати після підключення GoogleSignIn SDK

                Spacer()
            }
            .navigationTitle("Login")
        }
    }
}

#Preview {
    AuthView(viewModel: AuthViewModel())
}
