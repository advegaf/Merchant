// Rules: Geofence manager for near-instant entry alerts. Cap regions; power-safe.
// Inputs: Coordinates to monitor
// Outputs: didEnter callbacks
// Constraints: Max 10 regions; 150m radius; Always respects auth

import Foundation
import CoreLocation

public protocol Geofencing: AnyObject {
    func requestAuthorization() async
    func setRegions(_ regions: [CLCircularRegion])
    var onEnter: ((CLRegion) -> Void)? { get set }
}

public final class GeofenceManager: NSObject, Geofencing {
    private let manager = CLLocationManager()
    public var onEnter: ((CLRegion) -> Void)?
    private let maxRegions = 10

    public override init() {
        super.init()
        manager.delegate = self
        manager.pausesLocationUpdatesAutomatically = true
        manager.activityType = .other
    }

    public func requestAuthorization() async {
        if #available(iOS 13.4, *) {
            await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
                manager.requestAlwaysAuthorization()
                c.resume()
            }
        } else { manager.requestAlwaysAuthorization() }
    }

    public func setRegions(_ regions: [CLCircularRegion]) {
        // Clear existing
        for r in manager.monitoredRegions { manager.stopMonitoring(for: r) }
        let toAdd = regions.prefix(maxRegions)
        for r in toAdd {
            r.notifyOnEntry = true
            r.notifyOnExit = false
            manager.startMonitoring(for: r)
        }
    }
}

extension GeofenceManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        onEnter?(region)
    }
}


