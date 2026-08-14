//
//  MainTabView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 09.07.2026.
//

import MapKit
import SwiftUI

struct MainTabView: View {
    @State private var homeViewModel = HomeViewModel()
    @State private var selectedTab: AppTab = .home
    @State private var mapFocusCoordinate: CLLocationCoordinate2D?
    var viewModel: AuthViewModel
    
    enum AppTab: Hashable {
        case home, calendar, memories, profile
    }
    
    var body: some View {
        if let pairID = viewModel.pairID {
            TabView(selection: $selectedTab) {
                HomeView(homeViewModel: homeViewModel, pairID: pairID, currentUserID: viewModel.userID, partnerName: viewModel.partnerNickname ?? viewModel.partnerDisplayName, onOpenLocationInMap: { coordinate in
                    mapFocusCoordinate = coordinate
                    selectedTab = .memories
                })
                    .tabItem {
                        Label("Home", systemImage: "house")
                            .labelStyle(.iconOnly)
                    }
                    .tag(AppTab.home)
                
                CalendarView(letters: homeViewModel.letters, pairID: pairID, currentUserID: viewModel.userID, partnerName: viewModel.partnerNickname ?? viewModel.partnerDisplayName, homeViewModel: homeViewModel, onOpenLocationInMap: { coordinate in
                    mapFocusCoordinate = coordinate
                    selectedTab = .memories
                })
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                            .labelStyle(.iconOnly)
                    }
                    .tag(AppTab.calendar)
                
                MapView(focusCoordinate: $mapFocusCoordinate, letters: homeViewModel.letters, pairID: pairID, currentUserID: viewModel.userID, partnerName: viewModel.partnerNickname ?? viewModel.partnerDisplayName )
                    .tabItem {
                        Label("Memories", systemImage: "map")
                            .labelStyle(.iconOnly)
                    }
                    .tag(AppTab.memories)
                
                ProfileView(authViewModel: viewModel, homeViewModel: homeViewModel)
                    .tabItem {
                        Label("Profile", systemImage: "person")
                            .labelStyle(.iconOnly)
                    }
                    .tag(AppTab.profile)
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
