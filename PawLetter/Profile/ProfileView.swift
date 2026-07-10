//
//  ProfileView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 10.07.2026.
//

import FirebaseAuth
import SwiftUI

struct ProfileView: View {
    @State private var inviteCode: String?
    
    var viewModel: AuthViewModel
    var userServices = UserServices()
    
    var body: some View {
        NavigationStack{
                Form {
                    Section{
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundStyle(.blue)
                    }
                    .listRowBackground(Color.clear)
                    Section("Your code"){
                        Text(inviteCode ?? "Loading...")
                    }
                    Button("Logout", systemImage: "person.crop.circle.fill.badge.xmark") {
                        viewModel.signOut()
                    }
                }
                .task {
                    guard let user = Auth.auth().currentUser else {
                        inviteCode = "NO USER"
                        return
                    }
                    do {
                        let fetchedCode = try await userServices.fetchInviteCode(uid: user.uid)
                        inviteCode = fetchedCode ?? "NIL CODE"
                    } catch {
                        inviteCode = "ERROR: \(error.localizedDescription)"
                    }
                }
                .navigationTitle("Profile")
            }
        }
}

#Preview {
    ProfileView(viewModel: AuthViewModel())
}
