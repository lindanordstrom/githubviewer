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
        dataStore.keyValue[Constants.UserDefaultsConstants.oauthToken] = "1234"

        XCTAssertTrue(testObject.hasOauthToken())
        XCTAssertTrue(dataStore.objectForKeyCalled)
    }

    // given: oauth token does not exists in data storage
    // when: calling hasOauthToken
    // then: FALSE should be returned
    func testHasOauthTokenWhenNoTokenExists() {
        dataStore.keyValue[Constants.UserDefaultsConstants.oauthToken] = nil

        XCTAssertFalse(testObject.hasOauthToken())
        XCTAssertTrue(dataStore.objectForKeyCalled)
    }

    // given: oauthToken and user exists
    // when: calling clearUserDetails
    // then: the token and user should be removed
    func testClearUserDetails() {
        dataStore.keyValue[Constants.UserDefaultsConstants.oauthToken] = "1234"
        dataStore.keyValue[Constants.UserDefaultsConstants.signedInUser] = User(login: "lindanordstrom", name: nil, avatar_url: nil, location: nil, company: nil)

        testObject.clearUserDetails()

        XCTAssertTrue(dataStore.removeObjectForKeyCalled)
        XCTAssertNil(dataStore.keyValue[Constants.UserDefaultsConstants.oauthToken] ?? nil)
        XCTAssertNil(dataStore.keyValue[Constants.UserDefaultsConstants.signedInUser] ?? nil)
    }

    // given: oauth token exists in data storage
    // when: calling getOauthToken
    // then: the token value should be returned
    func testGetOauthTokenWhenTokenExists() {
        dataStore.keyValue[Constants.UserDefaultsConstants.oauthToken] = "1234"

        XCTAssertEqual(testObject.getOauthToken(), "1234")
    }

    // given: oauth token does not exists in data storage
    // when: calling getOauthToken
    // then: nil should be returned
    func testGetOauthTokenWhenNoTokenExists() {
        dataStore.keyValue[Constants.UserDefaultsConstants.oauthToken] = nil

        XCTAssertNil(testObject.getOauthToken())
    }

    // given: user exists in data storage
    // when: calling getSignedInUser
    // then: the user should be returned
    func testGetSignedInUserWhenUserExists() {
        let user = User(login: "lindanordstrom", name: nil, avatar_url: nil, location: nil, company: nil)
        dataStore.keyValue[Constants.UserDefaultsConstants.signedInUser] = NSKeyedArchiver.archivedData(withRootObject: user)

        XCTAssertEqual(testObject.getSignedInUser()?.login, user.login)
    }

    // given: user does not exists in data storage
    // when: calling getSignedInUser
    // then: nil should be returned
    func testGetSignedInUserWhenNoUserExists() {
        dataStore.keyValue[Constants.UserDefaultsConstants.signedInUser] = nil

        XCTAssertNil(testObject.getSignedInUser())
    }

    // when calling navigateToLoginPage
    // then the correct URL should be opened
    func testNavigateToLoginPage() {
        testObject.navigateToLoginPage() {}

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

    // given: get token is called with an url with a code
    // when: data is returned with an access token
    // then: the access token is set in the data store
    func testGetTokenWithCodeDataReturnedWithAccessToken() {
        let userDict = ["access_token":"testtest"]
        githubApiHandler.data = try? JSONEncoder().encode(userDict)
        testObject.getToken(url: URL(string: "test://?code=12345")!)
        XCTAssertEqual(dataStore.keyValue[Constants.UserDefaultsConstants.oauthToken] as? String, "testtest")
    }

    // given: oauth token exists
    // when: get user details is called
    // then: a fetch call is made to the API handler
    func testGetUserDetailsWhenOauthTokenExists() {
        dataStore.keyValue[Constants.UserDefaultsConstants.oauthToken] = "ABCDE"
        testObject.getUserDetails { _ in }

        XCTAssertEqual(githubApiHandler.url?.absoluteString, "https://api.github.com/user")
        XCTAssertEqual(githubApiHandler.parameters as! [String: String], ["access_token":"ABCDE"])
        XCTAssertTrue(githubApiHandler.networkRequestWasCalled)
    }

    // given: oauth token does not exists
    // when: get user details is called
    // then: no fetch call is made to the API handler
    func testGetUserDetailsWhenNoOauthTokenExists() {
        dataStore.keyValue[Constants.UserDefaultsConstants.oauthToken] = nil
        testObject.getUserDetails { _ in }

        XCTAssertFalse(githubApiHandler.networkRequestWasCalled)
    }

    // given: user details is called
    // when: data is returned that matches the user object
    // then: the closure is called with the created  user
    func testGetUserDetailsDataRetunedAsUser() {
        dataStore.keyValue[Constants.UserDefaultsConstants.oauthToken] = "ABCDE"
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
        dataStore.keyValue[Constants.UserDefaultsConstants.oauthToken] = "ABCDE"
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
        dataStore.keyValue[Constants.UserDefaultsConstants.oauthToken] = "ABCDE"
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



