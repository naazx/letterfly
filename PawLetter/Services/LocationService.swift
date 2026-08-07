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
}
