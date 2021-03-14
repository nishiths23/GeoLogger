//
//  File.swift
//  
//
//  Created by Nishith on 07/03/21.
//

import Foundation
import RealmSwift


protocol DBManagerType {
    func add(_ log: GeoLog) throws
    func allLogs(_ complition: @escaping ([GeoLog]) -> Void )
    func delete(_ log: GeoLog)
    func update(_ log: GeoLog)
}

class DBManager: DBManagerType {

    //MARK: - Internal properties
    static let shared = DBManager()
    private let dbQueue = DispatchQueue(label: "com.geoLogger.db", qos: .background)

    //MARK: - Internal methods
    func add(_ log: GeoLog) {
        dbQueue.async {
            let realm = try! Realm()
            realm.refresh()
            do {
                try realm.write {
                    realm.add(log.toGeoLogRealm())
                }
            } catch let e {
                print(e)
            }
        }
    }

    func allLogs(_ complition: @escaping ([GeoLog]) -> Void ) {
        dbQueue.async {
            let realm = try! Realm()
            realm.refresh()
            let logs = realm.objects(GeoLog_Realm.self)
            complition(Array(logs.map { GeoLog.from($0) }))
        }
    }

    func delete(_ log: GeoLog) {
        dbQueue.async { [unowned self] in
            let realm = try! Realm(queue: dbQueue)
            realm.refresh()
            if let log = realm.object(ofType: GeoLog_Realm.self, forPrimaryKey: log.id) {
                do {
                    try realm.write {
                        realm.delete(log)
                    }
                } catch let e {
                    print(e)
                }
            }
        }
    }

    func update(_ log: GeoLog) {
        dbQueue.async {
            let realm = try! Realm()
            realm.refresh()
            if let logRef = realm.object(ofType: GeoLog_Realm.self, forPrimaryKey: log.id) {
                do {
                    try realm.write {
                        logRef.api = log.api
                        logRef.latitude = log.latitude
                        logRef.longitude = log.longitude
                        logRef.retryCount = log.retryCount
                        logRef.ext = log.ext
                        realm.add(logRef, update: .modified)
                    }
                } catch let e {
                    print(e)
                }
            }
        }
    }

    //MARK: - Private methods
    private init() {}
}
