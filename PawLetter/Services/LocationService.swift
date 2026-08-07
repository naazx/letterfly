//
//  LocationService.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 07.08.2026.
//

import Foundation
import CoreLocation

@Observable
class LocationService: NSObject, CLLocationManagerDelegate {
    private let manager =   CLLocationManager()
    var userLocation: CLLocationCoordinate2D?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var isError: Bool = false
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
    
    func requestCurrentLocation(){
        manager.requestLocation( )
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isError = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           userLocation = locations.last?.coordinate
    }
    func placeName(for coordinate: CLLocationCoordinate2D) async -> String? {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        do{
            let geocodeLocation = try await CLGeocoder().reverseGeocodeLocation(location)
            return geocodeLocation.first?.areasOfInterest?.first ?? geocodeLocation.first?.locality
        } catch {}
        return nil
    }
}
extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
