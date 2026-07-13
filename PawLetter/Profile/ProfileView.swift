//
//  ProfileView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 10.07.2026.
//

import PhotosUI
import FirebaseAuth
import SwiftUI

struct ProfileView: View {
    @State private var profileViewModel = ProfileViewModel()
    @State private var selectedItem: PhotosPickerItem?
    var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack{
            Form {
                Section {
                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images
                    ) {
                        ZStack{
                            if let previewImage = profileViewModel.previewImage {
                                Image(uiImage: previewImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else if let imageURL = profileViewModel.avatarURL {
                                AsyncImage(url: imageURL) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(.blue)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            }
                            
                            if profileViewModel.isLoading {
                                Circle()
                                    .fill(.black.opacity(0.35))
                                    .frame(width: 100, height: 100)
                                
                                ProgressView()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(profileViewModel.isLoading)
                }
                .listRowBackground(Color.clear)
                       
                    Section("Your code"){
                        Text(profileViewModel.inviteCode ?? "Loading...")
                    }
                    Button("Logout", systemImage: "person.crop.circle.fill.badge.xmark") {
                        authViewModel.signOut()
                    }
                }
            .onChange(of: selectedItem){
                guard let item = selectedItem else { return }
                Task{
                    await profileViewModel.loadAndUpload(item: item)
                }
            }
            .task {
                await profileViewModel.loadProfile()
            }
            .alert("Error", isPresented: $profileViewModel.showError) {
                Button("OK") {}
            } message: {
                Text(profileViewModel.errorMessage)
            }
            .navigationTitle("Profile")
            }
    }
}

#Preview {
    ProfileView(authViewModel: AuthViewModel())
}
