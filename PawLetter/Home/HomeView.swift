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
    @State private var currentUserID: String?
    var homeViewModel: HomeViewModel
    var pairID: String
    
    var body: some View {
        NavigationStack{
            List(homeViewModel.letters) { letter in
                NavigationLink(value: letter) {
                HStack {
                    Group {
                        if let id = letter.id, let image = homeViewModel.loadedImages[id] {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Image(systemName: letter.authorID == currentUserID ? "paperplane.fill" : "envelope.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    VStack(alignment: .leading) {
                        Text(letter.subject)
                            .fontWeight(letter.isRead ? .regular : .bold)
                        Text(letter.text)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        if letter.authorID == currentUserID {
                            Text("You")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Text(letter.formattedDate)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
                .onAppear {
                    Task { await homeViewModel.loadImageIfNeeded(for: letter) }
                }
            }
            .toolbar{
                Button("Add new list", systemImage: "plus"){
                    isShowingNewLetter = true
                }
            }
            .sheet(isPresented: $isShowingNewLetter) {
                if let  currentUserID {
                    NewLetterView(pairID: pairID, authorID: currentUserID)
                }
            }
            .task {
                currentUserID = Auth.auth().currentUser?.uid
            }
            .navigationDestination(for: Letter.self) { letter in
                LetterDetailView(letter: letter, pairID: pairID)
            }
            .navigationTitle("Your lists")
        }
    }
}

#Preview {
    HomeView(homeViewModel: HomeViewModel(), pairID: "qJ23Kdi6EMFLYmtnWgiD")
}
