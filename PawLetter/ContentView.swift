//
//  ContentView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 27.06.2026.
//

import SwiftUI

struct ContentView: View {
    
    @State private var viewModel = AuthViewModel()
    
    var body: some View {
        if viewModel.isLogged && viewModel.pairID == nil{
            PairView(viewModel: viewModel)
        }
        else if viewModel.isLogged && viewModel.pairID != nil{
            MainTabView(viewModel: viewModel)
        }
        else{
            AuthView(viewModel: viewModel)
        }
            
    }
}

#Preview {
    ContentView()
}
