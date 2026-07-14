//
//  NameSetupView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 14.07.2026.
//

import SwiftUI

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
