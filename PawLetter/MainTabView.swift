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
            TabView{
                // pairID гарантовано не nil тут, бо ContentView перевіряє це перед показом MainTabView
                HomeView(homeViewModel: homeViewModel, pairID: viewModel.pairID!)
                    .tabItem{
                        Label("Home", systemImage: "house")
                    }
                CalendarView(letters: homeViewModel.letters)
                    .tabItem{
                        Label("Calendar", systemImage: "calendar")
                    }
                ProfileView(viewModel: viewModel)
                    .tabItem{
                        Label("Profile", systemImage: "person")
                    }
            }
            .onAppear {
                homeViewModel.startListening(pairID: viewModel.pairID!)
        }
    }
}

#Preview {
    MainTabView(viewModel: AuthViewModel())
}
