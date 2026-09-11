//
//  ProfileViewModel.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 13.07.2026.
//

import PhotosUI
import Foundation
import FirebaseAuth
import SwiftUI

@Observable
class ProfileViewModel{
    let storageService: StorageServiceProtocol
    
    var avatarURL: URL?
    var previewImage: UIImage?
    var isLoading: Bool = false
    var showError: Bool = false
    var errorMessage: String = ""
    
    var inviteCode: String?
    let userServices: UserServiceProtocol
    let pairServices: PairServiceProtocol
    
    init(storageService: StorageServiceProtocol = StorageService(), userServices: UserServiceProtocol = UserServices(), pairServices: PairServiceProtocol = PairServices()){
        self.storageService = storageService
        self.userServices = userServices
        self.pairServices = pairServices
    }
    
    var pair: Pair?
    
    func loadAndUpload(item: PhotosPickerItem) async {
        isLoading = true
        defer {isLoading = false}
        
        do{
            let data = try await item.loadTransferable(type: Data.self)
            
            guard let data else{
                errorMessage = "Something went wrong with convertation"
                showError = true
                return
            }
            guard let image = UIImage(data: data) else{
                errorMessage = "Something went wrong with image"
                showError = true
                return
            }
            previewImage = image
            
            do{
                guard let compression = image.jpegData(compressionQuality: 0.7)  else {
                    errorMessage = "Something went wrong with compression"
                    showError = true
                    return
                }
                    guard let id = Auth.auth().currentUser?.uid else {
                        errorMessage = "Something went wrong with authentication"
                        showError = true
                        return
                    }
                    let uploadedURL = try await storageService.uploadFile(data: compression, path: "avatars/\(id).jpg")
                    avatarURL = uploadedURL
                    try await userServices.updateAvatarURL(uid: id, url: uploadedURL.absoluteString)
                    errorMessage = ""
                    showError = false
                }
            } catch StorageError.fileTooLarge {
                errorMessage = "File is too large"
                showError = true
            } catch StorageError.uploadFailed{
                errorMessage = "Something went wrong with upload"
                showError = true
            }
         catch {
            errorMessage = "Data could not be loaded"
            showError = true
        }
    }
    func loadProfile() async {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "NO USER"
            showError = true
            return
        }
        do {
            let profile = try await userServices.fetchUserProfile(uid: user.uid)
            inviteCode = profile.inviteCode ?? "NIL CODE"
            if let temp = profile.avatarURL {
                avatarURL =  URL(string: temp)
            }
            
        } catch {
            errorMessage = "ERROR: \(error.localizedDescription)"
            showError = true
        }
    }
    func loadPair(pairID: String?) async {
        guard let pID = pairID else { return }
        do{
            pair = try await pairServices.fetchPair(pairID: pID)
        } catch {
            errorMessage = "ERROR: \(error.localizedDescription)"
            showError = true
        }
    }
}class ListNode {
         var val: Int
         var next: ListNode?
        init(_ val: Int) {
             self.val = val
             self.next = nil
         }
     }
class Solution {
    func mergeTwoLists(_ list1: ListNode?, _ list2: ListNode?) -> ListNode? {
        var list = list1 + list2
    }
