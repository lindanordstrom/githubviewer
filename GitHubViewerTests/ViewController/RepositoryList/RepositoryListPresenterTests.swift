//
//  RepositoryListPresenter.swift
//  GitHubViewerTests
//
//  Created by Linda on 2018-03-08.
//  Copyright © 2018 LindaCCNordstrom. All rights reserved.
//

import XCTest
@testable import GitHubViewer

class RepositoryListPresenterTests: XCTestCase {

    var testObject: RepositoriesPresenter!
    var loginHandler: TestLoginHandler!
    var repositoryHandler: TestRepositoryHandler!
    var repositoriesUI: TestRepositoriesUI!

    override func setUp() {
        super.setUp()
        loginHandler = TestLoginHandler()
        repositoryHandler = TestRepositoryHandler()
        repositoriesUI = TestRepositoriesUI()
        testObject = RepositoriesPresenter(ui: repositoriesUI, loginHandler: loginHandler, repositoryHandler: repositoryHandler)
    }

    override func tearDown() {
        testObject = nil
        loginHandler = nil
        repositoryHandler = nil
        repositoriesUI = nil
        super.tearDown()
    }

    // given: oauth token exists
    // when: load repositories content is called
    // then: call to fetch repositories should be made
    func testLoadRepositoriesContentWhenTokenExists() {
        loginHandler.hasOauthTokenVar = true

        testObject.loadRepositoriesContent()

        XCTAssertTrue(repositoryHandler.getRepositoriesCalled)
    }

    // given: oauth token does not exists
    // when: load repositories content is called
    // then: user should be navigated back to the sign in page
    func testLoadRepositoriesContentWhenNoTokenExists() {
        loginHandler.hasOauthTokenVar = false

        testObject.loadRepositoriesContent()

        XCTAssertTrue(repositoriesUI.navigateToSignInScreenCalled)
    }

    // given: load repositories content is called
    // when: an array of repositories is added to the getRepositories closure
    // then: the UI should be reloaded
    func testLoadRepositoriesContentWhenRepositoryObjectsAreReturned() {
        loginHandler.hasOauthTokenVar = true
        repositoryHandler.repositories = [Repository(name: "testRepo", language: "swift", stargazers_count: 5, watchers_count: 3, forks: 2)]
        testObject.loadRepositoriesContent()
        XCTAssertTrue(repositoriesUI.reloadDataCalled)
    }

    // given: load repositories content is called
    // when: an empty array is added to the getRepositories closure
    // then: the UI should be reloaded
    func testLoadRepositoriesContentWhenEmptyArrayIsReturned() {
        loginHandler.hasOauthTokenVar = true
        repositoryHandler.repositories = []

        testObject.loadRepositoriesContent()

        XCTAssertTrue(repositoriesUI.reloadDataCalled)
    }

    // given: load repositories content is called
    // when: no array is added to the getRepositories closure
    // then: oauthToken should be removed
    // and: user should be navigated back to the sign in page
    func testLoadRepositoriesContentWhenNoArrayIsReturned() {
        loginHandler.hasOauthTokenVar = true
        repositoryHandler.repositories = nil

        testObject.loadRepositoriesContent()

        XCTAssertTrue(loginHandler.clearUserDetailsCalled)
        XCTAssertTrue(repositoriesUI.navigateToSignInScreenCalled)
    }

    // given: one repository exists
    // when: asked for number of repositories
    // then: 1 is returned
    func testNumberOfRepositories() {
        loginHandler.hasOauthTokenVar = true
        repositoryHandler.repositories = [Repository(name: "testRepo", language: "swift", stargazers_count: 5, watchers_count: 3, forks: 2)]
        testObject.loadRepositoriesContent()

        XCTAssertEqual(testObject.numberOfRepositories(), 1)
    }

    // given: no repositories exists
    // when: asked for number of repositories
    // then: 0 is returned
    func testNumberOfRepositoriesWhenNoneExists() {
        loginHandler.hasOauthTokenVar = true
        testObject.loadRepositoriesContent()
        XCTAssertEqual(testObject.numberOfRepositories(), 0)
    }

    // given: multiple repositories exists
    // when: format cell is called for a specific indexpath
    // then: the closure is called with the repository matching the indexpath
    func testFormatCell() {
        loginHandler.hasOauthTokenVar = true
        let exp = expectation(description: "closure called")
        let repo1 = Repository(name: "testRepo", language: "Swift", stargazers_count: 0, watchers_count: 0, forks: 0)
        let repo2 = Repository(name: "testRepo2", language: "Swift", stargazers_count: 0, watchers_count: 0, forks: 0)
        repositoryHandler.repositories = [repo1, repo2]
        testObject.loadRepositoriesContent()

        testObject.formatCell(at: 1) { repo in
            XCTAssertEqual(repo.name, "testRepo2")
            exp.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if error != nil { XCTFail() }
        }
    }
}

