//
//  NewLetterViewModel.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 15.07.2026.
//

import PhotosUI
import Foundation
import FirebaseFirestore
import SwiftUI

@Observable
class NewLetterViewModel {
    var storageService = StorageService()
    var isLoading: Bool = false
    var subject: String = ""
    var text: String = ""
    var letterServices = LetterServices()
    var previewImage: UIImage?
    
    var showError: Bool = false
    var errorMessage: String = ""
    var isSuccess: Bool = false
    
    func uploadPhoto(item: PhotosPickerItem, pairID: String, letterID: String) async throws -> String? {
        isLoading = true
        defer {isLoading = false}
        
            let data = try await item.loadTransferable(type: Data.self)
            
            guard let data else{
                throw UploadError.dataConvertation
            }
            guard let image = UIImage(data: data) else{
                throw UploadError.imageConvertation
            }
            previewImage = image
            
            guard let compression = image.jpegData(compressionQuality: 0.7)  else {
                throw UploadError.imageCompression
            }
            let uploadedURL = try await storageService.uploadImage(data: compression, path:                                     "letterPhotos/\(pairID)/\(letterID).jpg")
        
            return uploadedURL.absoluteString
    }
    func send(pairID: String, authorID: String, selectedItem: PhotosPickerItem?) async {
        isLoading = true
        defer{ isLoading = false }
        
        var photoURL: String?
        
        do{
            let reference = letterServices.newLetterReference(pairID: pairID)
            
            if let selectedItem {
                photoURL = try await uploadPhoto(item: selectedItem, pairID: pairID, letterID: reference.documentID)
            }
            try await letterServices.sendLetter(authorID: authorID, subject: subject, text: text, photoURL: photoURL, reference: reference)
            isSuccess = true
            
        } catch let error as UploadError{
            switch error {
               case .dataConvertation:
                   errorMessage = "Could not process photo."
               case .imageConvertation:
                   errorMessage = "Image recognition failed"
               case .imageCompression:
                   errorMessage = "Could not compress photo"
               }
               showError = true
        } catch let error as StorageError{
            switch error {
            case .uploadFailed:
                errorMessage = "Could not upload photo"
            case .fileTooLarge:
                errorMessage = "Photo is too big"
            case .deletionFailed:
                errorMessage = "Could not delete photo"
            }
            showError = true
        } catch {
            errorMessage = "Something went wrong"
            showError = true
        }
    }
}
enum UploadError : Error{
    case dataConvertation, imageConvertation, imageCompression
}
