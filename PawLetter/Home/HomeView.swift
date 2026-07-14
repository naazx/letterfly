//
//  HomeView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 10.07.2026.
//
import FirebaseAuth
import SwiftUI

struct HomeView: View {
    @State private var isShowingNewLetter: Bool = false
    var homeViewModel: HomeViewModel
    var pairID: String
    
    var body: some View {
        NavigationStack{
            List(homeViewModel.letters) { letter in
                HStack {
                       Text(letter.text)
                       Spacer()
                       Text(letter.formattedDate)
                   }
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
            .navigationTitle("Your lists")
        }
    }
}

#Preview {
    HomeView(homeViewModel: HomeViewModel(), pairID: "qJ23Kdi6EMFLYmtnWgiD")
}
