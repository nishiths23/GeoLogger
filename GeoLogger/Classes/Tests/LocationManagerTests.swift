//
//  File.swift
//  
//
//  Created by Nishith on 13/03/21.
//

import Foundation
import XCTest
import CoreLocation
@testable import GeoLoggerSDK

class LocationManagerTests: XCTestCase {


    override class func setUp() {
        super.setUp()
    }

    func testPermissionNotProvided() {
        let locationManagerStub: CLLocationManagerStub! = CLLocationManagerStub()
        let exp = expectation(description: "Callback with permission not provided")
        let locationManager = LocationManager(locationManagerStub)
        locationManager.requestPermissions(false, requestTemporaryPreciseLocation: false) { (_ necessaryPermissionsProvided: Bool,_ showOpenSettingsAlert: Bool, _ withPreciousLocation: Bool, locationServicesDisabled: Bool)  in
            XCTAssertFalse(necessaryPermissionsProvided, "Wrong permission callback")
            exp.fulfill()
        }
        waitForExpectations(timeout: 30)
    }

    func testAlwaysPermissionProvided() {
        let locationManagerStub: CLLocationManagerStub! = CLLocationManagerStub()

        let exp = expectation(description: "Callback when permission is provided")
        let locationManager = LocationManager(locationManagerStub)
        locationManagerStub.allowLocationAlwaysPermission = true
        locationManager.requestPermissions(true, requestTemporaryPreciseLocation: false) { (_ necessaryPermissionsProvided: Bool,_ showOpenSettingsAlert: Bool, _ withPreciousLocation: Bool, locationServicesDisabled: Bool) in
            XCTAssert(necessaryPermissionsProvided, "Wrong permission callback")
            exp.fulfill()
        }
        waitForExpectations(timeout: 30)
    }

    func testAlwaysPermissionDenied() {
        let locationManagerStub: CLLocationManagerStub! = CLLocationManagerStub()

        let exp = expectation(description: "Callback when permission is provided")
        let locationManager = LocationManager(locationManagerStub)
        locationManagerStub.allowLocationAlwaysPermission = false
        locationManager.requestPermissions(true, requestTemporaryPreciseLocation: false) { (_ necessaryPermissionsProvided: Bool,_ showOpenSettingsAlert: Bool, _ withPreciousLocation: Bool, locationServicesDisabled: Bool) in
            XCTAssertFalse(necessaryPermissionsProvided, "Wrong permission callback")
            exp.fulfill()
        }
        waitForExpectations(timeout: 30)
    }

    func testAlwaysPermissionAskedBtWhileInUseProvided() {
        let locationManagerStub: CLLocationManagerStub! = CLLocationManagerStub()

        let exp = expectation(description: "Callback when permission is provided")
        let locationManager = LocationManager(locationManagerStub)
        locationManagerStub.allowLocationWhileInUsePermission = false
        locationManager.requestPermissions(true, requestTemporaryPreciseLocation: false) { (_ necessaryPermissionsProvided: Bool,_ showOpenSettingsAlert: Bool, _ withPreciousLocation: Bool, locationServicesDisabled: Bool) in
            XCTAssertFalse(necessaryPermissionsProvided, "Wrong permission callback")
            exp.fulfill()
        }
        waitForExpectations(timeout: 30)
    }

    #if os(iOS)
    func testWhileInUsePermissionGranted() {
        let locationManagerStub: CLLocationManagerStub! = CLLocationManagerStub()

        let exp = expectation(description: "Callback with permission not provided")
        let locationManager = LocationManager(locationManagerStub)
        locationManagerStub.allowLocationWhileInUsePermission = true
        locationManager.requestPermissions(false, requestTemporaryPreciseLocation: false) { (_ necessaryPermissionsProvided: Bool,_ showOpenSettingsAlert: Bool, _ withPreciousLocation: Bool, locationServicesDisabled: Bool) in
            XCTAssert(necessaryPermissionsProvided, "Wrong permission callback")
            exp.fulfill()
        }
        waitForExpectations(timeout: 30)
    }
    #endif

