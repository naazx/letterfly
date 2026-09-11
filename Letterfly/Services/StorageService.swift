//
//  StorageService.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 13.07.2026.
//

import Foundation
import FirebaseStorage

protocol StorageServiceProtocol {
    func uploadFile(data: Data, path: String) async throws -> URL
    func deleteFile(path: String) async throws
}

class StorageService: StorageServiceProtocol {
    func uploadFile(data: Data, path: String) async throws -> URL {
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
    func deleteFile(path: String) async throws {
        do {
            let storageRef = Storage.storage().reference(withPath: path)
            try await storageRef.delete()
        } catch {
            throw StorageError.deletionFailed
        }
    }
}
enum StorageError: Error {
    case fileTooLarge
    case uploadFailed
    case deletionFailed
}
