//
//  ProfilePagePresenterTests.swift
//  GitHubViewerTests
//
//  Created by Linda on 2018-03-08.
//  Copyright © 2018 LindaCCNordstrom. All rights reserved.
//

import XCTest
@testable import GitHubViewer

class ProfilePagePresenterTests: XCTestCase {
    
    var testObject: ProfilePagePresenter!
    var loginHandler: TestLoginHandler!
    var profilePageUI: TestProfilePageUI!

    override func setUp() {
        super.setUp()
        loginHandler = TestLoginHandler()
        profilePageUI = TestProfilePageUI()
        testObject = ProfilePagePresenter(ui: profilePageUI, loginHandler: loginHandler)
    }

    override func tearDown() {
        testObject = nil
        loginHandler = nil
        profilePageUI = nil
        super.tearDown()
    }

    // when: load profile page content is called
    // then: all content should be cleared
    func testLoadProfilePageContent() {
        testObject.loadProfilePageContent()

        XCTAssertTrue(profilePageUI.clearAllValuesCalled)
    }

    // given: oauth token exists
    // when: load profile page content is called
    // then: call to fetch user details should be made
    func testLoadProfilePageContentWhenTokenExists() {
        loginHandler.hasOauthTokenVar = true

        testObject.loadProfilePageContent()

        XCTAssertTrue(loginHandler.getUserDetailsCalled)
    }

    // given: oauth token does not exists
    // when: load profile page content is called
    // then: user should be navigated to githubs login page
    func testLoadProfilePageContentWhenNoTokenExists() {
        loginHandler.hasOauthTokenVar = false

        testObject.loadProfilePageContent()

        XCTAssertTrue(loginHandler.navigateToLoginPageCalled)
    }

    // given: load profile page content is called
    // when: a valid user object is added to the getUserDetails closure
    // then: relevant UI parts should be updated
    func testLoadProfilePageContentWhenUserObjectIsReturned() {
        loginHandler.hasOauthTokenVar = true
        loginHandler.user = User(name: "linda", avatar_url: nil, location: "sweden", company: "blocket")
        testObject.loadProfilePageContent()
        XCTAssertEqual(profilePageUI.name, "linda")
        XCTAssertEqual(profilePageUI.location, "sweden")
        XCTAssertEqual(profilePageUI.company, "blocket")
        XCTAssertEqual(profilePageUI.image, nil)
    }
}
