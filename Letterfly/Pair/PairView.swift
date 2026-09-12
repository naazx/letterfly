//
//  PairView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 09.07.2026.
//

import FirebaseAuth
import SwiftUI

struct PairView: View {
    @State private var inviteCode: String?
    @State private var partnerCodeInput: String = ""
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    @State private var isJoining: Bool = false
    @State private var joinTapped = false
    @State private var logoutTapped = false
    @State private var copiedTapped = false
    @State private var showCopiedConfirmation = false

    var userServices = UserServices()
    var viewModel: AuthViewModel
    var pairServices = PairServices()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    VStack(spacing: 14) {
                        Image(systemName: "envelope.badge.person.crop.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(.pink)

                        Text("Pair with your partner")
                            .font(.title2.bold())

                        Text("Share your code below, or enter theirs to connect.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 24)

                    VStack(spacing: 12) {
                        if let inviteCode {
                            Text(inviteCode)
                                .font(.system(.largeTitle, design: .monospaced, weight: .semibold))
                                .kerning(4)

                            HStack(spacing: 12) {
                                Button {
                                    UIPasteboard.general.string = inviteCode
                                    copiedTapped.toggle()

                                    withAnimation(.easeOut(duration: 0.2)) {
                                        showCopiedConfirmation = true
                                    }
                                    Task {
                                        try? await Task.sleep(for: .seconds(1.5))
                                        withAnimation(.easeOut(duration: 0.2)) {
                                            showCopiedConfirmation = false
                                        }
                                    }
                                } label: {
                                    Label(
                                        showCopiedConfirmation ? "Copied" : "Copy",
                                        systemImage: showCopiedConfirmation ? "checkmark" : "doc.on.doc"
                                    )
                                    .contentTransition(.symbolEffect(.replace))
                                    .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .pressScaleEffect()
                                .tint(.pink)

                                ShareLink(item: inviteCode) {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .pressScaleEffect()
                                .tint(.pink)
                            }
                        } else {
                            ProgressView()
                                .frame(height: 44)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .padding(.horizontal, 16)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal)

                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "number")
                                .foregroundStyle(.secondary)

                            TextField("Enter your partner's code", text: $partnerCodeInput)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 48)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                        Button {
                            joinTapped.toggle()
                            Task {
                                isJoining = true
                                guard let user = Auth.auth().currentUser else {
                                    errorMessage = "You're not signed in."
                                    showError = true
                                    isJoining = false
                                    return
                                }

                                do {
                                    try await pairServices.joinPair(myUID: user.uid, partnerCode: partnerCodeInput)
                                    await viewModel.loadUserData(uid: user.uid)
                                } catch PairError.codeNotFound {
                                    errorMessage = "That code wasn't found."
                                    showError = true
                                } catch PairError.selfSearch {
                                    errorMessage = "You can't pair with your own code."
                                    showError = true
                                } catch {
                                    errorMessage = error.localizedDescription
                                    showError = true
                                }
                                isJoining = false
                            }
                        } label: {
                            if isJoining {
                                ProgressView()
                                    .tint(.white)
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text("Join")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.pink)
                        .controlSize(.large)
                        .disabled(isJoining || partnerCodeInput.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding(.horizontal)

                    Button("Log Out") {
                        logoutTapped.toggle()
                        viewModel.signOut()
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
                }
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
            .onboardingOverlay(message: "Last step! Once you're paired, you're ready to send your first letter.", systemImage: "person.2.fill")
            .task {
                guard let user = Auth.auth().currentUser else {
                    errorMessage = "You're not signed in."
                    showError = true
                    return
                }
                do {
                    let profile = try await userServices.fetchUserProfile(uid: user.uid)
                    inviteCode = profile.inviteCode
                } catch {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: joinTapped)
        .sensoryFeedback(.impact(weight: .light), trigger: logoutTapped)
        .sensoryFeedback(.success, trigger: copiedTapped)
    }
}

#Preview {
    PairView(viewModel: AuthViewModel())
}
