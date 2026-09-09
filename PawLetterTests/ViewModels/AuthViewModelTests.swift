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
        mockUserService.profileToReturn = (inviteCode: nil, avatarURL: nil, displayName: "Nazar", pairID: nil, partnerNickname: nil)
        
        let viewModel = AuthViewModel(userServices: mockUserService, pairServices: mockPairService)
        
        await viewModel.loadUserData(uid: "test")
        
        #expect(viewModel.pairID == nil)
        #expect(viewModel.displayName == "Nazar")
        #expect(viewModel.partnerDisplayName == nil)
        #expect(viewModel.isLoadingPairID == false)
    }
    
    

}
