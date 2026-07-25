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
    let existingLetter: Letter?
    var pairID: String
    var authorID: String
    
    enum Field {
        case subject
        case letter
    }
    @FocusState private var focusedField: Field?
    
    init(existingLetter: Letter?, pairID: String, authorID: String){
        self.existingLetter = existingLetter
        self.pairID = pairID
        self.authorID = authorID
        _viewModel = State(initialValue: NewLetterViewModel(existingLetter: existingLetter))
    }
    
    var body: some View {
        NavigationStack{
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        
                        photoSection
                        
                        VStack(alignment: .leading, spacing: 10) {
                            
                            Text("TITLE")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.secondary)
                            
                            TextField("Birthday in the mountains", text: $viewModel.subject)
                                .focused($focusedField, equals: .subject)
                                .font(.title3.weight(.semibold))
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .letter
                                }
                            
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            
                            Text("LETTER")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.secondary)
                            
                            ZStack(alignment: .topLeading) {
                                if viewModel.text.isEmpty {
                                    Text("Write your letter...")
                                        .foregroundStyle(.tertiary)
                                        .padding(.top, 16)
                                        .padding(.leading, 14)
                                }
                                
                            TextEditor(text: $viewModel.text)
                                .focused($focusedField, equals: .letter)
                                .frame(minHeight: 260)
                                .padding(12)
                                .scrollContentBackground(.hidden)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .textInputAutocapitalization(.sentences)
                                .autocorrectionDisabled(false)
                        }
                    }
                }
                    .padding(20)
            }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            focusedField = nil
                        }
                    }
                    ToolbarItem(placement: .confirmationAction){
                        Button(existingLetter == nil ? "Send" : "Save"){
                            Task { await viewModel.send(pairID: pairID, authorID: authorID, selectedItem: selectedItem) }
                        }
                        .disabled(
                            viewModel.subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                            viewModel.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        )
                        .animation(.easeInOut(duration: 0.2),
                                   value: viewModel.subject)

                        .animation(.easeInOut(duration: 0.2),
                                   value: viewModel.text)
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
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
                .scrollDismissesKeyboard(.interactively)
                .navigationTitle(existingLetter == nil ? "New letter" : "Edit letter")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    private var photoSection: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {

            if let previewImage = viewModel.previewImage {

                Image(uiImage: previewImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 240)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .contentShape(RoundedRectangle(cornerRadius: 22))
                    .shadow(color: .black.opacity(0.12), radius: 10, y: 5)
                    .overlay(alignment: .topTrailing) {

                        if viewModel.previewImage != nil || existingLetter?.photoURL != nil {

                            Button {
                                viewModel.didRemovePhoto = true
                                selectedItem = nil
                                viewModel.previewImage = nil
                            } label: {
                                Image(systemName: "trash.circle.fill")
                                    .font(.title2)
                                    .symbolRenderingMode(.hierarchical)
                            }
                            .padding()
                        }

                    }
            } else {
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color(.secondarySystemBackground))
                    .frame(height: 240)
                    .overlay {

                        VStack(spacing: 12) {

                            Image(systemName: "photo.badge.plus")
                                .font(.largeTitle)

                            Text("Choose Photo")
                                .font(.headline)
                        }
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    NewLetterView(existingLetter: nil, pairID: "qJ23Kdi6EMFLYmtnWgiD", authorID: "3z34vv")
}
