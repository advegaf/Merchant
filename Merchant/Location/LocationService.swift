// Rules: Core Location wrapper using Visits for low power; degrades gracefully.
// Inputs: CLLocationManager authorization/visits
// Outputs: Visit callbacks for orchestrators
// Constraints: Cap features; no heavy timers; background-safe when permitted

import Foundation
import CoreLocation

@MainActor
public protocol LocationServicing: AnyObject {
    func requestAuthorization()
    func start()
    func stop()
    var onVisit: ((CLVisit) -> Void)? { get set }
}

@MainActor
public final class LocationService: NSObject, LocationServicing {
    private let manager: CLLocationManager
    public var onVisit: ((CLVisit) -> Void)?
    private var shouldMonitorVisits = false

    public override init() {
        self.manager = CLLocationManager()
        super.init()
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.manager.distanceFilter = 200
        self.manager.pausesLocationUpdatesAutomatically = true
        self.manager.activityType = .other
    }

    public func requestAuthorization() {
        // Guard missing plist keys to avoid runtime crash/blank screen
        let hasWhenInUse = Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") != nil
        guard hasWhenInUse else { return }
        manager.requestWhenInUseAuthorization()
    }

    public func start() {
        guard CLLocationManager.locationServicesEnabled() else { return }
        shouldMonitorVisits = true
        handleAuthorizationChange(manager.authorizationStatus)
    }

    public func stop() {
        shouldMonitorVisits = false
        manager.stopMonitoringVisits()
    }
}

extension LocationService: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        onVisit?(visit)
    }
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuthorizationChange(manager.authorizationStatus)
    }
}

private extension LocationService {
    func handleAuthorizationChange(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            guard shouldMonitorVisits else { return }
            manager.startMonitoringVisits()
        case .notDetermined:
            // Request will prompt; actual start happens via delegate callback
            requestAuthorization()
        default:
            manager.stopMonitoringVisits()
        }
    }
}

// Stub for previews/tests
@MainActor
public final class StubLocationService: LocationServicing {
    public var onVisit: ((CLVisit) -> Void)?
    public init() {}
    public func requestAuthorization() {}
    public func start() {}
    public func stop() {}
}
