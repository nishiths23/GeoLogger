//
//  File.swift
//  
//
//  Created by Nishith on 13/03/21.
//

import Foundation
import XCTest
@testable import GeoLoggerSDK

class BatchLoggerTest: XCTestCase {

    var batchLogger: BatchLogger?

    func testNewLogIsAdded() {
        let dbManager = DBManagetStub()
        let networkManager = NetworkManagerStub()
        let delegate = BatchLoggerDelegateImplementation()
        let batchLogger = BatchLogger(dbManager, networkManager: networkManager, delegate: delegate)

        let api: String = "Api"
        let lat: Double = 123.0
        let lon: Double = 456.0
        let time: Int64 = 123456
        let ext: String = "Ext"

        let addedLog = batchLogger.addLog(api: api, lat: lat, lon: lon, time: time, ext: ext, retryOnErrorCount: 5)
        XCTAssert(addedLog.api == api
                    && addedLog.latitude == lat
                    && addedLog.longitude == lon
                    && addedLog.time == time
                    && addedLog.ext == ext
                    && addedLog.retryCount == 5, "Incorrect log values")
        XCTAssert(dbManager.addLogCalled, "Log not added to db")
    }

    func testSyncSuccess() {
        let dbManager = DBManagetStub()
        let networkManager = NetworkManagerStub()
        let delegate = BatchLoggerDelegateImplementation()
        let batchLogger = BatchLogger(dbManager, networkManager: networkManager, delegate: delegate)
        
        self.batchLogger = batchLogger

        let api: String = "Api"
        let lat: Double = 123.0
        let lon: Double = 456.0
        let time: Int64 = 123456
        let ext: String = "Ext"

        dbManager.allLogs = [GeoLog(api: api, latitude: lat, longitude: lon, retryCount: 5, time: time, ext: ext), GeoLog(api: api, latitude: lat, longitude: lon, retryCount: 5, time: time, ext: ext)]
        networkManager.responseStatusSuccess = true
        networkManager.responseError = nil

        var uploadedLogsCount = dbManager.allLogs.count
        let exp = expectation(description: "Log successfully uploaded")

        dbManager.deleteLogCallback = {
            uploadedLogsCount -= 1
            if uploadedLogsCount <= 0 {
                exp.fulfill()
            }
        }

        let addedLog = batchLogger.addLog(api: api, lat: lat, lon: lon, time: time, ext: ext, retryOnErrorCount: 5)
        XCTAssert(addedLog.api == api
                    && addedLog.latitude == lat
                    && addedLog.longitude == lon
                    && addedLog.time == time
                    && addedLog.ext == ext
                    && addedLog.retryCount == 5, "Incorrect log values")
        waitForExpectations(timeout: 30)
        XCTAssert(dbManager.addLogCalled, "Log not added to db")
        XCTAssert(dbManager.deleteCalled, "Log not deleted from db")
    }

    func testSyncFaliureAndRemovedFromDBAfterRetryCountExpire() {
        let dbManager = DBManagetStub()
        let networkManager = NetworkManagerStub()
        let delegate = BatchLoggerDelegateImplementation()
        let batchLogger = BatchLogger(dbManager, networkManager: networkManager, delegate: delegate)

        self.batchLogger = batchLogger

        let api: String = "Api"
        let lat: Double = 123.0
        let lon: Double = 456.0
        let time: Int64 = 123456
        let ext: String = "Ext"

        dbManager.allLogs = [GeoLog(api: api, latitude: lat, longitude: lon, retryCount: 5, time: time, ext: ext), GeoLog(api: api, latitude: lat, longitude: lon, retryCount: 5, time: time, ext: ext)]
        networkManager.responseStatusSuccess = false
        networkManager.responseError = .unknown

        var deletedLogsCount = dbManager.allLogs.count
        let exp = expectation(description: "Log upload failed")

        dbManager.updateLogCallback = { log in
            if let index = dbManager.allLogs.firstIndex(where:  { $0.id == log.id }) {
                dbManager.allLogs[index] = log
            }
        }

        dbManager.deleteLogCallback = {
            deletedLogsCount -= 1
            if deletedLogsCount <= 0 {
                exp.fulfill()
            }
        }

        let addedLog = batchLogger.addLog(api: api, lat: lat, lon: lon, time: time, ext: ext, retryOnErrorCount: 5)
        XCTAssert(addedLog.api == api
                    && addedLog.latitude == lat
                    && addedLog.longitude == lon
                    && addedLog.time == time
                    && addedLog.ext == ext
                    && addedLog.retryCount == 5, "Incorrect log values")
        waitForExpectations(timeout: 300)
        XCTAssert(dbManager.addLogCalled, "Log not added to db")
        XCTAssert(dbManager.updateCalled, "Log not deleted from db")
    }
}

class BatchLoggerDelegateImplementation: BatchLoggerDelegate {
    var didUpdateLogCalled: Bool = false
    func didUpdateLog(_ success: Bool, error: NetworkError?, log: GeoLog, retryExpired: Bool) {
        didUpdateLogCalled = true
    }
}

class DBManagetStub: DBManagerType {
    var addLogCalled: Bool = false, allLogsCalled: Bool = false, deleteCalled: Bool = false, updateCalled = false

    var allLogs: [GeoLog] = []
    var deleteLogCallback: (() -> ())?
    var updateLogCallback: ((GeoLog) -> Void)?

    func add(_ log: GeoLog) throws {
        addLogCalled = true
    }

    func allLogs(_ complition: @escaping ([GeoLog]) -> Void) {
        allLogsCalled = true
        complition(allLogs)
    }

    func delete(_ log: GeoLog) {
        deleteCalled = true
        deleteLogCallback?()
    }

    func update(_ log: GeoLog) {
        updateCalled = true
        updateLogCallback?(log)
    }
}

class NetworkManagerStub: NetworkManagerType {
    var postCalled: Bool = false

    var responseStatusSuccess: Bool = false
    var responseError: NetworkError? = nil

    func post(_ url: URL, body: [String : Any], complition: @escaping (Bool, NetworkError?) -> Void) throws {
        postCalled = true
        complition(responseStatusSuccess, responseError)
    }
}
