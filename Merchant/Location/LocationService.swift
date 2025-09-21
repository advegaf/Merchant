// Rules: Core Location wrapper using Visits for low power; degrades gracefully.
// Inputs: CLLocationManager authorization/visits
// Outputs: Visit callbacks for orchestrators
// Constraints: Cap features; no heavy timers; background-safe when permitted

import Foundation
import CoreLocation

@MainActor
public protocol LocationServicing: AnyObject {
    func requestAuthorization() async
    func start() async
    func stop()
    var onVisit: ((CLVisit) -> Void)? { get set }
}

@MainActor
public final class LocationService: NSObject, LocationServicing {
    private let manager: CLLocationManager
    public var onVisit: ((CLVisit) -> Void)?
    private var shouldMonitorVisits = false
    private var authorizationContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?
    // Removed startContinuation; we start strictly from authorization delegate

    public override init() {
        self.manager = CLLocationManager()
        super.init()
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.manager.distanceFilter = 200
        self.manager.pausesLocationUpdatesAutomatically = true
        self.manager.activityType = .other
    }

    public func requestAuthorization() async {
        // Guard missing plist keys to avoid runtime crash/blank screen
        let hasWhenInUse = Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") != nil
        guard hasWhenInUse else { return }

        // Request authorization and wait for delegate callback without querying status synchronously
        let _ = await withCheckedContinuation { continuation in
            self.authorizationContinuation = continuation
            manager.requestWhenInUseAuthorization()
        }
    }

    public func start() async {
        guard CLLocationManager.locationServicesEnabled() else { return }
        shouldMonitorVisits = true
        // Kick off auth flow to ensure we get a delegate callback; no synchronous status reads
        manager.requestWhenInUseAuthorization()
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
        let status = manager.authorizationStatus
        handleAuthorizationChange(status)

        // Resume any waiting authorization continuation
        if let continuation = authorizationContinuation {
            authorizationContinuation = nil
            continuation.resume(returning: status)
        }

        // No-op: start continuation removed; start is driven entirely by delegate now
    }
}

private extension LocationService {
    func handleAuthorizationChange(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            guard shouldMonitorVisits else { return }
            manager.startMonitoringVisits()
        case .notDetermined:
            // Authorization will be requested via async method
            break
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
    public func requestAuthorization() async {}
    public func start() async {}
    public func stop() {}
}
