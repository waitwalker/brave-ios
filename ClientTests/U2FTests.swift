/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import XCTest

import Shared
import Storage
import WebKit
import Alamofire
@testable import Client

class U2FTests: XCTestCase {
    
    let expectedrpID = "demo.brave.com"
    
    func testWebAuthnRegisterRequest() {
        let webAuthnRegisterData = "{\"publicKey\":{\"attestation\":\"direct\",\"authenticatorSelection\":{\"requireResidentKey\":false,\"userVerification\":\"discouraged\"},\"pubKeyCredParams\":[{\"alg\":-7,\"type\":\"public-key\"},{\"alg\":-257,\"type\":\"public-key\"}],\"rp\":{\"id\":\"demo.brave.com\",\"name\":\"Brave\"},\"timeout\":90000,\"challenge\": \"mdMbxTPACurawWFHqkoltSUwDear2OZQVl/uhBNqiaM=\",\"user\":{\"displayName\":\"Brave demo user\",\"name\":\"Brave demo user\",\"id\":\"OvQO5490o1w89Op/9dp4w7VvKuLEk5NHcfOnc2ZECtc=\"},\"excludeCredentials\":[]},\"signal\":{}}"
        guard let jsonData = webAuthnRegisterData.data(using: String.Encoding.utf8) else {
            XCTFail()
            return
        }
        
        do {
            let request =  try JSONDecoder().decode(WebAuthnRegisterRequest.self, from: jsonData)
            XCTAssertEqual(request.username, "Brave demo user", "request username is correct.")
            XCTAssertEqual(request.userID, "OvQO5490o1w89Op/9dp4w7VvKuLEk5NHcfOnc2ZECtc=", "request user id is correct.")
            XCTAssertEqual(request.rpID, expectedrpID, "request rp id is correct.")
            XCTAssertEqual(request.rpName, "Brave", "request rp name is correct.")
            XCTAssertEqual(request.pubKeyAlg, -7, "request pub key alg is correct.")
            XCTAssertFalse(request.residentKey, "request resident key is correct.")
            XCTAssertEqual(request.challenge, "mdMbxTPACurawWFHqkoltSUwDear2OZQVl/uhBNqiaM=", "request challenge is correct.")
        } catch {
            XCTFail()
        }
    }
    
    func testWebAuthnAuthenticateRequest() {
        let webAuthnAuthenticateData = "{\"publicKey\":{\"allowCredentials\":[{\"type\":\"public-key\",\"id\":\"OvQO5490o1w89Op/9dp4w7VvKuLEk5NHcfOnc2ZECtc=\"}],\"rpId\":\"demo.brave.com\",\"timeout\":90000,\"userVerification\":\"discouraged\",\"challenge\":\"mdMbxTPACurawWFHqkoltSUwDear2OZQVl/uhBNqiaM=\"},\"signal\":{}}"
        guard let jsonData = webAuthnAuthenticateData.data(using: String.Encoding.utf8) else {
            XCTFail()
            return
        }
        
        do {
            let request =  try JSONDecoder().decode(WebAuthnAuthenticateRequest.self, from: jsonData)
            XCTAssertEqual(request.rpID, expectedrpID, "request rp id is correct.")
            XCTAssertEqual(request.challenge, "mdMbxTPACurawWFHqkoltSUwDear2OZQVl/uhBNqiaM=", "request challenge is correct.")
            XCTAssertEqual(request.allowCredentials.count, 1, "request allowCredential count is correct")
            XCTAssertEqual(request.allowCredentials.first, "OvQO5490o1w89Op/9dp4w7VvKuLEk5NHcfOnc2ZECtc=", "request allowCredential is correct")
        } catch {
            XCTFail()
        }
    }
    
    func testValidateRPId() {
        guard let currentURL = URL(string: "https://rp.example.domain") else {
            XCTFail()
            return
        }
        
        var rpIdURLs = [
            "rp.example.domain", // valid
            "example.domain",    // valid
            "https://bp.example.domain",
            "https://test.examples.domain.com",
            "https://test.rp.examples.domain",
            "https://domain"
        ]
        
        let tab = Tab(configuration: WKWebViewConfiguration())
        let U2FExtension = U2FExtensions(tab: tab)
        XCTAssertTrue(U2FExtension.validateRPID(url: currentURL.absoluteString, rpId: rpIdURLs.removeFirst()), "rpID URL is valid.")
        XCTAssertTrue(U2FExtension.validateRPID(url: currentURL.absoluteString, rpId: rpIdURLs.removeFirst()), "rpID URL is valid.")
        for url in rpIdURLs {
            XCTAssertFalse(U2FExtension.validateRPID(url: currentURL.absoluteString, rpId: url), "rpID URLs is invalid.")
        }
    }
}