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
                    VStack(spacing: 12) {
                        Image(systemName: "person.text.rectangle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(.pink)

                        Text("What's your name?")
                            .font(.title2.bold())

                        Text("This is what your partner will see on the letters you send.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }

                Section {
                    TextField("Your name", text: $name)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .onboardingOverlay(message: "Almost there — next you'll connect with your partner.", systemImage: "person.fill")
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
                .tint(.pink)
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
