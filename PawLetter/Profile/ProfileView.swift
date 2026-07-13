//
//  ProfileView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 10.07.2026.
//

import FirebaseAuth
import SwiftUI

struct ProfileView: View {
    @State private var profileViewModel = ProfileViewModel()
    var authViewModel: AuthViewModel
    
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
                        Text(profileViewModel.inviteCode ?? "Loading...")
                    }
                    Button("Logout", systemImage: "person.crop.circle.fill.badge.xmark") {
                        authViewModel.signOut()
                    }
                }
                .task {
                   await profileViewModel.loadInviteCode()
                }
                .navigationTitle("Profile")
            }
        }
}

#Preview {
    ProfileView(authViewModel: AuthViewModel())
}
