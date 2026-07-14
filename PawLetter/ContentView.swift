//
//  ContentView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 27.06.2026.
//

import SwiftUI

struct ContentView: View {
    
    @State private var authViewModel = AuthViewModel()
    
    var body: some View {
        
        if authViewModel.isLoadingPairID{
            ProgressView()
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
}

#Preview {
    ContentView()
}
