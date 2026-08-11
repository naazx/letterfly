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
                HomeView(homeViewModel: homeViewModel, pairID: pairID, currentUserID: viewModel.userID, partnerName: viewModel.partnerNickname ?? viewModel.partnerDisplayName)
                    .tabItem {
                        Label("Home", systemImage: "house")
                            .labelStyle(.iconOnly)
                    }
                CalendarView(letters: homeViewModel.letters, pairID: pairID, currentUserID: viewModel.userID, partnerName: viewModel.partnerNickname ?? viewModel.partnerDisplayName, homeViewModel: homeViewModel)
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                            .labelStyle(.iconOnly)
                    }
                MapView(letters: homeViewModel.letters, homeViewModel: homeViewModel )
                    .tabItem {
                        Label("Memories", systemImage: "map")
                            .labelStyle(.iconOnly)
                    }
                ProfileView(authViewModel: viewModel, homeViewModel: homeViewModel)
                    .tabItem {
                        Label("Profile", systemImage: "person")
                            .labelStyle(.iconOnly)
                    }
            }
            .onAppear {
                homeViewModel.startListening(pairID: pairID)
            }
            .onDisappear {
                homeViewModel.stopListening()
            }
        } else {
            PawLoadingView()
        }
    }
}

#Preview {
    MainTabView(viewModel: AuthViewModel())
}
