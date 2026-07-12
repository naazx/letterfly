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
    let userServices = UserServices()
    var pairID: String?
    var isLoadingPairID: Bool = false
    
    init(){
        if let currentUser = Auth.auth().currentUser {
            isLogged = true
            let userID = currentUser.uid
            isLoadingPairID = true
            Task{
                await loadPairID(uid: userID)
            }
        }
    }
    
    func signIn(email: String, password: String) async {
        do{
            try await Auth.auth().signIn(withEmail: email , password:password)
            let userID = Auth.auth().currentUser!.uid
            await loadPairID(uid: userID)
        }
        catch{
            print("Error: \(error.localizedDescription)")
                    return
        }
        isLogged = true
    }
    func signUp(email: String, password: String) async {
        do{
           let createUser = try await Auth.auth().createUser(withEmail: email, password: password)
            let code =  try await userServices.generateUniqueInviteCode()
            
            let userID = createUser.user.uid
            try await userServices.createUserDocument(uid: userID, inviteCode: code)
        }
        catch{
            print("Error: \(error.localizedDescription)")
            // TODO: обробити випадок, коли Auth-юзер створений, а Firestore-документ - ні
            return
        }
        isLogged = true
    }
    func signOut(){
        do{
            try  Auth.auth().signOut()
            isLogged = false
            pairID = nil
        }catch{
            print("error: \(error.localizedDescription)")
        }
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
    func loadPairID(uid: String) async {
        do{
            pairID = try await userServices.fetchPairID(uid: uid)
        } catch {
            print("error: \(error.localizedDescription)")
        }
        isLoadingPairID = false
    }
}
