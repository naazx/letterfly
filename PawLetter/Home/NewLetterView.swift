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
    var pairID: String
    var authorID: String
    
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
                    Button("Send"){
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
            .navigationTitle("New letter")
        }
    }
}

#Preview {
    NewLetterView(pairID: "qJ23Kdi6EMFLYmtnWgiD", authorID: "3z34vv")
}
