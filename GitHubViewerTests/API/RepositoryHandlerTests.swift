//
//  RepositoryHandlerTests.swift
//  GitHubViewerTests
//
//  Created by Linda on 2018-03-08.
//  Copyright © 2018 LindaCCNordstrom. All rights reserved.
//

import XCTest
@testable import GitHubViewer

class RepositoryHandlerTests: XCTestCase {

    var testObject: RepositoryHandler!
    var githubApiHandler: TestApiHandler!
    var loginHandler: TestLoginHandler!

    override func setUp() {
        super.setUp()
        githubApiHandler = TestApiHandler()
        loginHandler = TestLoginHandler()
        testObject = RepositoryHandler(githubApiHandler: githubApiHandler, loginHandler: loginHandler)
        loginHandler.oauthToken = "ABCDE"
    }

    override func tearDown() {
        testObject = nil
        githubApiHandler = nil
        loginHandler = nil
        super.tearDown()
    }

    // given: oauth token exists
    // when: get repositories is called
    // then: a fetch call is made to the API handler
    func testGetRepositoriesWhenOauthTokenExists() {
        testObject.getRepositories() { _ in }

        XCTAssertEqual(githubApiHandler.url?.absoluteString, "https://api.github.com/user/repos")
        XCTAssertEqual(githubApiHandler.parameters as! [String: String], ["access_token":"ABCDE"])
        XCTAssertTrue(githubApiHandler.networkRequestWasCalled)
    }

    // given: oauth token does not exists
    // when: get repositories is called
    // then: no fetch call is made to the API handler
    func testGetUserDetailsWhenNoOauthTokenExists() {
        loginHandler.oauthToken = nil
        testObject.getRepositories() { _ in }

        XCTAssertFalse(githubApiHandler.networkRequestWasCalled)
    }

    // given: get repositories is called
    // when: data is returned with an array with a repository object
    // then: the closure is called with the created array of repositories
    func testGetUserDetailsDataRetunedAsUser() {
        let exp = expectation(description: "closure called")

        let userDict = [["name":"Testrepo", "language": "Swift"]]
        githubApiHandler.data = try? JSONEncoder().encode(userDict)

        testObject.getRepositories() { repos in
            XCTAssertEqual(repos?.first?.name, "Testrepo")
            XCTAssertEqual(repos?.first?.language, "Swift")
            exp.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if error != nil { XCTFail() }
        }
    }

    // given: get repositories is called
    // when: data is returned that does not match repository objects
    // then: the closure is called without any repository object
    func testGetUserDetailsWrongDataReturned() {
        let exp = expectation(description: "closure called")

        let userDict = [["name":123]]
        githubApiHandler.data = try? JSONEncoder().encode(userDict)

        testObject.getRepositories() { repos in
            XCTAssertNil(repos)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if error != nil { XCTFail() }
        }
    }

    // given: get repositories is called
    // when: error is returned
    // then: the closure is called without any repository object
    func testGetUserDetailsWithError() {
        let exp = expectation(description: "closure called")

        githubApiHandler.error = NSError(domain: "test", code: 1, userInfo: nil)

        testObject.getRepositories() { repos in
            XCTAssertNil(repos)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if error != nil { XCTFail() }
        }
    }
}

