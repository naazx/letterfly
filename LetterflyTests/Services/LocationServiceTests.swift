import CoreLocation
import Testing
@testable import Letterfly

@MainActor
struct LocationServiceTests {
    @Test func didUpdateLocationsStoresMostRecentCoordinate() {
        let service = LocationService()
        let manager = CLLocationManager()
        let first = CLLocation(latitude: 49.0, longitude: 24.0)
        let last = CLLocation(latitude: 50.0, longitude: 25.0)

        service.locationManager(manager, didUpdateLocations: [first, last])

        #expect(service.userLocation == last.coordinate)
    }

    @Test func didUpdateLocationsWithNoResultsLeavesLocationUnset() {
        let service = LocationService()

        service.locationManager(CLLocationManager(), didUpdateLocations: [])

        #expect(service.userLocation == nil)
    }

    @Test func didFailWithErrorSetsErrorState() {
        let service = LocationService()

        service.locationManager(CLLocationManager(), didFailWithError: NSError(domain: "test", code: 1))

        #expect(service.isError)
    }

    @Test func authorizationCallbackCopiesManagerStatus() {
        let service = LocationService()
        let manager = CLLocationManager()

        service.locationManagerDidChangeAuthorization(manager)

        #expect(service.authorizationStatus == manager.authorizationStatus)
    }
}
