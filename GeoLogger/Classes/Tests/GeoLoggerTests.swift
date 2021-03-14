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

class GeoLoggerTests: XCTestCase {
    override class func setUp() {
        super.setUp()
    }

    func testPermissionRequestDeniedAndAlertIsNotShown() {
        let locationManagerStub = LocationManagerStub()
        let batchLoggerStub = BatchLoggerStub()

        GeoLogger.instance = GeoLogger()
        GeoLogger.internalSetup(locationManager: locationManagerStub, batchLogger: batchLoggerStub)

        locationManagerStub.necessaryPermissionsProvided = false
        locationManagerStub.showOpenSettingsAlert = false
        locationManagerStub.withPreciousLocation = false
        GeoLogger.requestPermission(true, requestTemporaryFullAccuracy: true)
        XCTAssert(locationManagerStub.requestPermissionIsCalled, "Request permission not being called")
    }

    func testPermissionRequestDeniedAndAlertIsShown() {
        let locationManagerStub = LocationManagerStub()
        let batchLoggerStub = BatchLoggerStub()

        GeoLogger.instance = GeoLogger()
        GeoLogger.internalSetup(locationManager: locationManagerStub, batchLogger: batchLoggerStub)

        locationManagerStub.necessaryPermissionsProvided = false
        locationManagerStub.showOpenSettingsAlert = true
        locationManagerStub.withPreciousLocation = false
        let exp = expectation(description: "Show alert callback is called when location permission is denied")
        GeoLogger.requestPermission(true, requestTemporaryFullAccuracy: true) { (locationPermissionDenied, locationServicesDisabled) in
            XCTAssert(locationPermissionDenied, "locationPermissionDenied  is not true")
            exp.fulfill()
        }
        waitForExpectations(timeout: 10)
        XCTAssert(locationManagerStub.requestPermissionIsCalled, "Request permission not being called")
    }

    func testPermissionRequestWhenInUse() {
        let locationManagerStub = LocationManagerStub()
        let batchLoggerStub = BatchLoggerStub()

        GeoLogger.instance = GeoLogger()
        GeoLogger.internalSetup(locationManager: locationManagerStub, batchLogger: batchLoggerStub)

        locationManagerStub.necessaryPermissionsProvided = true
        GeoLogger.requestPermission(false, requestTemporaryFullAccuracy: true)
        XCTAssert(locationManagerStub.startMonitoringLocationCalled, "Start monitoring location not called")
    }

    func testPermissionRequestBackground() {
        let locationManagerStub = LocationManagerStub()
        let batchLoggerStub = BatchLoggerStub()

        GeoLogger.instance = GeoLogger()
        GeoLogger.internalSetup(locationManager: locationManagerStub, batchLogger: batchLoggerStub)

        locationManagerStub.necessaryPermissionsProvided = true
        GeoLogger.requestPermission(true, requestTemporaryFullAccuracy: true)
        XCTAssert(locationManagerStub.setupBackgroundModeCalled, "Start monitoring background location not called")
    }

    func testLog() {
        let api: String = "Api"
        let lat: Double = 123.0
        let lon: Double = 456.0
        let time: Int64 = 123456
        let ext: String = "Ext"
        
        let locationManagerStub = LocationManagerStub()
        let batchLoggerStub = BatchLoggerStub()


        GeoLogger.instance = GeoLogger()
        GeoLogger.internalSetup(locationManager: locationManagerStub, batchLogger: batchLoggerStub)

        let callback = {(success: Bool, retryCountLeft: Int?) in }
        GeoLogger.log(api: api, lat: lat, lon: lon, time: time, ext: ext, retryOnErrorCount: 5, callback: callback)
        XCTAssert(batchLoggerStub.addLogCalled, "Batch logger add log not called")
        let addedLog = batchLoggerStub.log
        XCTAssert(addedLog!.api == api
                    && addedLog!.latitude == lat
                    && addedLog!.longitude == lon
                    && addedLog!.time == time
                    && addedLog!.ext == ext
                    && addedLog!.retryCount == 5, "Incorrect log values")
        XCTAssert(batchLoggerStub.startSyncCalled, "Batch logger start sync not called")
    }



    override class func tearDown() {
        super.tearDown()
    }
}

class LocationManagerStub: LocationManagerType {

    var requestPermissionIsCalled = false, startMonitoringLocationCalled: Bool = false, setupBackgroundModeCalled: Bool = false
    var necessaryPermissionsProvided: Bool = false, showOpenSettingsAlert: Bool = false, withPreciousLocation: Bool = false
    var location: CLLocationCoordinate2D?

    func startMonitoringLocation() {
        startMonitoringLocationCalled = true
    }

    func setupBackgroundMode() {
        setupBackgroundModeCalled = true
    }

    func requestPermissions(_ withBackgroundPermission: Bool, requestTemporaryPreciseLocation: Bool, complition: LocationPermissionCallback?) {
        requestPermissionIsCalled = true
        complition?(necessaryPermissionsProvided, showOpenSettingsAlert, withPreciousLocation, false)
    }
}

class BatchLoggerStub: BatchLoggerType {

    var addLogCalled: Bool = false
    var startSyncCalled: Bool = false
    var log: GeoLog?

    func addLog(api: String, lat: Double, lon: Double, time: Int64, ext: String, retryOnErrorCount: Int) -> GeoLog {
        addLogCalled = true
        log = GeoLog(api: api, latitude: lat, longitude: lon, retryCount: retryOnErrorCount, time: time, ext: ext)
        return log!
    }

    func startSync() {
        startSyncCalled = true
    }
}

