//
//  AuthViewModelTests.swift
//  PawLetterTests
//
//  Created by Nazar Dydyn on 09.09.2026.
//

import Foundation
import Testing
@testable import PawLetter

@MainActor
struct AuthViewModelTests {

    @Test func loadUserData_noPair_setsProfileWithoutPartner() async {
        let mockUserService = MockUserServices()
        let mockPairService = MockPairServices()
        mockUserService.profilesByUID["test"] = (nil, nil, "Nazar", nil, nil)
        
        let viewModel = AuthViewModel(userServices: mockUserService, pairServices: mockPairService)
        
        await viewModel.loadUserData(uid: "test")
        
        #expect(viewModel.pairID == nil)
        #expect(viewModel.displayName == "Nazar")
        #expect(viewModel.partnerDisplayName == nil)
        #expect(viewModel.isLoadingPairID == false)
    }
    
    @Test func loadUserData_withPair_setsPartnerDisplayName() async {
        let mockUserService = MockUserServices()
        let mockPairService = MockPairServices()
        
        mockUserService.profilesByUID["user1"] = (nil, nil, "Nazar", "pair123", nil)
        mockUserService.profilesByUID["partner1"] = (nil, nil, "Nastia", nil, nil)
        mockPairService.partnerID = "partner1"
        
        let viewModel = AuthViewModel(userServices: mockUserService, pairServices: mockPairService)
        
        await viewModel.loadUserData(uid: "user1")
        
        #expect(viewModel.pairID == "pair123")
        #expect(viewModel.displayName == "Nazar")
        #expect(viewModel.partnerDisplayName == "Nastia")
    }

}
