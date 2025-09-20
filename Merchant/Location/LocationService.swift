// Rules: Core Location wrapper using Visits for low power; degrades gracefully.
// Inputs: CLLocationManager authorization/visits
// Outputs: Visit callbacks for orchestrators
// Constraints: Cap features; no heavy timers; background-safe when permitted

import Foundation
import CoreLocation

public protocol LocationServicing: AnyObject {
    func requestAuthorization() async
    func start() async
    func stop()
    var onVisit: ((CLVisit) -> Void)? { get set }
}

public final class LocationService: NSObject, LocationServicing {
    private let manager: CLLocationManager
    public var onVisit: ((CLVisit) -> Void)?

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
        if #available(iOS 13.4, *) {
            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                self.manager.requestWhenInUseAuthorization()
                continuation.resume()
            }
        } else {
            self.manager.requestWhenInUseAuthorization()
        }
    }

    public func start() async {
        guard CLLocationManager.locationServicesEnabled() else { return }
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startMonitoringVisits()
        case .notDetermined:
            await requestAuthorization()
            if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
                manager.startMonitoringVisits()
            }
        default:
            break
        }
    }

    public func stop() {
        manager.stopMonitoringVisits()
    }
}

extension LocationService: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        onVisit?(visit)
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // No-op; orchestrator can call start() again if needed
    }
}

// Stub for previews/tests
public final class StubLocationService: LocationServicing {
    public var onVisit: ((CLVisit) -> Void)?
    public init() {}
    public func requestAuthorization() async {}
    public func start() async {}
    public func stop() {}
}


