//
//  File.swift
//  
//
//  Created by Nishith on 07/03/21.
//

import Foundation

protocol BatchLoggerDelegate: class {
    func didUpdateLog(_ success: Bool, error: NetworkError?, log: GeoLog, retryExpired: Bool)
}

protocol BatchLoggerType {
    func addLog(api: String,
                lat: Double,
                lon: Double,
                time: Int64,
                ext: String,
                retryOnErrorCount: Int) -> GeoLog
    func startSync()
}

class BatchLogger: BatchLoggerType {
    
    //MARK: - Private properties
    private let dbManager: DBManagerType
    private var isSyncing: Bool = false
    private let networkManager: NetworkManagerType
    /// Represents a semaphore that will force only 3 parallel log sync network requests
    private let logSyncSemaphore = DispatchSemaphore(value: 3)
    private weak var delegate: BatchLoggerDelegate?
    
    //MARK: - Internal methods
    
    init(_ dbmanager: DBManagerType, networkManager: NetworkManagerType, delegate: BatchLoggerDelegate?) {
        self.dbManager = dbmanager
        self.networkManager = networkManager
        self.delegate = delegate
    }
    
    func addLog(api: String,
                lat: Double,
                lon: Double,
                time: Int64,
                ext: String,
                retryOnErrorCount: Int = 3) -> GeoLog {
        let geolog = GeoLog(api: api, latitude: lat, longitude: lon, retryCount: retryOnErrorCount, time: time, ext: ext)
        try? dbManager.add(geolog)
        startSync()
        return geolog
    }
    
    func startSync() {
        if isSyncing {
            return
        }
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.isSyncing = true
            self?.dbManager.allLogs() { allLogs in
                var logs = Queue(allLogs)
                
                func reduceRetryCountOrDelete(_ log: GeoLog, error: NetworkError) {
                    if log.retryCount <= 0 {
                        self?.delegate?.didUpdateLog(false, error: error, log: log, retryExpired: true)
                        self?.dbManager.delete(log)
                    } else {
                        var log = log
                        log.retryCount -= 1
                        self?.delegate?.didUpdateLog(false, error: error, log: log, retryExpired: false)
                        self?.dbManager.update(log)
                        logs.enqueue(log)
                    }
                }
                
                while !logs.isEmpty {
                    self?.logSyncSemaphore.wait()
                    if let log = logs.dequeue() {
                        if let api = URL(string: log.api) {
                            let payload: [String: Any] = [
                                "lat": log.latitude,
                                "lon": log.longitude,
                                "time": log.time,
                                "ext": log.ext,
                            ]
                            do {
                                try self?.networkManager.post(api, body: payload) {[unowned self] (success, error) in
                                    if success {
                                        self?.delegate?.didUpdateLog(true, error: nil, log: log, retryExpired: true)
                                        self?.dbManager.delete(log)
                                    } else if let responseError = error {
                                        reduceRetryCountOrDelete(log, error: responseError)
                                    } else {
                                        reduceRetryCountOrDelete(log, error: .unknown)
                                    }
                                    self?.logSyncSemaphore.signal()
                                }
                            } catch {
                                reduceRetryCountOrDelete(log, error: .unknown)
                                self?.logSyncSemaphore.signal()
                            }
                        } else {
                            self?.dbManager.delete(log)
                            logs.dequeue()
                            self?.delegate?.didUpdateLog(false, error: .unknown, log: log, retryExpired: true)
                            self?.logSyncSemaphore.signal()
                        }
                    }
                }
                self?.isSyncing = false
            }
        }
    }
}
