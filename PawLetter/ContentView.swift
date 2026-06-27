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
        if viewModel.isLogged{
            Text("Nastia is so hungry")
        }
        else{
            AuthView(viewModel: viewModel)
        }
            
    }
}

#Preview {
    ContentView()
}
