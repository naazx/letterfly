//
//  AuthViewModel.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 27.06.2026.
//

import Foundation
import FirebaseAuth

@Observable
class AuthViewModel {
    var isLogged: Bool = false
    
    init(){
        if Auth.auth().currentUser != nil
        {
            isLogged = true
        }
    }
    
    func signIn(email: String, password: String) async {
        do{
            try await Auth.auth().signIn(withEmail: email , password:password)
        }
        catch{
            print("Error: \(error.localizedDescription)")
                    return
        }
        isLogged = true
    }
    func signUp(email: String, password: String) async {
        do{
            try await Auth.auth().createUser(withEmail: email, password: password)
        }
        catch{
            print("Error: \(error.localizedDescription)")
                    return
        }
        isLogged = true
    }
    func resetPassword(email: String) async {
        do{
            try await Auth.auth().sendPasswordReset(withEmail: email)
        }
        catch{
            print("Error: \(error.localizedDescription)")
                    return
        }
    }
}
