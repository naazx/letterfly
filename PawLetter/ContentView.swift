//
//  ContentView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 27.06.2026.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("appTheme") private var appTheme: Int = 1
    @State private var authViewModel = AuthViewModel()
    
    var body: some View {
        
        Group{
            if authViewModel.isLoadingPairID{
                PawLoadingView()
            }
            else if authViewModel.isLogged == false{
                AuthView(viewModel: authViewModel)
            }
            else if authViewModel.displayName == nil{
                NameSetupView(authViewModel: authViewModel)
            }
            else if authViewModel.pairID == nil{
                PairView(viewModel: authViewModel)
            }
            else{
                MainTabView(viewModel: authViewModel)
            }
        }
        .preferredColorScheme(selectedColorScheme)
    }
    private var selectedColorScheme: ColorScheme? {
        switch appTheme{
        case 1:
            return .light
        default:
            return .dark
        }
    }
}

#Preview {
    ContentView()
}
