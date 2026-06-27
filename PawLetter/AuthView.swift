//
//  AuthView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 27.06.2026.
//

import SwiftUI

struct AuthView: View {
    var viewModel: AuthViewModel
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        NavigationStack{
            Form {
                Section{
                    TextField("Email", text: $email)
                    SecureField("Password", text: $password)
                }
                Section {
                    Button("Sign in"){
                        Task{
                             await viewModel.signIn(email: email, password: password)
                        }
                    }
                    Button("Sing up"){
                        Task{
                             await viewModel.signUp(email: email, password: password)
                        }
                    }
                    Button("Reset password") {
                        Task{
                            await viewModel.resetPassword(email: email)
                        }
                    }
                }
            }
            .navigationTitle("Login")
        }
    }
}

#Preview {
    AuthView(viewModel: AuthViewModel())
}
