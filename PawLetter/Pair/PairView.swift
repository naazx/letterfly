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
                    .padding(.top, 20)

                    VStack(spacing: 12) {
                        if let inviteCode {
                            Text(inviteCode)
                                .font(.system(.largeTitle, design: .monospaced, weight: .semibold))
                                .kerning(4)
                        } else {
                            ProgressView()
                                .frame(height: 44)
                        }

                        if let inviteCode {
                            HStack(spacing: 12) {
                                Button {
                                    UIPasteboard.general.string = inviteCode
                                    copiedTapped.toggle()
                                } label: {
                                    Label("Copy", systemImage: "doc.on.doc")
                                }
                                .buttonStyle(.bordered)

                                ShareLink(item: inviteCode) {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal)

                    VStack(spacing: 12) {
                        TextField("Enter your partner's code", text: $partnerCodeInput)
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.none)

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
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text("Join")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .buttonStyle(.borderedProminent)
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
