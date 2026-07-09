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
    var userServices = UserServices()
    var viewModel: AuthViewModel
    
    var body: some View {
        Form{
            Text(inviteCode ?? "Loading...")
            
            Button("Logout") {
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
    }
}

#Preview {
    PairView(viewModel: AuthViewModel())
}
