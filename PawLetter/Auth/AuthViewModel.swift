//
//  AuthViewModel.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 27.06.2026.
//

import Foundation
import FirebaseAuth
import AuthenticationServices

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
    var userID: String?
    var currentNonce: String?

    init(){
        if let currentUser = Auth.auth().currentUser {
            isLogged = true
            let userIDlocal = currentUser.uid
            self.userID = userIDlocal
            isLoadingPairID = true
            Task{
                await loadUserData(uid: userIDlocal)
            }
        }
    }

    func prepareAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName]
        request.nonce = sha256(nonce)
    }

    func signInWithApple(result: Result<ASAuthorization, Error>) async {
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                print("error: не вдалося отримати ASAuthorizationAppleIDCredential")
                return
            }
            guard let nonce = currentNonce else {
                print("error: відсутній currentNonce — prepareAppleRequest не був викликаний")
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("error: Apple не повернув identityToken")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("error: не вдалося декодувати identityToken як UTF-8")
                return
            }

            let credential = OAuthProvider.credential(
                providerID: .apple,
                idToken: idTokenString,
                rawNonce: nonce
            )

            do {
                let authResult = try await Auth.auth().signIn(with: credential)
                let userIDlocal = authResult.user.uid
                self.userID = userIDlocal

                if authResult.additionalUserInfo?.isNewUser == true {
                    let code = try await userServices.generateUniqueInviteCode()
                    try await userServices.createUserDocument(uid: userIDlocal, inviteCode: code)
                }

                await loadUserData(uid: userIDlocal)
                isLogged = true
            } catch {
                print("error: \(error.localizedDescription)")
            }

        case .failure(let error):
            print("error: \(error.localizedDescription)")
        }
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
