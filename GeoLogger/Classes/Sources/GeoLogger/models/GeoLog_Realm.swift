//
//  File.swift
//  
//
//  Created by Nishith on 07/03/21.
//

import Foundation
import RealmSwift

class GeoLog_Realm: Object {
    @objc dynamic var api: String = ""
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    @objc dynamic var retryCount: Int = 3
    @objc dynamic var time: Int64 = 0
    @objc dynamic var ext: String = ""
    @objc dynamic var id: Int64 = 0

    override class func primaryKey() -> String? {
        "id"
    }
}
