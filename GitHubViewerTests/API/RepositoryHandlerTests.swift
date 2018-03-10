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
        testObject = GithubRepositoryHandler(githubApiHandler: githubApiHandler, loginHandler: loginHandler)
        loginHandler.oauthToken = "ABCDE"
        loginHandler.user = User(login: "lindanordstrom", name: nil, avatar_url: nil, location: nil, company: nil)
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
    func testGetRepositoriesWhenNoOauthTokenExists() {
        loginHandler.oauthToken = nil
        testObject.getRepositories() { _ in }

        XCTAssertFalse(githubApiHandler.networkRequestWasCalled)
    }

    // given: get repositories is called
    // when: data is returned with an array with a repository object
    // then: the closure is called with the created array of repositories
    func testGetRepositoriesDataRetunedAsRepositories() {
        let exp = expectation(description: "closure called")

        let repoDict = [["name":"Testrepo", "language": "Swift", "owner": ["login": "lindanordstrom"]],
                        ["name":"Testrepo2", "language": "Swift", "owner": ["login": "lindanordstrom"]]]
        githubApiHandler.data = try? JSONSerialization.data(withJSONObject: repoDict, options: .prettyPrinted)

        testObject.getRepositories() { repos in
            XCTAssertEqual(repos?.count, 2)
            XCTAssertEqual(repos?.first?.name, "Testrepo")
            XCTAssertEqual(repos?.first?.language, "Swift")
            exp.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if error != nil { XCTFail() }
        }
    }

    // given: get repositories is called
    // when: data is returned with an array with a repository object where some repos are not owned by the signed in user
    // then: the closure is called with an array of repositories that is owned by the user
    func testGetRepositoriesDataRetunedAsRepositoriesWithSomeNotOwnedBySignedInUser() {
        let exp = expectation(description: "closure called")
        
        let repoDict = [["name":"Testrepo", "language": "Swift", "owner": ["login": "kalleanka"]],
                        ["name":"Testrepo2", "language": "Swift", "owner": ["login": "lindanordstrom"]]]
        githubApiHandler.data = try? JSONSerialization.data(withJSONObject: repoDict, options: .prettyPrinted)

        testObject.getRepositories() { repos in
            XCTAssertEqual(repos?.count, 1)
            XCTAssertEqual(repos?.first?.name, "Testrepo2")
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
    func testGetRepositoriesWrongDataReturned() {
        let exp = expectation(description: "closure called")

        let repoDict = [["name":123]]
        githubApiHandler.data = try? JSONEncoder().encode(repoDict)

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
    func testGetRepositoriesWithError() {
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

    // given: oauth token and signed in user exists
    // when: get commits is called
    // then: a fetch call is made to the API handler
    func testGetCommitsWhenOauthTokenExists() {
        testObject.getCommits(for: "test") { _ in }

        XCTAssertEqual(githubApiHandler.url?.absoluteString, "https://api.github.com/repos/lindanordstrom/test/commits")
        XCTAssertEqual(githubApiHandler.parameters as! [String: String], ["access_token":"ABCDE"])
        XCTAssertTrue(githubApiHandler.networkRequestWasCalled)
    }

    // given: oauth token does not exists
    // when: get commits is called
    // then: no fetch call is made to the API handler
    func testGetCommitsWhenNoOauthTokenExists() {
        loginHandler.oauthToken = nil
        testObject.getRepositories() { _ in }

        XCTAssertFalse(githubApiHandler.networkRequestWasCalled)
    }

    // given: no user exists
    // when: get commits is called
    // then: no fetch call is made to the API handler
    func testGetCommitsWhenNoUserExists() {
        loginHandler.user = nil

        testObject.getCommits(for: "testrepo") { _ in }

        XCTAssertFalse(githubApiHandler.networkRequestWasCalled)
    }

    // given: get commits is called
    // when: data is returned with an array with commit object
    // then: the closure is called with the created array of commits
    func testGetCommitsDataRetunedAsCommits() {
        let exp = expectation(description: "closure called")

        let commitDict = [["commit": ["message": "test", "author": ["date": "2018-03-02T20:56:48Z"]]]]
        githubApiHandler.data = try? JSONSerialization.data(withJSONObject: commitDict, options: .prettyPrinted)

        testObject.getCommits(for: "testrepo") { commits in
            XCTAssertEqual(commits?.first?.commit?.message, "test")
            XCTAssertEqual(commits?.first?.commit?.author?.date, "2018-03-02T20:56:48Z")
            exp.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if error != nil { XCTFail() }
        }
    }

    // given: get commits is called
    // when: data is returned that does not match commit objects
    // then: the closure is called without any repository object
    func testGetCommitsWrongDataReturned() {
        let exp = expectation(description: "closure called")

        let commitDict = [["commit":123]]
        githubApiHandler.data = try? JSONEncoder().encode(commitDict)

        testObject.getCommits(for: "testrepo") { commits in
            XCTAssertNil(commits)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if error != nil { XCTFail() }
        }
    }

    // given: get commits is called
    // when: error is returned
    // then: the closure is called without any repository object
    func testGetCommitsWithError() {
        let exp = expectation(description: "closure called")

        githubApiHandler.error = NSError(domain: "test", code: 1, userInfo: nil)

        testObject.getCommits(for: "testrepo") { commits in
            XCTAssertNil(commits)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if error != nil { XCTFail() }
        }
    }
}

