//
//  NameSetupView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 14.07.2026.
//

import SwiftUI
import FirebaseAuth

struct NameSetupView: View {
    @State private var name = ""

    var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Your name", text: $name)
                } footer: {
                    Text("Your name will be displayed on the letters you send.")
                }
            }
            .navigationTitle("What's your name?")
            .alert("Error", isPresented: .constant(authViewModel.authError != nil)) {
                Button("OK") {
                    authViewModel.authError = nil
                }
            } message: {
                Text(authViewModel.authError?.errorDescription ?? "")
            }
            .safeAreaInset(edge: .bottom) {
                Button("Continue") {
                    Task {
                        await authViewModel.saveDisplayName(name)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .padding()
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
}
#Preview {
    NameSetupView(authViewModel: AuthViewModel())
}
