//
//  NewLetterViewModelTests.swift
//  PawLetterTests
//
//  Created by Nazar Dydyn on 08.09.2026.
//

import Foundation
import Testing
@testable import PawLetter

@MainActor
struct NewLetterViewModelTests {
    @Test func send_newLetter_textOnly_callsSendLetterWithCorrectSubject() async {
        let mockLetterServices = MockLetterServices()
        let mockStorageService = MockStorageService()
        let viewModel = NewLetterViewModel(storageService: mockStorageService, letterServices: mockLetterServices)
        
        viewModel.subject = "Hello"
        viewModel.text = "Test message"
        viewModel.inputMode = .text
        
        await viewModel.send(pairID: "pair123", authorID: "user1", recordingURL: nil, location: nil)
        
        #expect(mockLetterServices.sendLetterCalled == true)
        #expect(mockLetterServices.sendLetterSubject == "Hello")
        #expect(mockLetterServices.sendLetterText == "Test message")
        #expect(viewModel.isSuccess == true)
    }
    
    @Test func send_editExistingLetter_noChanges_doesNotCallUpdateLetter() async {
        let mockLetterServices = MockLetterServices()
        let mockStorageService = MockStorageService()
        let existingLetter = Letter(id: "123456789", authorID: "user1", subject: "Hello", text: "", createdAt: .now)
        let viewModel = NewLetterViewModel(existingLetter: existingLetter, storageService: mockStorageService, letterServices: mockLetterServices)
        
        await viewModel.send(pairID: "pair123", authorID: "user1", recordingURL: nil, location: nil)
        
        #expect(mockLetterServices.updateLetterCalled == false)
    }
}
