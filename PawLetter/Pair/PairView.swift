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
    
    var userServices = UserServices()
    var viewModel: AuthViewModel
    var pairServices = PairServices()
    
    var body: some View {
        NavigationStack {
            Form{
                Section("Your code"){
                    Text(inviteCode ?? "Loading...")
                }
                Section("Join pair"){
                    TextField("Enter your partner code", text: $partnerCodeInput)
                    
                    Button("Join") {
                        joinTapped.toggle()
                        Task {
                            isJoining = true
                            guard let user = Auth.auth().currentUser else {
                                inviteCode = "NO USER"
                                isJoining = false
                                return
                            }
                            
                            do {
                                try await pairServices.joinPair(myUID: user.uid, partnerCode: partnerCodeInput)
                                await viewModel.loadUserData(uid: user.uid)
                            } catch PairError.codeNotFound{
                                errorMessage = "code is not found"
                                showError = true
                            }
                            catch PairError.selfSearch{
                                errorMessage = "user has written his own code"
                                showError = true
                            } catch let error{
                                errorMessage = error.localizedDescription
                                showError = true
                            }
                            isJoining = false
                        }
                    }
                    .disabled(isJoining)
                }
            }
            .toolbar{
                Button("Logout", systemImage: "person.crop.circle.fill.badge.xmark") {
                    logoutTapped.toggle()
                    viewModel.signOut()
                }
            }
            .task {
                guard let user = Auth.auth().currentUser else {
                    inviteCode = "NO USER"
                    return
                }
                do {
                    let profile = try await userServices.fetchUserProfile(uid: user.uid)
                    inviteCode = profile.inviteCode ?? "NIL CODE"
                } catch {
                    inviteCode = "ERROR: \(error.localizedDescription)"
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
    }
}

#Preview {
    PairView(viewModel: AuthViewModel())
}
