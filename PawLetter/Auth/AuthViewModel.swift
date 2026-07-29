//
//  AuthViewModel.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 27.06.2026.
//

import Foundation
import FirebaseAuth
import AuthenticationServices
import GoogleSignIn
import UIKit
import FirebaseCore

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
    
    var authError: AuthError?
    
    enum AuthError: LocalizedError, Equatable{
        case noInternet, unknown(String)
        
        var errorDescription: String? {
            switch self {
            case .noInternet:
                return "No Internet connection"
            case .unknown(let message):
                return message
            }
        }
    }
    
    func mapError(_ error: Error) -> AuthError? {
        if (error as? ASAuthorizationError)?.code == .canceled {
            return nil
        } else if (error as NSError).code == GIDSignInError.canceled.rawValue{
            return nil
        } else if (error as NSError).domain == NSURLErrorDomain && (error as NSError).code == NSURLErrorNotConnectedToInternet {
            return .noInternet
        } else {
            return .unknown(error.localizedDescription)
        }
    }

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
    func signInWithGoogle() async {
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                print("error: відсутній clientID у Firebase-конфігурації")
                return
            }
    
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
    
            guard let rootViewController = Self.topViewController() else {
                print("error: не вдалося знайти root view controller для презентації Google Sign-In")
                return
            }
    
            do {
                let googleResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
    
                guard let idToken = googleResult.user.idToken?.tokenString else {
                    print("error: Google не повернув idToken")
                    return
                }
                let accessToken = googleResult.user.accessToken.tokenString
    
                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: accessToken
                )
    
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
                let mapError = mapError(error)
                if let mapError{
                    authError = mapError
                }
            }
        }
    
        @MainActor
        private static func topViewController(_ base: UIViewController? = nil) -> UIViewController? {
            let base = base ?? UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }?
                .rootViewController
    
            if let nav = base as? UINavigationController {
                return topViewController(nav.visibleViewController)
            }
            if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
                return topViewController(selected)
            }
            if let presented = base?.presentedViewController {
                return topViewController(presented)
            }
            return base
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
                let mapError = mapError(error)
                if let mapError{
                    authError = mapError
                }
            }

        case .failure(let error):
            let mapError = mapError(error)
            if let mapError{
                authError = mapError
            }
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