    func testWhileInUsePermissionRejected() {
        let locationManagerStub: CLLocationManagerStub! = CLLocationManagerStub()

        let exp = expectation(description: "Callback with permission not provided")
        let locationManager = LocationManager(locationManagerStub)
        locationManagerStub.allowLocationWhileInUsePermission = false
        locationManager.requestPermissions(false, requestTemporaryPreciseLocation: false) { (_ necessaryPermissionsProvided: Bool,_ showOpenSettingsAlert: Bool, _ withPreciousLocation: Bool, locationServicesDisabled: Bool) in
            XCTAssertFalse(necessaryPermissionsProvided, "Wrong permission callback")
            exp.fulfill()
        }
        waitForExpectations(timeout: 30)
    }

    func testAskedForWhileInUseGrantedAlways() {
        let locationManagerStub: CLLocationManagerStub! = CLLocationManagerStub()

        let exp = expectation(description: "Callback with permission not provided")
        let locationManager = LocationManager(locationManagerStub)
        locationManagerStub.allowLocationAlwaysPermission = true
        locationManager.requestPermissions(false, requestTemporaryPreciseLocation: false) { (_ necessaryPermissionsProvided: Bool,_ showOpenSettingsAlert: Bool, _ withPreciousLocation: Bool, locationServicesDisabled: Bool) in
            XCTAssert(necessaryPermissionsProvided, "Wrong permission callback")
            exp.fulfill()
        }
        waitForExpectations(timeout: 30)
    }
    #if os(iOS)
    func testBackgroundModeIsActivatedWhenNeeded() {
        let locationManagerStub: CLLocationManagerStub! = CLLocationManagerStub()

        let locationManager = LocationManager(locationManagerStub)
        locationManagerStub.authorizationStatus = .authorizedAlways
        locationManager.setupBackgroundMode()
        XCTAssert(locationManagerStub.allowsBackgroundLocationUpdates, "Background mode is not activated")
        XCTAssertFalse(locationManagerStub.pausesLocationUpdatesAutomatically, "Automatic location updates pause is not disabled")
        locationManager.startMonitoringLocation()
        XCTAssert(locationManagerStub.startUpdatingLocationCalled, "Start monitoring location is not called")
    }
    #endif

    func testLocationMonitoring() {
        let locationManagerStub: CLLocationManagerStub! = CLLocationManagerStub()

        let locationManager = LocationManager(locationManagerStub)
        locationManagerStub.authorizationStatus = .authorizedAlways
        locationManager.startMonitoringLocation()
        let location = CLLocation(latitude: 100, longitude: 123)
        locationManagerStub.delegate?.locationManager?(CLLocationManager(), didUpdateLocations: [location])
        XCTAssert(location.coordinate.latitude == locationManager.location!.latitude && location.coordinate.longitude == locationManager.location!.longitude, "Wrong location updated")
    }

    #if os(iOS)
    func testLocationMonitoringWithWhileInUsePermission() {
        let locationManagerStub: CLLocationManagerStub! = CLLocationManagerStub()

        let locationManager = LocationManager(locationManagerStub)
        locationManagerStub.authorizationStatus = .authorizedWhenInUse
        locationManager.startMonitoringLocation()
        let location = CLLocation(latitude: 100, longitude: 123)
        locationManagerStub.delegate?.locationManager?(CLLocationManager(), didUpdateLocations: [location])
        XCTAssert(location.coordinate.latitude == locationManager.location!.latitude && location.coordinate.longitude == locationManager.location!.longitude, "Wrong location updated")
    }
    #endif

    func testWhenAlwaysLocationPermissionsAreProvidedPrecisePermissionsPrompt() {
        let locationManagerStub: CLLocationManagerStub! = CLLocationManagerStub()

        let locationManager = LocationManager(locationManagerStub)
        locationManagerStub.authorizationStatus = .authorizedAlways
        let exp = expectation(description: "Callback with permission not provided")
        locationManager.requestPermissions(false, requestTemporaryPreciseLocation: true) { (_ necessaryPermissionsProvided: Bool,_ showOpenSettingsAlert: Bool, _ withPreciousLocation: Bool, locationServicesDisabled: Bool) in
            XCTAssert(locationManagerStub.requestTemporaryFullAccuracyAuthorizationCalled, "Wrong permission callback")
            exp.fulfill()
        }
        waitForExpectations(timeout: 30)
    }

