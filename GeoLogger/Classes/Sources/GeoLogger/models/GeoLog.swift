//
//  File.swift
//  
//
//  Created by Nishith on 07/03/21.
//

import Foundation

struct GeoLog: Hashable, Equatable {
    let api: String
    let latitude: Double
    let longitude: Double
    var retryCount: Int
    let time: Int64
    var ext: String
    let id: Int64

    init(api: String, latitude: Double, longitude: Double, retryCount: Int = 3, time: Int64, ext: String = "", id: Int64 = Int64(Date().timeIntervalSince1970 * 1000)) {
        self.api = api
        self.latitude = latitude
        self.longitude = longitude
        self.retryCount = retryCount
        self.time = time
        self.ext = ext
        self.id = id
    }

    static func from(_ geoLog: GeoLog_Realm) -> GeoLog {
        GeoLog(api: geoLog.api, latitude: geoLog.latitude, longitude: geoLog.longitude, retryCount: geoLog.retryCount,time: geoLog.time, ext: geoLog.ext, id: geoLog.id)
    }

    func toGeoLogRealm() -> GeoLog_Realm {
        let geoLogRealm = GeoLog_Realm()
        geoLogRealm.api = api
        geoLogRealm.latitude = latitude
        geoLogRealm.longitude = longitude
        geoLogRealm.retryCount = retryCount
        geoLogRealm.time = time
        geoLogRealm.ext = ext
        geoLogRealm.id = id
        return geoLogRealm
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
