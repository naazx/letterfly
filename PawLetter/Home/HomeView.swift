//
//  HomeView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 10.07.2026.
//
import FirebaseAuth
import SwiftUI

struct HomeView: View {
    @State private var homeViewModel = HomeViewModel()
    @State private var isShowingNewLetter: Bool = false
    var pairID: String
    
    var body: some View {
        NavigationStack{
            List(homeViewModel.letters) { letter in
                Text(letter.text)
            }
            .onAppear {
                homeViewModel.startListening(pairID: pairID)
            }
            .toolbar{
                Button("Add new list", systemImage: "plus"){
                    isShowingNewLetter = true
                }
            }
            .sheet(isPresented: $isShowingNewLetter) {
                if let  currentUser = Auth.auth().currentUser?.uid {
                    NewLetterView(pairID: pairID, authorID: currentUser)
                }
            }
        }
    }
}

#Preview {
    HomeView(pairID: "qJ23Kdi6EMFLYmtnWgiD")
}
