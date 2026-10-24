//
//  MockStorageService.swift
//  PawLetterTests
//
//  Created by Nazar Dydyn on 08.09.2026.
//

import Foundation
@testable import Letterfly

class MockStorageService: StorageServiceProtocol {
    var errorToThrow: Error?
    var deleteErrorToThrow: Error?
    private(set) var uploadedPaths: [String] = []
    private(set) var uploadedData: [Data] = []
    private(set) var deletedPaths: [String] = []
    
    func uploadFile(data: Data, path: String) async throws -> URL {
        uploadedPaths.append(path)
        uploadedData.append(data)
        if let error = errorToThrow {
            throw error
        } else {
            return URL(string: "https://fake.com/\(path)")!
        }
    }
    func deleteFile(path: String) async throws {
        deletedPaths.append(path)
        if let error = deleteErrorToThrow {
            throw error
        }
    }
}
