//
//  ContentView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 27.06.2026.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("appTheme") private var appTheme: Int = 0
    @State private var authViewModel = AuthViewModel()
    
    var body: some View {
        
        if authViewModel.isLoadingPairID{
            ProgressView()
        }
        else if authViewModel.isLogged == false{
            AuthView(viewModel: authViewModel)
                .preferredColorScheme(selectedColorScheme)
        }
        else if authViewModel.displayName == nil{
            NameSetupView(authViewModel: authViewModel)
                .preferredColorScheme(selectedColorScheme)
        }
        else if authViewModel.pairID == nil{
            PairView(viewModel: authViewModel)
                .preferredColorScheme(selectedColorScheme)
        }
        else{
            MainTabView(viewModel: authViewModel)
                .preferredColorScheme(selectedColorScheme)
        }
    }
    private var selectedColorScheme: ColorScheme? {
        switch appTheme{
        case 1:
            return .light
        case 2:
            return .dark
        default:
            return nil // system
        }
    }
}

#Preview {
    ContentView()
}
