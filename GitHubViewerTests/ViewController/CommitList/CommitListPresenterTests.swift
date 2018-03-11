//
//  CommitListPresenterTests.swift
//  GitHubViewerTests
//
//  Created by Linda on 2018-03-10.
//  Copyright © 2018 LindaCCNordstrom. All rights reserved.
//

import XCTest
@testable import GitHubViewer

class CommitListPresenterTests: XCTestCase {

    var testObject: CommitsListPresenter!
    var loginHandler: TestLoginHandler!
    var repositoryHandler: TestRepositoryHandler!
    var commitsUI: TestCommitsUI!

    override func setUp() {
        super.setUp()
        loginHandler = TestLoginHandler()
        repositoryHandler = TestRepositoryHandler()
        commitsUI = TestCommitsUI()
        testObject = CommitsListPresenter(ui: commitsUI, loginHandler: loginHandler, repositoryHandler: repositoryHandler)
    }

    override func tearDown() {
        testObject = nil
        loginHandler = nil
        repositoryHandler = nil
        commitsUI = nil
        super.tearDown()
    }

    // given: oauth token exists
    // when: load commits content is called
    // then: call to fetch commits should be made
    func testLoadCommitsContentWhenTokenExists() {
        loginHandler.hasOauthTokenVar = true

        testObject.loadCommitsContent(for: "testrepo")

        XCTAssertTrue(repositoryHandler.getCommitsCalled)
    }

    // given: oauth token does not exists
    // when: load commits content is called
    // then: user should be navigated back to the sign in page
    func testLoadRepositoriesContentWhenNoTokenExists() {
        loginHandler.hasOauthTokenVar = false

        testObject.loadCommitsContent(for: "testrepo")

        XCTAssertTrue(commitsUI.navigateToSignInScreenCalled)
    }

    // given: load commits content is called
    // when: an array of commits is added to the getCommits closure
    // then: the UI should be reloaded
    func testLoadCommitsContentWhenRepositoryObjectsAreReturned() {
        loginHandler.hasOauthTokenVar = true
        repositoryHandler.commits = [Commit(commit: CommitDetails(message: "test", author: Author(date: "2018-03-02T20:56:48Z")))]

        testObject.loadCommitsContent(for: "testrepo")

        XCTAssertTrue(commitsUI.reloadDataCalled)
    }

    // given: load commits content is called
    // when: an empty array is added to the getCommits closure
    // then: the UI should be reloaded
    func testLoadCommitsContentWhenEmptyArrayIsReturned() {
        loginHandler.hasOauthTokenVar = true
        repositoryHandler.commits = []

        testObject.loadCommitsContent(for: "testrepo")

        XCTAssertTrue(commitsUI.reloadDataCalled)
    }

    // given: load commits content is called
    // when: no array is added to the getCommits closure
    // then: oauthToken should be removed
    // and: user should be navigated back to the sign in page
    func testLoadCommitsContentWhenNoArrayIsReturned() {
        loginHandler.hasOauthTokenVar = true
        repositoryHandler.commits = nil

        testObject.loadCommitsContent(for: "testrepo")

        XCTAssertTrue(loginHandler.clearUserDetailsCalled)
        XCTAssertTrue(commitsUI.navigateToSignInScreenCalled)
    }

    // given: one commit exists
    // when: asked for number of commits
    // then: 1 is returned
    func testNumberOfCommits() {
        loginHandler.hasOauthTokenVar = true
        repositoryHandler.commits = [Commit(commit: CommitDetails(message: "test", author: Author(date: "2018-03-02T20:56:48Z")))]

        testObject.loadCommitsContent(for: "testrepo")

        XCTAssertEqual(testObject.numberOfCommits(), 1)
    }

    // given: no commits exists
    // when: asked for number of commits
    // then: 0 is returned
    func testNumberOfCommitsWhenNoneExists() {
        loginHandler.hasOauthTokenVar = true
        testObject.loadCommitsContent(for: "testreoi")
        XCTAssertEqual(testObject.numberOfCommits(), 0)
    }

    // given: multiple commits exists
    // when: format cell is called for a specific indexpath
    // then: the closure is called with the commit matching the indexpath
    // and: the commits dateTimeString has been formatted accordingly
    func testFormatCell() {
        loginHandler.hasOauthTokenVar = true
        let exp = expectation(description: "closure called")
        let commit1 = Commit(commit: CommitDetails(message: "test", author: Author(date: "2018-03-02T20:56:48Z")))
        let commit2 = Commit(commit: CommitDetails(message: "test2", author: Author(date: "2018-03-03T20:56:48Z")))
        repositoryHandler.commits = [commit1, commit2]

        testObject.loadCommitsContent(for: "testrepo")

        testObject.formatCell(at: 1) { commit in
            XCTAssertEqual(commit.commit?.message, "test2")
            XCTAssertEqual(commit.commit?.author?.date, "Mar 03, 2018")
            exp.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if error != nil { XCTFail() }
        }
    }
}
