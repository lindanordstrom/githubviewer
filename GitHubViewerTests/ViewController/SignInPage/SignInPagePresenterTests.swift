//
//  SignInPagePresenterTests.swift
//  GitHubViewerTests
//
//  Created by Yaser on 2018-03-09.
//  Copyright © 2018 LindaCCNordstrom. All rights reserved.
//

import XCTest
@testable import GitHubViewer

class SignInPagePresenterTests: XCTestCase {

    var testObject: SignInPagePresenter!
    var loginHandler: TestLoginHandler!
    var signInPageUI: TestSignInPageUI!

    override func setUp() {
        super.setUp()
        loginHandler = TestLoginHandler()
        signInPageUI = TestSignInPageUI()
        testObject = SignInPagePresenter(ui: signInPageUI, loginHandler: loginHandler)
    }

    override func tearDown() {
        testObject = nil
        loginHandler = nil
        signInPageUI = nil
        super.tearDown()
    }

    // given: oauth token exists
    // when: navigateToProfilePageIfUserIsSignedIn is called
    // then: the UI should navigate to the profile page
    func testNavigateToProfilePageIfUserIsSignedInWhenTokenExists() {
        loginHandler.hasOauthTokenVar = true

        testObject.navigateToProfilePageIfUserIsSignedIn()

        XCTAssertTrue(signInPageUI.navigateToProfilePageCalled)
    }

    // given: oauth token does not exists
    // when: navigateToProfilePageIfUserIsSignedIn is called
    // then: the UI should not navigate to the profile page
    func testNavigateToProfilePageIfUserIsSignedInWhenNoTokenExists() {
        loginHandler.hasOauthTokenVar = false

        testObject.navigateToProfilePageIfUserIsSignedIn()

        XCTAssertFalse(signInPageUI.navigateToProfilePageCalled)
    }

    // when: launchLoginWebFlow is called
    // then: the loginHandler should start the web flow login
    // given: the oauthtoken gets set
    // when: the loginhandler closure is called
    // then: the UI should navigate to the profile page
    func testLaunchLoginWebFlow() {
        loginHandler.hasOauthTokenVar = true
        testObject.launchLoginWebFlow()
        XCTAssertTrue(loginHandler.navigateToLoginPageCalled)
        XCTAssertTrue(signInPageUI.navigateToProfilePageCalled)
    }

    // when: launchLoginWebFlow is called
    // then: the loginHandler should start the web flow login
    // given: the oauthtoken doesn't get set
    // when: the loginhandler closure is called
    // then: the UI should not navigate to the profile page
    func testLaunchLoginWebFlowWhenOauthTokenDoesntGetSet() {
        loginHandler.hasOauthTokenVar = false
        testObject.launchLoginWebFlow()
        XCTAssertTrue(loginHandler.navigateToLoginPageCalled)
        XCTAssertFalse(signInPageUI.navigateToProfilePageCalled)
    }
}

