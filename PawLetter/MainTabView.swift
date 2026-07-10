//
//  MainTabView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 09.07.2026.
//

import SwiftUI

struct MainTabView: View {
    var viewModel: AuthViewModel
    
    var body: some View {
        TabView{
            // pairID гарантовано не nil тут, бо ContentView перевіряє це перед показом MainTabView
            HomeView(pairID: viewModel.pairID!)
                .tabItem{
                    Label("Home", systemImage: "house")
                }
            CalendarView()
                .tabItem{
                    Label("Calendar", systemImage: "calendar")
                }
            ProfileView(viewModel: viewModel)
                .tabItem{
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

#Preview {
    MainTabView(viewModel: AuthViewModel())
}
