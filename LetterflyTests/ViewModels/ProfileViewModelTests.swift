//
//  ProfileViewModelTests.swift
//  PawLetterTests
//
//  Created by Nazar Dydyn on 11.09.2026.
//

import Foundation
import Testing

@testable import Letterfly

@MainActor
struct ProfileViewModelTests {

    @Test func loadPair_withPairID() async {
        let mockPairServices = MockPairServices()
        mockPairServices.pair = Pair(id: "pair123", members: ["nazar", "nastia"], startDate: .now)
        let viewModel = ProfileViewModel(pairServices: mockPairServices)
        
        await viewModel.loadPair(pairID: "pair123")
        
        #expect(viewModel.pair?.id == "pair123")
    }
    
    @Test func loadPair_nilPairID_doesNotCallFetchPair() async {
        let mockPairServices = MockPairServices()
        mockPairServices.pair = Pair(id: "pair123", members: ["nazar", "nastia"], startDate: .now)
        let viewModel = ProfileViewModel(pairServices: mockPairServices)
        
        await viewModel.loadPair(pairID: nil)
        
        #expect(mockPairServices.fetchPairCalled == false)
        #expect(viewModel.pair == nil)
    }

    @Test func loadPair_passesRequestedIDToService() async {
        let services = MockPairServices()
        let viewModel = ProfileViewModel(pairServices: services)

        await viewModel.loadPair(pairID: "pair-42")

        #expect(services.fetchPairIDs == ["pair-42"])
    }

    @Test func loadPair_serviceReturnsNilLeavesPairEmpty() async {
        let viewModel = ProfileViewModel(pairServices: MockPairServices())

        await viewModel.loadPair(pairID: "missing")

        #expect(viewModel.pair == nil)
        #expect(!viewModel.showError)
    }

    @Test func loadPair_serviceFailureShowsError() async {
        let services = MockPairServices()
        services.fetchPairError = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "offline"])
        let viewModel = ProfileViewModel(pairServices: services)

        await viewModel.loadPair(pairID: "pair-1")

        #expect(viewModel.showError)
        #expect(viewModel.errorMessage.contains("offline"))
    }

    @Test func loadPair_nilClearsPreviouslyLoadedPair() async {
        let services = MockPairServices()
        services.pair = Pair(id: "pair-1", members: ["me", "partner"], startDate: .now)
        let viewModel = ProfileViewModel(pairServices: services)
        await viewModel.loadPair(pairID: "pair-1")

        await viewModel.loadPair(pairID: nil)

        #expect(viewModel.pair == nil)
    }

    @Test func loadPartnerUID_requiresBothIDs() async {
        let services = MockPairServices()
        let viewModel = ProfileViewModel(pairServices: services)

        await viewModel.loadPartnerUID(pairID: nil, myUID: "me")
        await viewModel.loadPartnerUID(pairID: "pair-1", myUID: nil)

        #expect(services.fetchPartnerCalls.isEmpty)
        #expect(viewModel.partnerUID == nil)
    }

    @Test func loadPartnerUID_storesPartnerFromService() async {
        let services = MockPairServices()
        services.partnerID = "partner-1"
        let viewModel = ProfileViewModel(pairServices: services)

        await viewModel.loadPartnerUID(pairID: "pair-1", myUID: "me")

        #expect(viewModel.partnerUID == "partner-1")
        #expect(services.fetchPartnerCalls.first?.pairID == "pair-1")
        #expect(services.fetchPartnerCalls.first?.myUID == "me")
    }

    @Test func loadPartnerUID_missingPairClearsPreviouslyLoadedPartner() async {
        let services = MockPairServices()
        services.partnerID = "partner-1"
        let viewModel = ProfileViewModel(pairServices: services)
        await viewModel.loadPartnerUID(pairID: "pair-1", myUID: "me")

        await viewModel.loadPartnerUID(pairID: nil, myUID: "me")

        #expect(viewModel.partnerUID == nil)
    }

    @Test func blockPartner_sendsIDsAndReturnsSuccess() async {
        let services = MockUserServices()
        let viewModel = ProfileViewModel(userServices: services)

        let result = await viewModel.blockPartner(myUID: "me", partnerUID: "partner", pairID: "pair-1")

        #expect(result)
        #expect(services.lastBlockRequest?.myUID == "me")
        #expect(services.lastBlockRequest?.partnerUID == "partner")
        #expect(services.lastBlockRequest?.pairID == "pair-1")
        #expect(!viewModel.showError)
    }

    @Test func blockPartner_serviceFailureReturnsFalseAndShowsError() async {
        let services = MockUserServices()
        services.blockPartnerError = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "denied"])
        let viewModel = ProfileViewModel(userServices: services)

        let result = await viewModel.blockPartner(myUID: "me", partnerUID: "partner", pairID: "pair-1")

        #expect(!result)
        #expect(viewModel.showError)
        #expect(viewModel.errorMessage.contains("denied"))
    }

}
