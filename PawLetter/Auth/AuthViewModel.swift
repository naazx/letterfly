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
    let pairServices = PairServices()
    var pairID: String?
    var displayName: String?
    var isLoadingPairID: Bool = false
    var partnerNickname: String?
    var partnerDisplayName: String?
    
    init(){
        if let currentUser = Auth.auth().currentUser {
            isLogged = true
            let userID = currentUser.uid
            isLoadingPairID = true
            Task{
                await loadUserData(uid: userID)
            }
        }
    }
    func signIn(email: String, password: String) async {
        do{
            try await Auth.auth().signIn(withEmail: email , password:password)
            let userID = Auth.auth().currentUser!.uid
            await loadUserData(uid: userID)
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
            displayName = nil
            partnerNickname = nil
            partnerDisplayName = nil
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
    func loadUserData(uid: String) async {
        do {
            let profile = try await userServices.fetchUserProfile(uid: uid)
            pairID = profile.pairID
            displayName = profile.displayName
            partnerNickname = profile.partnerNickname
            
            if let pairID = profile.pairID {
                if let partnerID = try await pairServices.fetchPartnerID(pairID: pairID, myUID: uid) {
                    let partnerProfile = try await userServices.fetchUserProfile(uid: partnerID)
                    partnerDisplayName = partnerProfile.displayName
                }
            }
        } catch {
            print("error: \(error.localizedDescription)")
        }
        isLoadingPairID = false
    }
    func saveDisplayName(_ name: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            try await userServices.updateDisplayName(uid: uid, name: name)
            displayName = name
        } catch {
            print("error: \(error.localizedDescription)")
        }
    }
    func savePartnerNickname(_ nickname: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            try await userServices.updatePartnerNickname(uid: uid, nickname: nickname)
            partnerNickname = nickname
        } catch {
            print("error: \(error.localizedDescription)")
        }
    }
}
