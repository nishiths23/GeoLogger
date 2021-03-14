//
//  File.swift
//  
//
//  Created by Nishith on 13/03/21.
//

import Foundation
import XCTest
import RealmSwift
@testable import GeoLoggerSDK

class DBManagerTest: XCTestCase {

    var observer: NotificationToken?

    func testGetAllLogs() {
        let realm = try! Realm()
        let objects = realm.objects(GeoLog_Realm.self)
        let api: String = "Api"
        let lat: Double = 123.0
        let lon: Double = 456.0
        let time: Int64 = 123456
        let ext: String = "Ext"
        let log = GeoLog(api: api, latitude: lat, longitude: lon, retryCount: 5, time: time, ext: ext)
        DBManager.shared.add(log)
        let exp = expectation(description: "Log successfully uploaded")
        exp.assertForOverFulfill = false
        observer = objects.observe { (change) in
            switch change {
            case .update(_, _ , let insertions, _):
                if insertions.count > 0 {
                    DBManager.shared.allLogs { (allLogs) in
                        XCTAssertFalse(allLogs.isEmpty, "No log added")
                        exp.fulfill()
                    }
                }
                break
            default: break
            }
        }
        waitForExpectations(timeout: 10)
        observer?.invalidate()
        observer = nil
        try! realm.write {
          realm.deleteAll()
        }
    }

    func testUpdate() {
        let realm = try! Realm()
        let objects = realm.objects(GeoLog_Realm.self)
        let api: String = "Api"
        let lat: Double = 123.0
        let lon: Double = 456.0
        let time: Int64 = 123456
        let ext: String = "Ext"
        let log = GeoLog(api: api, latitude: lat, longitude: lon, retryCount: 5, time: time, ext: ext)
        let exp = expectation(description: "Log successfully uploaded")
        observer = objects.observe { (change) in
            switch change {
            case .update(let newLog, _ , let insertions,let modifications):
                if insertions.count > 0, let firstLog = newLog.first {
                    var addedLog = GeoLog.from(firstLog)
                    XCTAssert(addedLog.api == api
                                && addedLog.latitude == lat
                                && addedLog.longitude == lon
                                && addedLog.time == time
                                && addedLog.ext == ext
                                && addedLog.retryCount == 5, "log inserted is not same as what was passed in add method")
                    addedLog.retryCount = 0
                    DBManager.shared.update(addedLog)
                } else if modifications.count > 0, let firstLog = newLog.first {
                    let updatedLog = GeoLog.from(firstLog)
                    XCTAssert(updatedLog.retryCount == 0, "Modification unsuccessful")
                    exp.fulfill()
                }
                break
            default: break
            }
        }
        DBManager.shared.add(log)
        waitForExpectations(timeout: 10)
        observer?.invalidate()
        observer = nil
        try! realm.write {
          realm.deleteAll()
        }
    }

    func testDelete() {
        let realm = try! Realm()
        let objects = realm.objects(GeoLog_Realm.self)
        let api: String = "Api"
        let lat: Double = 123.0
        let lon: Double = 456.0
        let time: Int64 = 123456
        let ext: String = "Ext"
        let log = GeoLog(api: api, latitude: lat, longitude: lon, retryCount: 5, time: time, ext: ext)
        let exp = expectation(description: "Log successfully uploaded")
        observer = objects.observe { (change) in
            switch change {
            case .update(let newLog, let deletion , let insertions, _):
                if insertions.count > 0, let firstLog = newLog.first {
                    var addedLog = GeoLog.from(firstLog)
                    addedLog.retryCount = 0
                    DBManager.shared.delete(addedLog)
                } else if deletion.count > 0 {
                    exp.fulfill()
                }
                break
            default: break
            }
        }
        DBManager.shared.add(log)
        waitForExpectations(timeout: 10)
        observer?.invalidate()
        observer = nil
        try! realm.write {
          realm.deleteAll()
        }
    }
}
