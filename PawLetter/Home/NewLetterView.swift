//
//  NewLetterView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 10.07.2026.
//

import SwiftUI

struct NewLetterView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showError: Bool = false
    var pairID: String
    var authorID: String
    var letterServices = LetterServices()
    
    @State private var text: String = ""
    @FocusState private var isInputActive: Bool
    
    var body: some View {
        NavigationStack{
            Form{
                TextEditor(text: $text)
                    .focused($isInputActive)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                isInputActive = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction){
                            Button("Send"){
                                Task{
                                    do{
                                        try await letterServices.sendLetter(pairID: pairID, authorID: authorID, text: text)
                                        dismiss()
                                    } catch {
                                        showError = true
                                    }
                                }
                            }
                            .disabled(text.isEmpty)
                        }
                    }
                    .alert("Error", isPresented: $showError) {
                        Button("OK") {}
                    } message: {
                        Text("Something went wrong. Your message was not sent.")
                    }
            }
        }
    }
}

#Preview {
    NewLetterView(pairID: "qJ23Kdi6EMFLYmtnWgiD", authorID: "3z34vv")
}
