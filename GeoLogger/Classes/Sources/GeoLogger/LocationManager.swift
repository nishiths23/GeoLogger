//
//  File.swift
//  
//
//  Created by Nishith on 07/03/21.
//

import Foundation
import CoreLocation

typealias LocationPermissionCallback = ((_ necessaryPermissionsProvided: Bool,_ showOpenSettingsAlert: Bool, _ withPreciousLocation: Bool, _ locationServicesDisabled: Bool) -> Void)

protocol CLLocationManagerType: class {
    var delegate: CLLocationManagerDelegate? { get set }
    var pausesLocationUpdatesAutomatically: Bool { get set }
    var authorizationStatus: CLAuthorizationStatus { get }
    var allowsBackgroundLocationUpdates: Bool { get set }
    var accuracyAuthorization: CLAccuracyAuthorization { get }

    func requestAlwaysAuthorization()
    func requestWhenInUseAuthorization()
    func startUpdatingLocation()
    func requestTemporaryFullAccuracyAuthorization(withPurposeKey purposeKey: String, completion: ((Error?) -> Void)?)
}

protocol LocationManagerType {
    var location: CLLocationCoordinate2D? { get }
    
    func startMonitoringLocation()
    func setupBackgroundMode()
    func requestPermissions(_ withBackgroundPermission: Bool, requestTemporaryPreciseLocation: Bool, complition: LocationPermissionCallback?)
}

extension CLLocationManager : CLLocationManagerType {}

class LocationManager: NSObject, LocationManagerType {

    //MARK: - Internal properties
    static let shared = LocationManager()

    private(set) var location: CLLocationCoordinate2D? = nil
    let temporaryAccuracyAuthPurposeKey = "TemporaryAccuracyAuthPurposeKey"

    //MARK: - Private properties
    private var locationPermissionCallback: LocationPermissionCallback?
    private var withBackgroundPermission: Bool = false
    private var requestTemporaryPreciseLocation: Bool = false

    //MARK: - Internal methods
    func startMonitoringLocation() {
        checkForPermissionAndStartLocationMonitor()
    }

    func setupBackgroundMode() {
        if locationManager.authorizationStatus == .authorizedAlways {
            #if os(iOS)
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
            #endif
        }
    }

    func requestPermissions(_ withBackgroundPermission: Bool, requestTemporaryPreciseLocation: Bool, complition: LocationPermissionCallback?) {
        self.requestTemporaryPreciseLocation = requestTemporaryPreciseLocation
        self.withBackgroundPermission = withBackgroundPermission
        if CLLocationManager.locationServicesEnabled() {
            switch locationManager.authorizationStatus {
            case .notDetermined:
                locationPermissionCallback = complition
                withBackgroundPermission
                    ? locationManager.requestAlwaysAuthorization()
                    : locationManager.requestWhenInUseAuthorization()
            case .restricted, .denied: complition?(false, true, false, false)
            case .authorizedAlways:
                if requestTemporaryPreciseLocation {
                    locationPermissionCallback = complition
                    checkPermissionAndRequestPreciseLocation()
                } else {
                    complition?(true, false, locationManager.accuracyAuthorization == .fullAccuracy, false)
                }
            #if os(iOS)
            case .authorizedWhenInUse:
                if requestTemporaryPreciseLocation {
                    locationPermissionCallback = complition
                    checkPermissionAndRequestPreciseLocation()
                } else {
                    complition?(true, false, locationManager.accuracyAuthorization == .fullAccuracy, false)
                }
            #endif
            @unknown default: break
            }
        } else {
            complition?(false, false, false, true)
        }
    }


    //MARK: - Private properties
    private let locationManager: CLLocationManagerType

    //MARK: - Private methods
    internal init(_ locationManager: CLLocationManagerType = CLLocationManager()) {
        self.locationManager = locationManager
        super.init()
        locationManager.delegate = self
    }

    private func checkForPermissionAndStartLocationMonitor() {
        if CLLocationManager.locationServicesEnabled() {
            switch locationManager.authorizationStatus {
            case .notDetermined, .restricted, .denied: break
            case .authorizedAlways:
                locationManager.startUpdatingLocation()
            #if os(iOS)
            case .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
            #endif
            @unknown default: break
            }
        }
    }

    private func checkPermissionAndRequestPreciseLocation() {
        if (locationManager.accuracyAuthorization == .reducedAccuracy) {
            locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: temporaryAccuracyAuthPurposeKey) { [unowned self] (error) in
                locationPermissionCallback?(true, false, locationManager.accuracyAuthorization == .fullAccuracy, false)
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    //MARK: - CLLocationManagerDelegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if CLLocationManager.locationServicesEnabled() {
            switch locationManager.authorizationStatus {
            case .notDetermined: break
            case .restricted, .denied: locationPermissionCallback?(false, false, false, false)
            case .authorizedAlways: locationPermissionCallback?(true, false, locationManager.accuracyAuthorization == .fullAccuracy, false)
            #if os(iOS)
            case .authorizedWhenInUse: locationPermissionCallback?(true, false, locationManager.accuracyAuthorization == .fullAccuracy, false)
            #endif
            @unknown default: break
            }
        } else {
            locationPermissionCallback?(false, false, false, true)
        }
    }
}
