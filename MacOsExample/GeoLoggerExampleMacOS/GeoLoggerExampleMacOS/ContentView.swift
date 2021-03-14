//
//  ContentView.swift
//  GeoLoggerExampleMacOS
//
//  Created by Nishith on 14/03/21.
//

import SwiftUI
import GeoLoggerSDK

struct ContentView: View {
    @State var showsAlert = false

    var body: some View {
        VStack {
            Spacer()
            Button("Ask for location permission") {
                GeoLogger.requestPermission(true, requestTemporaryFullAccuracy: true) { (locationPermissionDenied, locationServicesDisabled) in
                    showsAlert.toggle()
                }
            }
            Button("Log") {
                GeoLogger.log(api: "<Your api post url>", ext: "Providing ext") { (success, retryCount) in
                    print("\(success), retry count \(retryCount)")
                }
            }
            Spacer()
        }.alert(isPresented: $showsAlert, content: {
            return Alert(title: Text("Error"),
                  message: Text("Please open system settings to provide location permission"),
                  dismissButton: .cancel(Text("Ok")))
        }).frame(minWidth: 300)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
