//
//  ProfileView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 10.07.2026.
//

import SwiftUI

struct ProfileView: View {
    var viewModel: AuthViewModel
    var body: some View {
            Button("Logout", systemImage: "person.crop.circle.fill.badge.xmark") {
                viewModel.signOut()
            }
    }
}

#Preview {
    ProfileView(viewModel: AuthViewModel())
}
