//
//  MapViewModelTests.swift
//  PawLetterTests
//
//  Created by Nazar Dydyn on 10.09.2026.
//

import Foundation
import MapKit
import Testing
@testable import PawLetter

@MainActor
struct MapViewModelTests {

    @Test func toggleFilter_select_withPhotos() {
        let viewModel = MapViewModel()
        
        viewModel.toggleFilter(.withPhotos)
        #expect(viewModel.selectedFilters == [.withPhotos])
    }
    
    @Test func filteredLetters_returnsAll() {
        let letter1 = Letter(authorID: "nazar", subject: "nastia, do you love me?", createdAt: .now)
        let letter2 = Letter(authorID: "nastia", subject: "yes, i do", createdAt: .now)
        
        let viewModel = MapViewModel()
        let letterFiltered = viewModel.filteredLetters(from: [letter1, letter2])
        
        #expect(letterFiltered.count == 2)
    }
    
    @Test func filteredLetters_returnsNothing() {
        let letter1 = Letter(authorID: "nazar", subject: "nastia, do you love me?", createdAt: .now)
        let letter2 = Letter(authorID: "nastia", subject: "yes, i do", createdAt: .now)
        
        let viewModel = MapViewModel()
        viewModel.selectedFilters = []
        
        let letterFiltered = viewModel.filteredLetters(from: [letter1, letter2])
        
        #expect(letterFiltered.count == 0)
    }
    
    @Test func filteredLetters_returnsSelected() {
        let letter1 = Letter(authorID: "nazar", subject: "nastia, do you love me?", createdAt: .now, photoURL: "https://example.com/photo.jpg")
        let letter2 = Letter(authorID: "nastia", subject: "yes, i do", createdAt: .now, photoURL: nil)
        
        let viewModel = MapViewModel()
        viewModel.selectedFilters = [.withPhotos]
        
        let letterFiltered = viewModel.filteredLetters(from: [letter1, letter2])
        
        #expect(letterFiltered.count == 1)
        #expect(letterFiltered.first?.subject == "nastia, do you love me?")
        #expect(letterFiltered.first?.photoURL != nil)
    }
    
    @Test func nearbyCount_noUserLocation_returnsNil() {
        let viewModel = MapViewModel()
        let locationService = LocationService()
        
        let result = viewModel.nearbyCount(from: [], locationService)
        
        #expect(result == nil)
    }
    
    @Test func nearbyCount_withUserLocation_returnsCount() {
        let closeLocation = Letter.LetterLocation(placeName: nil, latitude: 49.8397, longitude: 24.0297)
        let distantLocation = Letter.LetterLocation(placeName: nil ,latitude: 50.4501, longitude: 30.5234)
        
        let letter1 = Letter(authorID: "nazar", subject: "close letter", createdAt: .now, location: closeLocation)
        let letter2 = Letter(authorID: "nastia", subject: "yes, i do", createdAt: .now, location: distantLocation)
        
        let viewModel = MapViewModel()
        
        let locationService = LocationService()
        locationService.userLocation = CLLocationCoordinate2D(latitude: 49.8397, longitude: 24.0297)
        
        let nearbyCount = viewModel.nearbyCount(from: [letter1, letter2], locationService)
        
        #expect(nearbyCount == 1)
    }

}
