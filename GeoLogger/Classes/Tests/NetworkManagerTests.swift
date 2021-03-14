//
//  File.swift
//  
//
//  Created by Nishith on 13/03/21.
//

import Foundation
import XCTest
import Hippolyte
@testable import GeoLoggerSDK

class NetworkManagerTests: XCTestCase {

    static let successRequestUrl = URL(string: "http://successResponse")!
    static let failedRequestUrl = URL(string: "http://failedResponse")!

    class func setupStubbedServer() {
        let response = StubResponse.Builder()
            .stubResponse(withStatusCode: 200)
            .addHeader(withKey: "X-Foo", value: "Bar")
            .addBody("{\"success\": true}".data(using: .utf8)!)
            .build()
        let request = StubRequest.Builder()
            .stubRequest(withMethod: .POST, url: successRequestUrl)
            .addResponse(response)
            .build()

        let responseFailed = StubResponse.Builder()
            .stubResponse(withStatusCode: 500)
            .addHeader(withKey: "X-Foo", value: "Bar")
            .addBody("{\"success\": false}".data(using: .utf8)!)
            .build()
        let requestFailed = StubRequest.Builder()
            .stubRequest(withMethod: .POST, url: failedRequestUrl)
            .addResponse(responseFailed)
            .build()

        Hippolyte.shared.add(stubbedRequest: requestFailed)
        Hippolyte.shared.add(stubbedRequest: request)
        Hippolyte.shared.start()
    }

    override class func setUp() {
        super.setUp()
        setupStubbedServer()
    }

    override class func tearDown() {
        super.tearDown()
        Hippolyte.shared.stop()
        Hippolyte.shared.clearStubs()
    }

    func testApiSuccessResponse() {
        let exp = expectation(description: "Network response is successful")
        do {
            try NetworkManager().post(NetworkManagerTests.successRequestUrl, body: ["param":"value"]) { (success, error) in
                XCTAssert(success, "Network response unsuccessful when expected success")
                exp.fulfill()
            }
        } catch {
            XCTAssert(false, "Unexpected throw")
        }
        waitForExpectations(timeout: 10)
    }

    func testApiFailedResponse() {
        let exp = expectation(description: "Network response is successful")
        do {
            try NetworkManager().post(NetworkManagerTests.failedRequestUrl, body: ["param":"value"]) { (success, error) in
                XCTAssertFalse(success, "Network response unsuccessful when expected success")
                XCTAssertFalse(error == nil, "Error is nil")
                exp.fulfill()
            }
        } catch {
            XCTAssert(false, "Unexpected throw")
        }
        waitForExpectations(timeout: 10)
    }


}