    #if os(iOS)
    func testWhenInUseLocationPermissionsAreProvidedPrecisePermissionsPrompt() {
        let locationManagerStub: CLLocationManagerStub! = CLLocationManagerStub()

        let locationManager = LocationManager(locationManagerStub)
        locationManagerStub.authorizationStatus = .authorizedWhenInUse
        let exp = expectation(description: "Callback with permission not provided")
        locationManager.requestPermissions(false, requestTemporaryPreciseLocation: true) { (_ necessaryPermissionsProvided: Bool,_ showOpenSettingsAlert: Bool, _ withPreciousLocation: Bool, locationServicesDisabled: Bool) in
            XCTAssert(locationManagerStub.requestTemporaryFullAccuracyAuthorizationCalled, "Wrong permission callback")
            exp.fulfill()
        }
        waitForExpectations(timeout: 30)
    }
    #endif


    func testWhenAlwaysLocationPermissionsAreProvidedGetExpectedCallback() {
        let locationManagerStub: CLLocationManagerStub! = CLLocationManagerStub()

        let locationManager = LocationManager(locationManagerStub)
        locationManagerStub.authorizationStatus = .authorizedAlways
        let exp = expectation(description: "Callback with permission not provided")
        locationManager.requestPermissions(false, requestTemporaryPreciseLocation: false) { (_ necessaryPermissionsProvided: Bool,_ showOpenSettingsAlert: Bool, _ withPreciousLocation: Bool, locationServicesDisabled: Bool) in
            XCTAssertFalse(withPreciousLocation, "Wrong permission callback")
            exp.fulfill()
        }
        waitForExpectations(timeout: 30)
    }

    #if os(iOS)
    func testWhenInUseLocationPermissionsAreProvidedGetExpectedCallback() {
        let locationManagerStub: CLLocationManagerStub! = CLLocationManagerStub()

        let locationManager = LocationManager(locationManagerStub)
        locationManagerStub.authorizationStatus = .authorizedWhenInUse
        let exp = expectation(description: "Callback with permission not provided")
        locationManager.requestPermissions(false, requestTemporaryPreciseLocation: false) { (_ necessaryPermissionsProvided: Bool,_ showOpenSettingsAlert: Bool, _ withPreciousLocation: Bool, locationServicesDisabled: Bool) in
            XCTAssertFalse(withPreciousLocation, "Wrong permission callback")
            exp.fulfill()
        }
        waitForExpectations(timeout: 30)
    }
    #endif



    override class func tearDown() {
        super.tearDown()
    }
}

class CLLocationManagerStub: CLLocationManagerType {

    var requestAlwaysAuthorizationCalled: Bool = false, requestWhenInUseAuthorizationCalled: Bool = false, startUpdatingLocationCalled: Bool = false, requestTemporaryFullAccuracyAuthorizationCalled: Bool = false
    var allowPreciseLocation: Bool = false
    var allowLocationAlwaysPermission: Bool = false
    var allowLocationWhileInUsePermission: Bool = false

    var delegate: CLLocationManagerDelegate? = nil

    var pausesLocationUpdatesAutomatically: Bool = false

    var authorizationStatus: CLAuthorizationStatus = .notDetermined

    var allowsBackgroundLocationUpdates: Bool = false

    var accuracyAuthorization: CLAccuracyAuthorization = .reducedAccuracy

    func requestAlwaysAuthorization() {
        requestAlwaysAuthorizationCalled = true
        authorizationStatus = allowLocationAlwaysPermission ? .authorizedAlways : .denied
        delegate?.locationManagerDidChangeAuthorization?(CLLocationManager())
    }

    func requestWhenInUseAuthorization() {
        requestWhenInUseAuthorizationCalled = true
        #if os(iOS)
        authorizationStatus = allowLocationWhileInUsePermission
            ? .authorizedWhenInUse
            : allowLocationAlwaysPermission
                ? .authorizedAlways
                : .denied
        #else
        authorizationStatus = allowLocationAlwaysPermission
                ? .authorizedAlways
                : .denied
        #endif
        delegate?.locationManagerDidChangeAuthorization?(CLLocationManager())
    }

    func startUpdatingLocation() {
        startUpdatingLocationCalled = true
    }

    func requestTemporaryFullAccuracyAuthorization(withPurposeKey purposeKey: String, completion: ((Error?) -> Void)?) {
        requestTemporaryFullAccuracyAuthorizationCalled = true
        completion?(allowPreciseLocation ? nil : NSError(domain: "GeoLogger", code: 1, userInfo: ["Status":"Precise location not provided"]))
    }

}
