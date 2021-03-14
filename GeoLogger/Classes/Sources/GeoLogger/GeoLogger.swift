import Foundation



public typealias LogResponse = ((_ success: Bool,_ retryCountLeft: Int?) -> Void)

public class GeoLogger: BatchLoggerDelegate {

    //MARK: - Private properties
    private var locationManager: LocationManagerType!
    private var batchManager: BatchLoggerType!
    private var callbackHolder: [Int64: LogResponse] = [:]
    internal static var instance = GeoLogger()

    internal init(){}

    //MARK: - Internal methods

    static func internalSetup(
        locationManager: LocationManagerType = LocationManager.shared,
        batchLogger: BatchLoggerType = BatchLogger(DBManager.shared, networkManager: NetworkManager(), delegate: instance)
    ){
        instance.locationManager = locationManager
        instance.batchManager = batchLogger
        batchLogger.startSync()
    }

    //MARK: - Public methods
    public static func setup() {
        internalSetup()
    }

    /// Show location permission dialog if location permission is not provided
    /// If `settingsAlertTitle` and `settingsAlertDescription` are provided the SDK will show a popup allowing user to open settings app and privide location permissions again.
    /// - Parameters:
    ///   - allowBackgroundLocationTracking: If true SDK will track user location in background. Default is `false`
    ///   - requestTemporaryFullAccuracy: If precise location is not allowed for the app, passing a true value will ask user for temporary access for the same. This temporary access will be valid for the current running session.
    ///   - error: Callback closure when the user has denied location access or the location permissions are disabled. This callback can be used to show feedback UI like an alert to the user. Default is `nil`
    public static func requestPermission(_ allowBackgroundLocationTracking: Bool = false,
                                  requestTemporaryFullAccuracy: Bool = true,
                                  error: ((_ locationPermissionDenied: Bool, _ locationServicesDisabled: Bool) -> Void)? = nil) {
        instance.locationManager.requestPermissions(allowBackgroundLocationTracking,
                                                  requestTemporaryPreciseLocation: requestTemporaryFullAccuracy) {[unowned instance] (persmissionsGranted, showOpenSettingsAlert, withPreciseLocation, locationServicesDisabled) in
            if (persmissionsGranted) {
                if (allowBackgroundLocationTracking) {
                    instance.locationManager.setupBackgroundMode()
                }
                instance.locationManager.startMonitoringLocation()
            } else {
                error?(showOpenSettingsAlert, locationServicesDisabled)
            }
        }
    }

    /// Logs provided location data to the given URL. The function fires a POST method request on the given API URL.
    ///
    /// If `monitorLocationInBackground` was `true` during setup and no value is provided in `lat` and `lon` parameters
    /// the SDK will pick the best lat, lon available depending on the permissions.
    ///
    ///
    /// - Parameters:
    ///   - api: API url where the location is logged.
    ///   - lat: Latitude to be logged
    ///   - lon: Longitude to be logged
    ///   - time: Time
    ///   - ext: Any extra parameter
    ///   - callback: Callback containing the status of the request
    public static func log(
        api: String,
        lat: Double = 0.0,
        lon: Double = 0.0,
        time: Int64 = 0, // epoch timestamp in seconds
        ext: String = "", // extra text payload
        retryOnErrorCount: Int = 3,
        callback: @escaping LogResponse
    ) {
        let latitude = lat <= 0.0 ? instance.locationManager.location?.latitude ?? 0.0 : lat
        let longitude = lon <= 0.0 ? instance.locationManager.location?.longitude ?? 0.0 : lon
        let logTime = time <= 0 ? Int64(NSDate().timeIntervalSince1970) : time
        let log = instance.batchManager.addLog(api: api, lat: latitude, lon: longitude, time: logTime, ext: ext, retryOnErrorCount: retryOnErrorCount)
        instance.callbackHolder[log.id] = callback
    }

    func didUpdateLog(_ success: Bool, error: NetworkError?, log: GeoLog, retryExpired: Bool) {
        if let callback = callbackHolder[log.id] {
            callback(success, success ? nil : log.retryCount)
            callbackHolder[log.id] = nil
        }
    }
}
