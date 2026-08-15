//
//  MapViewModel.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 15.08.2026.
//
import MapKit
import Foundation
import SwiftUI

@Observable
class MapViewModel{
    var position: MapCameraPosition = .userLocation(
        fallback: .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 49.8397, longitude: 24.0297),
                latitudinalMeters: 5000 * 2,
                longitudinalMeters: 5000 * 2
            )
        )
    )
    var isSatelliteStyle: Bool = false
    var hasSetInitialPosition = false
    var selectedLetter: Letter?
    var letterToOpen: Letter?
    var selectedRadius: NearbyRadius = .near
    var selectedFilters: Set<MapFilterOption> = [.all]
    
    enum NearbyRadius: Double, CaseIterable {
        case near = 5_000
        case medium = 10_000
        case far = 20_000
        
        var title: String {
            switch self {
            case .near:
                return "5 km"
            case .medium:
                return "10 km"
            case .far:
                return "20 km"
            }
        }
    }
    
    func nearbyCount(from letters: [Letter], _ locationService: LocationService) -> Int? {
        guard let userCoordinate = locationService.userLocation else { return nil }
        let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        
        return letters.filter { letter in
            guard let location = letter.location else { return false}
            let letterLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            return userLocation.distance(from: letterLocation) <= selectedRadius.rawValue
        }.count
    }
    
    func toggleFilter(_ option: MapFilterOption) {
        if option == .all {
            selectedFilters = [.all]
        } else {
            selectedFilters.remove(.all)
            if selectedFilters.contains(option) {
                selectedFilters.remove(option)
            } else {
                selectedFilters.insert(option)
            }
        }
    }
    func filteredLetters(from letters: [Letter]) -> [Letter] {
        if selectedFilters.isEmpty {
            return []
        }
        if selectedFilters.contains(.all) {
            return letters
        }
        
        return letters.filter { letter in
            for filter in selectedFilters {
                switch filter {
                case .all:
                    continue
                case .withPhotos:
                    if letter.photoURL == nil { return false }
                case .withMood:
                    if letter.mood == nil { return false }
                case .withSurprise:
                    if letter.surprise == nil { return false }
                case .thisYear:
                    if !Calendar.current.isDate(letter.createdAt, equalTo: .now, toGranularity: .year) { return false }
                case .thisMonth:
                    if !Calendar.current.isDate(letter.createdAt, equalTo: .now, toGranularity: .month) { return false }
                }
            }
            return true
        }
    }
    
}
