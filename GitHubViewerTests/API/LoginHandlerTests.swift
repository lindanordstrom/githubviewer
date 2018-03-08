//
//  LoginHandlerTests.swift
//  GitHubViewerTests
//
//  Created by Linda on 2018-03-07.
//  Copyright © 2018 LindaCCNordstrom. All rights reserved.
//

import XCTest
@testable import GitHubViewer

class LoginHandlerTests: XCTestCase {

    var testObject: LoginHandler!
    var dataStore: TestUserDefaults!
    var githubApiHandler: TestApiHandler!
    var application: TestApplication!

    override func setUp() {
        super.setUp()
        dataStore = TestUserDefaults()
        githubApiHandler = TestApiHandler()
        application = TestApplication()
        testObject = GithubLoginHandler(dataStore: dataStore, githubApiHandler: githubApiHandler, application: application)
    }

    override func tearDown() {
        dataStore = nil
        testObject = nil
        githubApiHandler = nil
        application = nil
        super.tearDown()
    }

    // given: oauth token exists in data storage
    // when: calling hasOauthToken
    // then: TRUE should be returned
    func testHasOauthTokenWhenTokenExists() {
        dataStore.value = "1234"

        XCTAssertTrue(testObject.hasOauthToken())
        XCTAssertTrue(dataStore.stringForKeyCalled)
    }

    // given: oauth token does not exists in data storage
    // when: calling hasOauthToken
    // then: FALSE should be returned
    func testHasOauthTokenWhenNoTokenExists() {
        dataStore.value = nil

        XCTAssertFalse(testObject.hasOauthToken())
        XCTAssertTrue(dataStore.stringForKeyCalled)
    }

    // given: oauth token exists in data storage
    // when: calling getOauthToken
    // then: the token value should be returned
    func testGetOauthTokenWhenTokenExists() {
        dataStore.value = "1234"

        XCTAssertEqual(testObject.getOauthToken(), dataStore.value)
    }

    // given: oauth token does not exists in data storage
    // when: calling getOauthToken
    // then: nil should be returned
    func testGetOauthTokenWhenNoTokenExists() {
        dataStore.value = nil

        XCTAssertNil(testObject.getOauthToken())
    }

    // when calling navigateToLoginPage
    // then the correct URL should be opened
    func testNavigateToLoginPage() {
        testObject.navigateToLoginPage()

        XCTAssertTrue(application.openUrlCalled)
        XCTAssertEqual(application.url, URL(string: "https://github.com/login/oauth/authorize?client_id=\(GitHubHiddenConstants.clientId)&scope=repo%20user&state=TEST_STATE"))

    }

    // when: get token is called with an url with a code
    // then: a fetch call is made to the API handler
    func testGetTokenWithCode() {
        testObject.getToken(url: URL(string: "test://?code=12345")!)

        XCTAssertEqual(githubApiHandler.url?.absoluteString, "https://github.com/login/oauth/access_token")
        XCTAssertEqual(githubApiHandler.parameters as! [String: String], ["code": "12345"])
        XCTAssertTrue(githubApiHandler.networkRequestWasCalled)
    }

    // when: get token is called with an url without a code
    // then: no fetch call is made
    func testGetTokenWithoutCode() {
        testObject.getToken(url: URL(string: "test://?test=12345")!)

        XCTAssertFalse(githubApiHandler.networkRequestWasCalled)
    }

    // given: oauth token exists
    // when: get user details is called
    // then: a fetch call is made to the API handler
    func testGetUserDetailsWhenOauthTokenExists() {
        dataStore.value = "ABCDE"
        testObject.getUserDetails { _ in }

        XCTAssertEqual(githubApiHandler.url?.absoluteString, "https://api.github.com/user")
        XCTAssertEqual(githubApiHandler.parameters as! [String: String], ["access_token":"ABCDE"])
        XCTAssertTrue(githubApiHandler.networkRequestWasCalled)
    }

    // given: oauth token does not exists
    // when: get user details is called
    // then: no fetch call is made to the API handler
    func testGetUserDetailsWhenNoOauthTokenExists() {
        dataStore.value = nil
        testObject.getUserDetails { _ in }

        XCTAssertFalse(githubApiHandler.networkRequestWasCalled)
    }

    // given: user details is called
    // when: data is returned that matches the user object
    // then: the closure is called with the created  user
    func testGetUserDetailsDataRetunedAsUser() {
        dataStore.value = "ABCDE"
        let exp = expectation(description: "closure called")

        let userDict = ["name":"Linda Nordstrom", "location": "Sweden"]
        githubApiHandler.data = try? JSONEncoder().encode(userDict)

        testObject.getUserDetails { user in
            XCTAssertEqual(user?.name, "Linda Nordstrom")
            XCTAssertEqual(user?.location, "Sweden")
            exp.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if error != nil { XCTFail() }
        }
    }

    // given: user details is called
    // when: data is returned that does not match the user object
    // then: the closure is called without any user object
    func testGetUserDetailsWrongDataReturned() {
        dataStore.value = "ABCDE"
        let exp = expectation(description: "closure called")

        let userDict = ["name":123]
        githubApiHandler.data = try? JSONEncoder().encode(userDict)

        testObject.getUserDetails { user in
            XCTAssertNil(user)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if error != nil { XCTFail() }
        }
    }

    // given: user details is called
    // when: error is returned
    // then: the closure is called without any user object
    func testGetUserDetailsWithError() {
        dataStore.value = "ABCDE"
        let exp = expectation(description: "closure called")

        githubApiHandler.error = NSError(domain: "test", code: 1, userInfo: nil)

        testObject.getUserDetails { user in
            XCTAssertNil(user)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if error != nil { XCTFail() }
        }
    }

}



