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
    var text: String? 
    var letterServices = LetterServices()
    var previewImage: UIImage?
    
    var showError: Bool = false
    var errorMessage: String = ""
    var isSuccess: Bool = false
    
    var existingLetter: Letter?
    var didRemovePhoto: Bool = false
    
    var mood: MoodType?
    var surprise: SurpriseType?
    
    enum InputMode: CaseIterable{
        case text
        case voice
    }
    var inputMode: InputMode = .text
    
    init(existingLetter: Letter? = nil) {
        self.existingLetter = existingLetter
        self.subject = existingLetter?.subject ?? ""
        self.text = existingLetter?.text ?? ""
        self.mood = existingLetter?.mood
        self.surprise = existingLetter?.surprise
        if existingLetter?.audioURL != nil {
            inputMode = .voice
        } else {
            inputMode = .text
        }
    }
    
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
            let uploadedURL = try await storageService.uploadFile(data: compression, path:                                     "letterPhotos/\(pairID)/\(letterID).jpg")
        
            return uploadedURL.absoluteString
    }
    func send(pairID: String, authorID: String, selectedItem: PhotosPickerItem?, recordingURL: URL?) async {
        isLoading = true
        defer{ isLoading = false }
        
        do{
            if let existingLetter {
                guard let letterID = existingLetter.id else {return}
                var photoURL = existingLetter.photoURL
                var audioURL = existingLetter.audioURL
                
                if didRemovePhoto == true{
                    try await storageService.deleteFile(path: "letterPhotos/\(pairID)/\(letterID).jpg")
                    photoURL = nil
                    
                } else if let selectedItem{
                    photoURL = try await uploadPhoto(item: selectedItem, pairID: pairID, letterID: letterID)
                }
                
                if inputMode == .text && existingLetter.audioURL != nil {
                    try await storageService.deleteFile(path: "letterAudio/\(pairID)/\(letterID).m4a")
                    audioURL = nil
                }
                if inputMode == .voice, let recordingURL {
                    if existingLetter.audioURL != nil {
                        try await storageService.deleteFile(path: "letterAudio/\(pairID)/\(letterID).m4a")
                    }
                    audioURL = try await uploadAudio(url: recordingURL, pairID: pairID, letterID: letterID)
                }
                
                let hasChanges = subject != existingLetter.subject
                        || text != existingLetter.text
                        || photoURL != existingLetter.photoURL
                        || audioURL != existingLetter.audioURL
                        || mood != existingLetter.mood
                        || surprise != existingLetter.surprise

                    if hasChanges {
                        try await letterServices.updateLetter(pairID: pairID, letterID: letterID, subject: subject, text: text, photoURL: photoURL, audioURL: audioURL, mood: mood, surprise: surprise)
                    }
                
            } else {
                let reference = letterServices.newLetterReference(pairID: pairID)
                var photoURL: String? = nil
                var audioURL: String? = nil

                if let selectedItem {
                    photoURL = try await uploadPhoto(item: selectedItem, pairID: pairID, letterID: reference.documentID)
                }
                if inputMode == .voice, let recordingURL {
                    audioURL = try await uploadAudio(url: recordingURL, pairID: pairID, letterID: reference.documentID)
                }
                try await letterServices.sendLetter(authorID: authorID, subject: subject, text: inputMode == .text ? text : nil, photoURL: photoURL, audioURL: audioURL, reference: reference, mood: mood, surprise: surprise)
            }
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
    func loadExistingPhoto() async {
        guard let photoURLString = existingLetter?.photoURL,
              let url = URL(string: photoURLString) else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return }
            previewImage = image
        } catch {}
    }
    func uploadAudio(url: URL, pairID: String, letterID: String) async throws -> String? {
        isLoading = true
        defer { isLoading = false }
        
        let data = try Data(contentsOf: url)
        let uploadedURL = try await storageService.uploadFile(data: data, path: "letterAudio/\(pairID)/\(letterID).m4a")
        
        return uploadedURL.absoluteString
    }
}
enum UploadError : Error {
    case dataConvertation, imageConvertation, imageCompression
}
