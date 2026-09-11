//
//  ProfileViewModelTests.swift
//  PawLetterTests
//
//  Created by Nazar Dydyn on 11.09.2026.
//

import Foundation
import Testing

@testable import PawLetter

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

}
