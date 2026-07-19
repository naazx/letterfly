//
//  MainTabView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 09.07.2026.
//

import SwiftUI

struct MainTabView: View {
    @State private var homeViewModel = HomeViewModel()
    var viewModel: AuthViewModel
    
    var body: some View {
        if let pairID = viewModel.pairID {
            TabView {
                HomeView(homeViewModel: homeViewModel, pairID: pairID, currentUserID: viewModel.userID)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                CalendarView(letters: homeViewModel.letters, pairID: pairID, currentUserID: viewModel.userID, homeViewModel: homeViewModel)
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
                ProfileView(authViewModel: viewModel)
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
            }
            .onAppear {
                homeViewModel.startListening(pairID: pairID)
            }
            .onDisappear {
                homeViewModel.stopListening()
            }
        } else {
            ProgressView()
        }
    }
}

#Preview {
    MainTabView(viewModel: AuthViewModel())
}
