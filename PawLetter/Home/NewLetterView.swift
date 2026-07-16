//
//  NewLetterView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 10.07.2026.
//

import PhotosUI
import SwiftUI

struct NewLetterView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = NewLetterViewModel()
    @State private var selectedItem: PhotosPickerItem?
    @FocusState private var isInputActive: Bool
    let existingLetter: Letter?
    var pairID: String
    var authorID: String
    
    init(existingLetter: Letter?, pairID: String, authorID: String){
        self.existingLetter = existingLetter
        self.pairID = pairID
        self.authorID = authorID
        _viewModel = State(initialValue: NewLetterViewModel(existingLetter: existingLetter))
    }
    
    var body: some View {
        NavigationStack{
            Form{
                Section{
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        if let previewImage = viewModel.previewImage {
                            Image(uiImage: previewImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            Label("Add Photo", systemImage: "photo.badge.plus")
                        }
                    }
                    if existingLetter?.photoURL != nil || viewModel.previewImage != nil{
                        Button("Remove Photo", role: .destructive){
                            viewModel.didRemovePhoto = true
                            selectedItem = nil
                            viewModel.previewImage = nil
                        }
                    }
                }
                
                Section{
                    TextField("Subject", text: $viewModel.subject)
                        .focused($isInputActive)
                    TextEditor(text: $viewModel.text)
                        .focused($isInputActive)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isInputActive = false
                    }
                }
                ToolbarItem(placement: .confirmationAction){
                    Button(existingLetter == nil ? "Send" : "Save"){
                        Task { await viewModel.send(pairID: pairID, authorID: authorID, selectedItem: selectedItem) }
                    }
                    .disabled(viewModel.text.isEmpty)
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .onChange(of: viewModel.isSuccess){ _, _ in
                dismiss()
            }
            .task {
                await viewModel.loadExistingPhoto()
            }
            .navigationTitle(existingLetter == nil ? "New letter" : "Edit letter")
        }
    }
}

#Preview {
    NewLetterView(existingLetter: nil, pairID: "qJ23Kdi6EMFLYmtnWgiD", authorID: "3z34vv")
}
