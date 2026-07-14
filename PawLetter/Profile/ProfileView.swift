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
    @State private var showFullScreenAvatar = false
    @State private var showLogoutDialog = false
    
    @State private var isEditingName: Bool = false
    @State private var editedName: String = ""

    var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            profileForm
                .navigationTitle("Profile")
                .confirmationDialog(
                    "Log out?",
                    isPresented: $showLogoutDialog
                ) {
                    Button("Log Out", role: .destructive) {
                        authViewModel.signOut()
                    }

                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("You'll need to sign in again to access your account.")
                }
                .alert("Error", isPresented: $profileViewModel.showError) {
                    Button("OK") { }
                } message: {
                    Text(profileViewModel.errorMessage)
                }
                .onChange(of: selectedItem) {
                    guard let item = selectedItem else { return }

                    Task {
                        await profileViewModel.loadAndUpload(item: item)
                    }
                }
                .task {
                    await profileViewModel.loadProfile()
                    await profileViewModel.loadFullImage()
                }
        }
    }
    private var profileForm: some View {
        Form {
            avatarSection
            infoSection
            logoutSection
        }
    }
    private var infoSection: some View {
        Section {
            HStack {
                Image(systemName: "person.fill")
                
                if isEditingName  == false{
                    Text(authViewModel.displayName ?? "")
                    
                    Spacer()

                    Button("Edit") {
                        editedName = authViewModel.displayName ?? ""
                        isEditingName = true
                    }
                }
                else{
                    TextField("Name", text: $editedName)
                    
                    Spacer()
                    
                    Button("Cancel"){
                        isEditingName = false
                    }
                    .foregroundStyle(.red)
                    
                    Button("Confirm", role: .confirm) {
                        Task{
                            await authViewModel.saveDisplayName(editedName)
                            isEditingName = false
                        }
                    }
                    .foregroundStyle(.green)
                    .disabled(editedName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

            HStack {
                Image(systemName: "lock.badge.checkmark.fill")
                Text("Your code")

                Spacer()

                Text(profileViewModel.inviteCode ?? "Loading...")
            }
        }
    }
    private var logoutSection: some View {
        Section {
            Button("Logout", role: .destructive) {
                showLogoutDialog = true
            }
        }
    }
    private var avatarSection: some View {
        Section {
            avatarView
                .frame(maxWidth: .infinity)
                .overlay(alignment: .bottomTrailing) {
                    avatarPicker
                }
                .fullScreenCover(isPresented: $showFullScreenAvatar) {
                    fullScreenAvatar
                }
        }
        .listRowBackground(Color.clear)
    }
    private var avatarView: some View {
        ZStack {
            if let previewImage = profileViewModel.previewImage {
                Image(uiImage: previewImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .onTapGesture {
                        showFullScreenAvatar = true
                    }

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
                .onTapGesture {
                    showFullScreenAvatar = true
                }

            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.blue)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .onTapGesture {
                        showFullScreenAvatar = true
                    }
            }

            if profileViewModel.isLoading {
                Circle()
                    .fill(.black.opacity(0.35))
                    .frame(width: 100, height: 100)

                ProgressView()
            }
        }
    }
    private var avatarPicker: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            Image(systemName: "camera.circle.fill")
                .font(.title2)
                .foregroundStyle(.blue)
        }
        .disabled(profileViewModel.isLoading)
    }
    private var fullScreenAvatar: some View {
        Group {
            if let previewImage = profileViewModel.previewImage {
                Image(uiImage: previewImage)
                    .resizable()
                    .scaledToFit()

            } else {
                AsyncImage(url: profileViewModel.avatarURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        .ignoresSafeArea()
        .onTapGesture {
            showFullScreenAvatar = false
        }
    }
}
#Preview {
    ProfileView(authViewModel: AuthViewModel())
}
