//
//  MockStorageService.swift
//  PawLetterTests
//
//  Created by Nazar Dydyn on 08.09.2026.
//

import Foundation
@testable import PawLetter

class MockStorageService: StorageServiceProtocol {
    var errorToThrow: Error?
    
    func uploadFile(data: Data, path: String) async throws -> URL {
        if let error = errorToThrow {
            throw error
        } else {
            URL(string: "https://fake.com/\(path)")!
        }
    }
    func deleteFile(path: String) async throws {
        
    }
}
