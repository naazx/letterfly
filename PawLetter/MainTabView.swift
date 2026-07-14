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
        guard let pairID = viewModel.pairID else {
                return AnyView(ProgressView())
            }
        return AnyView(
            TabView{
                HomeView(homeViewModel: homeViewModel, pairID: pairID)
                    .tabItem{
                        Label("Home", systemImage: "house")
                    }
                CalendarView(letters: homeViewModel.letters)
                    .tabItem{
                        Label("Calendar", systemImage: "calendar")
                    }
                ProfileView(authViewModel: viewModel)
                    .tabItem{
                        Label("Profile", systemImage: "person")
                    }
            }
            .onAppear {
                homeViewModel.startListening(pairID: pairID)
        }
            )
    }
}

#Preview {
    MainTabView(viewModel: AuthViewModel())
}
