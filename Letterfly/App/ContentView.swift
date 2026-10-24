//
//  ContentView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 27.06.2026.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("appTheme") private var appTheme: Int = 1
    @AppStorage("hasAcceptedTerms") private var hasAcceptedTerms: Bool = false
    @State private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            switch AppRoute.resolve(
                isLoadingPairID: authViewModel.isLoadingPairID,
                hasAcceptedTerms: hasAcceptedTerms,
                isLogged: authViewModel.isLogged,
                displayName: authViewModel.displayName,
                pairID: authViewModel.pairID
            ) {
            case .loading:
                LetterLoadingView()
            case .terms:
                TermsView(hasAcceptedTerms: $hasAcceptedTerms)
            case .authentication:
                AuthView(viewModel: authViewModel)
            case .nameSetup:
                NameSetupView(authViewModel: authViewModel)
            case .pairing:
                PairView(viewModel: authViewModel)
            case .main:
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
