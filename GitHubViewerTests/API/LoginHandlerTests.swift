//
//  LoginHandlerTests.swift
//  GitHubViewerTests
//
//  Created by Yaser on 2018-03-07.
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
        testObject = LoginHandler(dataStore: dataStore, githubApiHandler: githubApiHandler, application: application)
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

    // when calling navigateToLoginPage
    // then the correct URL should be opened
    func testNavigateToLoginPage() {
        testObject.navigateToLoginPage()

        XCTAssertTrue(application.openUrlCalled)
        XCTAssertEqual(application.url, URL(string: "https://github.com/login/oauth/authorize?client_id=\(GitHubHiddenConstants.clientId)&scope=repo&state=TEST_STATE"))

    }

    // when: get token is called with an url with a code
    // then: a fetch call is made to the API handler
    func testGetTokenWithCode() {

        testObject.getToken(url: URL(string: "test://?code=12345")!)

        XCTAssertEqual(githubApiHandler.url?.absoluteString, "https://github.com/login/oauth/access_token")
        XCTAssertEqual(githubApiHandler.parameters as! [String: String], ["client_id": GitHubHiddenConstants.clientId, "client_secret": GitHubHiddenConstants.clientSecret, "code": "12345"])
        XCTAssertEqual(githubApiHandler.headers!, ["Accept": "application/json"])
        XCTAssertTrue(githubApiHandler.fetchJSONwasCalled)
    }

    // when: get token is called with an url without a code
    // then: no fetch call is made
    func testGetTokenWithoutCode() {

        testObject.getToken(url: URL(string: "test://?test=12345")!)

        XCTAssertFalse(githubApiHandler.fetchJSONwasCalled)
    }

}

class TestUserDefaults: DataStore {
    var setValueForKeyCalled = false
    var stringForKeyCalled = false
    var key: String?
    var value: String?

    func set(_ value: Any?, forKey defaultName: String) {
        self.key = defaultName
        self.value = value as? String
        setValueForKeyCalled = true
    }

    func string(forKey: String) -> String? {
        stringForKeyCalled = true
        key = forKey
        return value
    }
}

class TestApiHandler: APIHandler {
    var url: URL?
    var parameters: [String: Any]?
    var headers: [String: String]?
    var fetchJSONwasCalled = false


    func fetchJSON(url: URL, parameters: [String : Any]?, headers: [String : String]?, closure: @escaping ((Data?, Error?) -> Void)) {
        self.url = url
        self.parameters = parameters
        self.headers = headers
        fetchJSONwasCalled = true
    }
}

class TestApplication: Application {
    var url: URL?
    var openUrlCalled = false

    func open(_ url: URL, options: [String : Any], completionHandler completion: ((Bool) -> Void)?) {
        self.url = url
        openUrlCalled = true
    }
}

