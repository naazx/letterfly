//
//  AuthViewModelTests.swift
//  PawLetterTests
//
//  Created by Nazar Dydyn on 09.09.2026.
//

import Foundation
import Testing
@testable import Letterfly

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
    
    @Test func mapError_noInternetError_returnsNoInternet() async {
        let viewModel = AuthViewModel()
        let error = NSError(domain: NSURLErrorDomain,code: NSURLErrorNotConnectedToInternet)
        
        let result = viewModel.mapError(error)
        
        #expect(result == .noInternet)
    }
    
    @Test func mapError_unknownError_returnsUnknownError() async {
        let viewModel = AuthViewModel()
        let error = NSError(domain: "custom",code: 123, userInfo: [NSLocalizedDescriptionKey: "nazar loves nastia"])
        
        let result = viewModel.mapError(error)
        
        #expect(result?.localizedDescription == "nazar loves nastia")
    }

    @Test func loadUserData_clearsOldPartnerWhenNewProfileHasNoPair() async {
        let users = MockUserServices()
        users.profilesByUID["paired"] = (nil, nil, "Nazar", "pair-1", nil)
        users.profilesByUID["single"] = (nil, nil, "Nazar", nil, nil)
        let pairs = MockPairServices()
        pairs.partnerID = "partner"
        users.profilesByUID["partner"] = (nil, nil, "Partner", nil, nil)
        let viewModel = AuthViewModel(userServices: users, pairServices: pairs)

        await viewModel.loadUserData(uid: "paired")
        await viewModel.loadUserData(uid: "single")

        #expect(viewModel.pairID == nil)
        #expect(viewModel.partnerDisplayName == nil)
    }

    @Test func loadUserData_pairWithoutPartnerClearsPartnerName() async {
        let users = MockUserServices()
        users.profilesByUID["me"] = (nil, nil, "Nazar", "pair-1", nil)
        users.profilesByUID["oldPartner"] = (nil, nil, "Old", nil, nil)
        let pairs = MockPairServices()
        pairs.partnerID = "oldPartner"
        let viewModel = AuthViewModel(userServices: users, pairServices: pairs)

        await viewModel.loadUserData(uid: "me")
        pairs.partnerID = nil
        await viewModel.loadUserData(uid: "me")

        #expect(viewModel.partnerDisplayName == nil)
    }

    @Test func loadUserData_fetchFailureEndsLoadingState() async {
        let users = MockUserServices()
        users.fetchProfileError = NSError(domain: "test", code: 1)
        let viewModel = AuthViewModel(userServices: users, pairServices: MockPairServices())
        viewModel.isLoadingPairID = true

        await viewModel.loadUserData(uid: "me")

        #expect(!viewModel.isLoadingPairID)
    }

    @Test func loadUserData_fetchesCurrentAndPartnerProfiles() async {
        let users = MockUserServices()
        users.profilesByUID["me"] = (nil, nil, "Nazar", "pair-1", nil)
        users.profilesByUID["partner"] = (nil, nil, "Partner", nil, nil)
        let pairs = MockPairServices()
        pairs.partnerID = "partner"
        let viewModel = AuthViewModel(userServices: users, pairServices: pairs)

        await viewModel.loadUserData(uid: "me")

        #expect(users.fetchedProfileUIDs == ["me", "partner"])
    }

}
