//
//  ProfileView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 10.07.2026.
//

import PhotosUI
import FirebaseAuth
import Kingfisher
import SwiftUI
import UIKit

struct ProfileView: View {
    @AppStorage("appTheme") private var appTheme: Int = 1
    @AppStorage("useHandwritingFont") var useHandwritingFont: Bool = true
    @State private var profileViewModel = ProfileViewModel()
    @State private var selectedItem: PhotosPickerItem?
    @State private var showFullScreenAvatar = false
    @State private var showLogoutDialog = false
    
    @State private var isEditingName: Bool = false
    @State private var editedName: String = ""
    
    @State private var isEditingPartnerNickname: Bool = false
    @State private var editedPartnerNickname: String = ""
    @State private var codeCopied: Bool = false
    
    @State private var nameEditToggled = false
    @State private var codeCopyTapped = false
    @State private var partnerNicknameEditToggled = false
    @State private var avatarTapped = false
    @State private var fullScreenDismissed = false
    @State private var logoutTapped = false
    @State private var logoutConfirmed = false
    

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
                        logoutConfirmed.toggle()
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
                    await profileViewModel.loadPair(pairID: authViewModel.pairID)
                }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: nameEditToggled)
        .sensoryFeedback(.success, trigger: codeCopyTapped)
        .sensoryFeedback(.impact(weight: .light), trigger: partnerNicknameEditToggled)
        .sensoryFeedback(.impact(weight: .light), trigger: avatarTapped)
        .sensoryFeedback(.impact(weight: .light), trigger: fullScreenDismissed)
        .sensoryFeedback(.impact(weight: .light), trigger: logoutTapped)
        .sensoryFeedback(.impact(weight: .heavy), trigger: logoutConfirmed)
    }
    private var profileForm: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28){
                avatarSection
                
                statsSection
                
                userInfoSection
                
                pairInfoSection
                
                logoutSection
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
    }
    private var statsSection: some View {

        HStack {

            statItem(
                title: "Letters",
                value: "\(lettersCount)"
            )

            Divider()

            statItem(
                title: "Days",
                value: "\(daysTogether)"
            )

            Divider()

            statItem(
                title: "Photos",
                value: "\(photosCount)"
            )

        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    private var userInfoSection: some View {
        VStack(alignment: .leading, spacing: 14) {

            Text("ACCOUNT")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {

                nameRow

                Divider()
                    .padding(.leading, 56)

                inviteCodeRow

                Divider()
                    .padding(.leading, 56)

                appearanceRow
                
                Divider()
                    .padding(.leading, 56)
                
                fontRow
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    private var nameRow: some View {
        HStack(spacing: 16) {

            Image(systemName: "person.fill")
                .font(.title3)
                .frame(width: 26)
                .foregroundStyle(Color.accentColor)

            VStack(alignment: .leading, spacing: 3) {

                Text("Name")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if isEditingName {

                    TextField("Name", text: $editedName)
                        .textFieldStyle(.plain)

                } else {

                    Text(authViewModel.displayName ?? "Unknown")
                        .font(.headline)
                }
            }

            Spacer()

            if isEditingName {

                HStack {

                    Button("Cancel") {
                        nameEditToggled.toggle()
                        isEditingName = false
                        editedName = authViewModel.displayName ?? ""
                    }

                    Button("Save") {
                        nameEditToggled.toggle()
                        Task{
                            await authViewModel.saveDisplayName(editedName);
                            isEditingName = false
                        }
                    }
                    .fontWeight(.semibold)
                }

            } else {

                Button {
                    nameEditToggled.toggle()
                    editedName = authViewModel.displayName ?? ""
                    isEditingName = true

                } label: {

                    Image(systemName: "square.and.pencil")
                        .font(.title3)
                }
            }
        }
        .padding()
    }
    private var inviteCodeRow: some View {
        HStack(spacing: 16) {

            Image(systemName: "link")
                .font(.title3)
                .frame(width: 26)
                .foregroundStyle(Color.accentColor)

            VStack(alignment: .leading, spacing: 3) {

                Text("Invite Code")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("Share this code with your partner")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Button {
                codeCopyTapped.toggle()
                UIPasteboard.general.string = profileViewModel.inviteCode

                withAnimation(.easeOut(duration: 0.2)) {
                    codeCopied = true
                }

                Task {
                    try? await Task.sleep(for: .seconds(1.5))
                    withAnimation(.easeOut(duration: 0.2)) {
                        codeCopied = false
                    }
                }

            } label: {

                HStack(spacing: 8) {

                    Text(profileViewModel.inviteCode ?? "")

                    Image(systemName: codeCopied ? "checkmark" : "doc.on.doc")
                        .contentTransition(.symbolEffect(.replace))
                }
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.thinMaterial)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding()
    }
    private var appearanceRow: some View {
        HStack(spacing: 16) {

            Image(systemName: "paintbrush.fill")
                .font(.title3)
                .frame(width: 28)
                .foregroundStyle(Color.accentColor)

            Text("Appearance")
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)

            Picker("", selection: $appTheme) {

                Image(systemName: "sun.max")
                    .tag(1)

                Image(systemName: "moon")
                    .tag(2)
            }
            .labelsHidden()
            .pickerStyle(.segmented)
            .frame(width: 120)
        }
        .padding()
    }
    private var fontRow: some View {
        HStack(spacing: 16) {

            Image(systemName: "pencil.and.scribble")
                .font(.title3)
                .frame(width: 28)
                .foregroundStyle(Color.accentColor)

            VStack(alignment: .leading, spacing: 2) {
                Text("Handwriting Font")
                    .font(.body)

                Text("Applies to letter card")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Toggle("", isOn: $useHandwritingFont)
                .labelsHidden()
        }
        .padding()
    }
private var pairInfoSection: some View {
        VStack(alignment: .leading, spacing: 14) {

            Text("PARTNER")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {

                partnerRow

                Divider()
                    .padding(.leading, 56)

                togetherRow

                Divider()
                    .padding(.leading, 56)

                sinceRow

                Divider()
                    .padding(.leading, 56)

                lettersRow
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    private var partnerRow: some View {
        HStack(spacing: 16) {

            Image(systemName: "heart.fill")
                .foregroundStyle(Color.accentColor)
                .font(.title3)
                .frame(width: 26)

            VStack(alignment: .leading, spacing: 3) {

                Text("Partner")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if isEditingPartnerNickname {

                    TextField("Nickname", text: $editedPartnerNickname)
                        .textFieldStyle(.plain)

                } else {

                    Text(authViewModel.partnerNickname ??
                         authViewModel.partnerDisplayName ??
                         "Unknown")
                        .font(.headline)
                }
            }

            Spacer()

            if isEditingPartnerNickname {

                HStack {

                    Button("Cancel") {
                        partnerNicknameEditToggled.toggle()
                        isEditingPartnerNickname = false
                    }

                    Button("Save") {
                        partnerNicknameEditToggled.toggle()
                        Task{
                            await authViewModel.savePartnerNickname(editedPartnerNickname)
                            isEditingPartnerNickname = false
                        }
                    }
                    .fontWeight(.semibold)
                }
                
            } else {
                Button {
                    partnerNicknameEditToggled.toggle()
                    editedPartnerNickname =
                        authViewModel.partnerNickname ??
                        authViewModel.partnerDisplayName ?? ""

                    isEditingPartnerNickname = true

                } label: {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
        .padding()
    }
    private var togetherRow: some View {
        HStack(spacing: 16) {

            Image(systemName: "figure.2")
                .font(.title3)
                .frame(width: 26)
                .foregroundStyle(Color.accentColor)

            VStack(alignment: .leading, spacing: 2) {

                Text("Together")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("\(daysTogether) days")
                    .font(.title3.bold())
                    .contentTransition(.numericText())
            }

            Spacer()
        }
        .padding()
    }
    private var sinceRow: some View {
        HStack(spacing: 16) {

            Image(systemName: "calendar")
                .font(.title3)
                .frame(width: 26)
                .foregroundStyle(Color.accentColor)

            VStack(alignment: .leading, spacing: 2) {

                Text("Together Since")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(
                    profileViewModel.pair?.startDate.formatted(
                        date: .long,
                        time: .omitted
                    ) ?? "—"
                )
                .font(.headline)
            }

            Spacer()
        }
        .padding()
    }
    private var lettersRow: some View {
        HStack(spacing: 16) {

            Image(systemName: "envelope.fill")
                .font(.title3)
                .frame(width: 26)
                .foregroundStyle(Color.accentColor)

            VStack(alignment: .leading, spacing: 2) {

                Text("Letters")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("\(homeViewModel.letters.count)")
                    .font(.title3.bold())
                    .contentTransition(.numericText())
            }

            Spacer()
        }
        .padding()
    }
    private var logoutSection: some View {
        Button("Logout", role: .destructive) {
            logoutTapped.toggle()
            showLogoutDialog = true
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.red.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    private var avatarSection: some View {
        VStack(spacing: 18) {
            
            avatarView
                .frame(maxWidth: .infinity)
                .fullScreenCover(isPresented: $showFullScreenAvatar) {
                    fullScreenAvatar
                }
            
            VStack(spacing: 4){
                Text(authViewModel.displayName ?? "User")
                    .font(.title2.bold())
                
                Text("Letterfly member")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            avatarPicker
        }
        .padding(.vertical, 16)
    }
    private var avatarView: some View {
        ZStack {
            if let previewImage = profileViewModel.previewImage {
                Image(uiImage: previewImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .overlay {
                        Circle()
                            .stroke(Color.accentColor.opacity(0.35), lineWidth: 3)
                    }
                    .shadow(
                        color: .accentColor.opacity(0.25),
                        radius: 15
                    )
                    .onTapGesture {
                        avatarTapped.toggle()
                        showFullScreenAvatar = true
                    }

            } else if let imageURL = profileViewModel.avatarURL {
                KFImage(imageURL)
                .placeholder {
                    PawLoadingView()
                }
                .resizable()
                .scaledToFill()
                .frame(width: 150, height: 150)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(Color.accentColor.opacity(0.35), lineWidth: 3)
                }
                .shadow(
                    color: .accentColor.opacity(0.25),
                    radius: 15
                )
                .onTapGesture {
                    avatarTapped.toggle()
                    showFullScreenAvatar = true
                }
                

            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .overlay {
                        Circle()
                            .stroke(Color.accentColor.opacity(0.35), lineWidth: 3)
                    }
                    .shadow(
                        color: .accentColor.opacity(0.25),
                        radius: 15
                    )
                    .onTapGesture {
                        avatarTapped.toggle()
                        showFullScreenAvatar = true
                    }
            }

            if profileViewModel.isLoading {
                Circle()
                    .fill(.black.opacity(0.35))
                    .frame(width: 150, height: 150)

                PawLoadingView()
            }
        }
    }
    private var avatarPicker: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {

            Label("Change Photo", systemImage: "camera.fill")
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(.thinMaterial)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(profileViewModel.isLoading)
    }
    private var fullScreenAvatar: some View {
        Group {
            if let previewImage = profileViewModel.previewImage {
                Image(uiImage: previewImage)
                    .resizable()
                    .scaledToFit()

            } else {
                KFImage(profileViewModel.avatarURL)
                    .placeholder {
                        PawLoadingView()
                    }
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        .ignoresSafeArea()
        .onTapGesture {
            fullScreenDismissed.toggle()
            showFullScreenAvatar = false
        }
    }
    private func statItem(title: String, value: String) -> some View {
        VStack(spacing: 6) {

            Text(value)
                .font(.title.bold())
                .contentTransition(.numericText())

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    private var daysTogether: Int {
        guard let pair = profileViewModel.pair else { return 0 }

        return Calendar.current.dateComponents(
            [.day],
            from: pair.startDate,
            to: Date()
        ).day ?? 0
    }
    private var lettersCount: Int {
        homeViewModel.letters.count
    }
    private var photosCount : Int {
        let array = homeViewModel.letters.filter {$0.photoURL != nil }
        return array.count
    }
}
#Preview {
    ProfileView(authViewModel: AuthViewModel(), homeViewModel: HomeViewModel())
}
