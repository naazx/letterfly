//
//  MapViewModelTests.swift
//  PawLetterTests
//
//  Created by Nazar Dydyn on 10.09.2026.
//

import Foundation
import MapKit
import Testing
@testable import Letterfly

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

    @Test func toggleFilter_allResetsOtherSelections() {
        let viewModel = MapViewModel()
        viewModel.selectedFilters = [.withPhotos, .withMood]

        viewModel.toggleFilter(.all)

        #expect(viewModel.selectedFilters == [.all])
    }

    @Test func toggleFilter_sameOptionTwiceClearsSelection() {
        let viewModel = MapViewModel()

        viewModel.toggleFilter(.withPhotos)
        viewModel.toggleFilter(.withPhotos)

        #expect(viewModel.selectedFilters.isEmpty)
        #expect(viewModel.filteredLetters(from: [letter("Any")]).isEmpty)
    }

    @Test func toggleFilter_selectingSpecificFilterRemovesAll() {
        let viewModel = MapViewModel()

        viewModel.toggleFilter(.withMood)

        #expect(viewModel.selectedFilters == [.withMood])
    }

    @Test func filteredLetters_withMoodRequiresMood() {
        let withMood = letter("Mood", mood: .happy)
        let withoutMood = letter("No mood")
        let viewModel = MapViewModel()
        viewModel.selectedFilters = [.withMood]

        #expect(viewModel.filteredLetters(from: [withMood, withoutMood]).map(\.subject) == ["Mood"])
    }

    @Test func filteredLetters_withSurpriseRequiresSurprise() {
        let withSurprise = letter("Surprise", surprise: .coffee)
        let withoutSurprise = letter("No surprise")
        let viewModel = MapViewModel()
        viewModel.selectedFilters = [.withSurprise]

        #expect(viewModel.filteredLetters(from: [withSurprise, withoutSurprise]).map(\.subject) == ["Surprise"])
    }

    @Test func filteredLetters_withPhotosRequiresPhotoURL() {
        let withPhoto = letter("Photo", photoURL: "https://example.com/photo.jpg")
        let withoutPhoto = letter("No photo")
        let viewModel = MapViewModel()
        viewModel.selectedFilters = [.withPhotos]

        #expect(viewModel.filteredLetters(from: [withPhoto, withoutPhoto]).map(\.subject) == ["Photo"])
    }

    @Test func filteredLetters_multipleFiltersUseAndSemantics() {
        let matching = letter("Matching", photoURL: "photo", mood: .love)
        let photoOnly = letter("Photo only", photoURL: "photo")
        let moodOnly = letter("Mood only", mood: .love)
        let viewModel = MapViewModel()
        viewModel.selectedFilters = [.withPhotos, .withMood]

        #expect(viewModel.filteredLetters(from: [matching, photoOnly, moodOnly]).map(\.subject) == ["Matching"])
    }

    @Test func filteredLetters_thisYearExcludesPreviousYear() {
        let currentYear = letter("Current")
        var previousYear = letter("Previous")
        previousYear.createdAt = Calendar.current.date(byAdding: .year, value: -1, to: .now)!
        let viewModel = MapViewModel()
        viewModel.selectedFilters = [.thisYear]

        #expect(viewModel.filteredLetters(from: [currentYear, previousYear]).map(\.subject) == ["Current"])
    }

    @Test func filteredLetters_thisMonthExcludesPreviousMonth() {
        let currentMonth = letter("Current")
        var previousMonth = letter("Previous")
        previousMonth.createdAt = Calendar.current.date(byAdding: .month, value: -1, to: .now)!
        let viewModel = MapViewModel()
        viewModel.selectedFilters = [.thisMonth]

        #expect(viewModel.filteredLetters(from: [currentMonth, previousMonth]).map(\.subject) == ["Current"])
    }

    @Test func nearbyCount_ignoresLettersWithoutLocation() {
        let service = LocationService()
        service.userLocation = CLLocationCoordinate2D(latitude: 49.8397, longitude: 24.0297)
        let viewModel = MapViewModel()

        #expect(viewModel.nearbyCount(from: [letter("No location")], service) == 0)
    }

    @Test func nearbyCount_usesSelectedRadius() {
        let service = LocationService()
        service.userLocation = CLLocationCoordinate2D(latitude: 49.8397, longitude: 24.0297)
        let nearby = letter("Near", location: .init(placeName: nil, latitude: 49.8397, longitude: 24.10))
        let viewModel = MapViewModel()

        viewModel.selectedRadius = .near
        #expect(viewModel.nearbyCount(from: [nearby], service) == 0)
        viewModel.selectedRadius = .medium
        #expect(viewModel.nearbyCount(from: [nearby], service) == 1)
    }

    private func letter(
        _ subject: String,
        photoURL: String? = nil,
        mood: MoodType? = nil,
        surprise: SurpriseType? = nil,
        location: Letter.LetterLocation? = nil
    ) -> Letter {
        Letter(
            authorID: "partner",
            subject: subject,
            createdAt: .now,
            photoURL: photoURL,
            mood: mood,
            surprise: surprise,
            location: location
        )
    }

}
