//
//  GeoLoggerExampleMacOSApp.swift
//  GeoLoggerExampleMacOS
//
//  Created by Nishith on 14/03/21.
//

import SwiftUI
import GeoLoggerSDK

@main
struct GeoLoggerExampleMacOSApp: App {

    let initializeGeoLogger: Void = {
        GeoLogger.setup()
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    let _ = initializeGeoLogger
            }
        }
    }
}
