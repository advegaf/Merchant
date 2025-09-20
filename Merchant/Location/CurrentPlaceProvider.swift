// Rules: Provide current place name and session start tracking with low power.
// Inputs: Core Location updates, reverse geocoding
// Outputs: Place name and session start date via callback
// Constraints: Use coarse accuracy; reset session when moving >75m

import Foundation
import CoreLocation

public final class CurrentPlaceProvider: NSObject {
    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var anchor: CLLocation?
    private var isRunning = false

    public override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 50
        manager.pausesLocationUpdatesAutomatically = true
        manager.activityType = .other
    }

    public func start(onUpdate: @escaping (_ name: String, _ start: Date) -> Void) {
        guard !isRunning else { return }
        isRunning = true
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
        manager.startUpdatingLocation()
        // Initial update if we have a cached location
        if let loc = manager.location {
            handle(location: loc, onUpdate: onUpdate)
        }
        self.onUpdate = onUpdate
    }

    public func stop() {
        isRunning = false
        manager.stopUpdatingLocation()
        onUpdate = nil
    }

    private var onUpdate: ((_ name: String, _ start: Date) -> Void)?

    private func handle(location: CLLocation, onUpdate: @escaping (_ name: String, _ start: Date) -> Void) {
        let shouldResetSession: Bool
        if let anchor {
            shouldResetSession = location.distance(from: anchor) > 75
        } else {
            shouldResetSession = true
        }

        if shouldResetSession {
            anchor = location
            let start = Date()
            geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
                guard self?.isRunning == true else { return }
                let pm = placemarks?.first
                let name = pm?.name ?? pm?.locality ?? "Nearby"
                onUpdate(name, start)
            }
        }
    }
}

extension CurrentPlaceProvider: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last, let onUpdate else { return }
        handle(location: latest, onUpdate: onUpdate)
    }
}


