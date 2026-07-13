//
//  StorageService.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 13.07.2026.
//

import Foundation
import FirebaseStorage

class StorageService {
    func uploadImage(data: Data, path: String) async throws -> URL {
        if data.count > 5 * 1024 * 1024 {
            throw StorageError.fileTooLarge
        }
        do{
            let storageRef = Storage.storage().reference(withPath: path)
            _ = try await storageRef.putDataAsync(data)
            let url = try await storageRef.downloadURL()
            
            return url
        } catch{
            throw StorageError.uploadFailed
        }
    }
}
enum StorageError: Error {
    case fileTooLarge
    case uploadFailed
}
