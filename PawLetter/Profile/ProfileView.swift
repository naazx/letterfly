//
//  ProfileView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 10.07.2026.
//

import PhotosUI
import FirebaseAuth
import SwiftUI
import UIKit

struct ProfileView: View {
    @AppStorage("appTheme") private var appTheme: Int = 0
    @State private var profileViewModel = ProfileViewModel()
    @State private var selectedItem: PhotosPickerItem?
    @State private var showFullScreenAvatar = false
    @State private var showLogoutDialog = false
    
    @State private var isEditingName: Bool = false
    @State private var editedName: String = ""
    
    @State private var isEditingPartnerNickname: Bool = false
    @State private var editedPartnerNickname: String = ""
    
    @State private var codeCopied: Bool = false
    

    var authViewModel: AuthViewModel
    var homeViewModel: HomeViewModel

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
                    await profileViewModel.loadPair(pairID: authViewModel.pairID)
                }
        }
    }
    private var profileForm: some View {
        Form {
            avatarSection
            userInfoSection
            pairInfoSection
            logoutSection
        }
    }
    private var userInfoSection: some View {
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
                    
                    Button("Confirm") {
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
                
                HStack(spacing: 4){
                    Text(profileViewModel.inviteCode ?? "Loading...")
                        .font(.system(.body, design: .monospaced))
                    
                    Image(systemName: codeCopied ? "checkmark" : "doc.on.doc")
                        .font(.caption)
                        .foregroundStyle(codeCopied ? .green : .secondary)
                       
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.15), in: Capsule())
                .onTapGesture {
                    guard let code = profileViewModel.inviteCode else { return }
                    UIPasteboard.general.string = code
                    
                    withAnimation {
                        codeCopied = true
                    }
                    
                    Task{
                        try? await Task.sleep(for: .seconds(1.5))
                        withAnimation {
                            codeCopied = false
                        }
                    }
                }
            }
            
            HStack{
                Image(systemName: "circle.lefthalf.filled")
                Text("Appearance")
                    .font(.body)
                
                Spacer()
                
                Picker("Appearance", selection: $appTheme){
                    Image(systemName: "desktopcomputer")
                        .tag(0) // system
                    
                    Image(systemName: "sun.max")
                        .tag(1) // light
                    
                    Image(systemName: "moon")
                        .tag(2) // dark
                }
                .pickerStyle(.segmented)
                .frame(width: 120)
            }
        }
    }
    private var pairInfoSection: some View {
        Section{
            HStack {
                Image(systemName: "heart.fill")
                           
            if isEditingPartnerNickname  == false{
                Text(authViewModel.partnerNickname ?? authViewModel.partnerDisplayName ??
                     "—")
                               
            Spacer()

            Button("Edit") {
                editedPartnerNickname = authViewModel.partnerNickname ?? ""
                    isEditingPartnerNickname = true
            }
        }
            else{
                TextField("Name", text: $editedPartnerNickname)
                               
                Spacer()
                               
                Button("Cancel"){
                    isEditingPartnerNickname = false
                }
                .foregroundStyle(.red)
                               
                Button("Confirm") {
                    Task{
                        await authViewModel.savePartnerNickname(editedPartnerNickname)
                        isEditingPartnerNickname = false
                    }
                }
                .foregroundStyle(.green)
                .disabled(editedPartnerNickname.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
            if let pair = profileViewModel.pair {
                HStack {
                    let daysTogether = Calendar.current.dateComponents([.day], from: pair.startDate, to: Date()).day ?? 0
                    Image(systemName: "calendar.badge.clock")
                    Text("\(pair.startDate.formatted(.dateTime.day().month(.abbreviated).year())) (\(daysTogether) days together)")
                }
                HStack {
                    Image(systemName: "envelope.fill")
                    Text("Total letters: \(homeViewModel.letters.count)")
                }
            }
        }
    }
    private var logoutSection: some View {
        Section {
            Button("Logout", role: .destructive) {
                showLogoutDialog = true
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .listRowBackground(Color.red.opacity(0.15))
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
                    .overlay(Circle().stroke(.blue.opacity(0.4), lineWidth: 2))
                    .shadow(color: .blue.opacity(0.25), radius: 8)
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
                .overlay(Circle().stroke(.blue.opacity(0.4), lineWidth: 2))
                .shadow(color: .blue.opacity(0.25), radius: 8)
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
                    .overlay(Circle().stroke(.blue.opacity(0.4), lineWidth: 2))
                    .shadow(color: .blue.opacity(0.25), radius: 8)
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
    ProfileView(authViewModel: AuthViewModel(), homeViewModel: HomeViewModel())
}
