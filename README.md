# GeoLogger

[![Build and test](https://github.com/nishiths23/GeoLogger/actions/workflows/Build%20and%20test.yml/badge.svg)](https://github.com/nishiths23/GeoLogger/actions/workflows/Build%20and%20test.yml)
[![Version](https://img.shields.io/cocoapods/v/GeoLoggerSDK.svg?style=flat)](https://cocoapods.org/pods/GeoLoggerSDK)
[![License](https://img.shields.io/cocoapods/l/GeoLoggerSDK.svg?style=flat)](https://cocoapods.org/pods/GeoLoggerSDK)
[![Platform](https://img.shields.io/cocoapods/p/GeoLoggerSDK.svg?style=flat)](https://cocoapods.org/pods/GeoLoggerSDK) 
[![codecov](https://codecov.io/gh/nishiths23/GeoLogger/branch/main/graph/badge.svg?token=iBd7Q8C9W7)](https://codecov.io/gh/nishiths23/GeoLogger)


## Example


A package to log location events.

## Installation

GeoLogger is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'GeoLoggerSDK'
```

Add the following to your `info.plist` file

```xml
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>The app needs both when in use and background location permission</string>
    <key>NSLocationTemporaryUsageDescriptionDictionary</key>
    <dict>
        <key>TemporaryAccuracyAuthPurposeKey</key>
        <string>This app needs accurate location so it can verify that you&apos;re in a supported region.</string>
    </dict>
    <key>NSLocationUsageDescription</key>
    <string>The app needs always location permission</string>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>The app needs when in use location permission</string>
```
These keys include background, foreground and precise location permission keys.
You can modify the strings for these keys according to your project and requirement

## Usage

### iOS and MacOS

Additional steps are required to add background location access.

- Go to your project -> Signing & Capabilities -> + Capability and add `Background Modes` capability
- Tick `Location updates` checkbox

#### Requirements

##### Min iOS build target - iOS14.4
##### Min MacOS build target - MacOS 11.0
#### Implementation

 Add the following import at the top of your file
 
 `import GeoLogger`

 - For SwiftUI apps add the following setup code to your `@main` `struct`

 ```swift
 var body: some Scene {
        WindowGroup {
            ContentView()
        }.onAppear {
            GeoLogger.setup()
        }
    }
 ```

 - For storyboard based apps add the following to your `application(_:didFinishLaunchingWithOptions:)` in `AppDelegate.swift`

```swift
GeoLogger.setup()
```

##### Next

You will need to ask the user for location permissions. Depending on your app and use case you can decide when and where you would like to do that. To request for location permissions call `requestPermission` method from the SDK

```swift
GeoLogger.requestPermission(true, requestTemporaryFullAccuracy: true) { (locationPermissionDenied, locationServicesDisabled) in }
```
Parameters:
- `allowBackgroundLocationTracking`: Passing true will ask the user for background permissions
- `requestTemporaryFullAccuracy`: Passing true will ask the user for temporary precise location permission if not provided

Within the callback you get 2 parameters depending on the location access situation.

- `locationPermissionDenied`: True when the user has denied location permission for your app completely
- `locationServicesDisabled`: True when location services are disabled on the device

You can use these parameters to show an alert and in case of iOS open settings to prompt the user to grant location permissions to your app.

#### If the user has provided location permission to your app even bare minimum then this callback will not be called

Finall call the `log` method to register current location log

```swift
GeoLogger.log(api: "<Your POST api url>") { (success, retryCount) in }
```

This method will create a post request pointed to the provided URL and send current location coordinates along with the timestamp.

The library implements batch uploading and has a persistant `Realm` storage built in where it stores all the logs and syncs them max 3 at a time whenever the time is appropriate.

In case of an error the SDK will try to register the log again for `retryOnErrorCount` times.

If the log registration fails after `retryOnErrorCount` is expired(or is 0) then the log will be deleted from the storage.

In the `callback` you will be able to monitor the `success` and `retryCount` of the registered log.


## Author

nishiths23, nishithsingh23@ymail.com

## License

GeoLogger is available under the MIT license. See the LICENSE file for more info.
