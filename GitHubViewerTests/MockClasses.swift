//
//  MockClasses.swift
//  GitHubViewerTests
//
//  Created by Linda on 2018-03-08.
//  Copyright © 2018 LindaCCNordstrom. All rights reserved.
//

import Foundation
import UIKit
@testable import GitHubViewer

// MARK API HANDLERS MOCK

class TestApiHandler: APIHandler {
    var url: URL?
    var parameters: [String: Any]?
    var headers: [String: String]?
    var networkRequestWasCalled = false
    var data: Data?
    var error: Error?


    func networkRequest(url: URL, method: RequestMethod, parameters: [String: Any]?, headers: [String: String]?, closure: @escaping ((Data?, Error? ) -> Void)) {
        self.url = url
        self.parameters = parameters
        self.headers = headers
        if data != nil {
            closure(data, nil)
        } else if error != nil {
            closure(nil, error)
        }
        networkRequestWasCalled = true
    }
}

class TestLoginHandler: LoginHandler {
    var oauthToken: String?
    var hasOauthTokenVar = false
    var navigateToLoginPageCalled = false
    var getUserDetailsCalled = false
    var clearUserDetailsCalled = true
    var getSignedInUserCalled = true
    var url: URL?
    var user: User?
    var closure: (()->Void)?

    func getOauthToken() -> String? {
        return oauthToken
    }
    func hasOauthToken() -> Bool {
        return hasOauthTokenVar
    }
    func clearUserDetails() {
        clearUserDetailsCalled = true
    }
    func getSignedInUser() -> User? {
        getSignedInUserCalled = true
        return user
    }
    func navigateToLoginPage(closure: @escaping () -> Void) {
        navigateToLoginPageCalled = true
        closure()
    }
    func getToken(url: URL) {
        self.url = url
    }
    func getUserDetails(closure: @escaping (User?)->()) {
        getUserDetailsCalled = true
        closure(user)
    }
}

class TestRepositoryHandler: RepositoryHandler {
    var getRepositoriesCalled = false
    var getCommitsCalled = false
    var repositories: [Repository]?
    var commits: [Commit]?

    func getRepositories(closure: @escaping ([Repository]?) -> ()) {
        getRepositoriesCalled = true
        closure(repositories)
    }

    func getCommits(for repo: String, closure: @escaping ([Commit]?) -> ()) {
        getCommitsCalled = true
        closure(commits)
    }
}

// MARK: UI MOCKS

class TestProfilePageUI: ProfilePageUI {
    var clearAllValuesCalled = false
    var name: String?
    var location: String?
    var company: String?
    var image: UIImage?
    var navigateToSignInScreenCalled = false

    func clearAllValues() {
        clearAllValuesCalled = true
    }
    func setNameLabel(text: String?) {
        name = text
    }
    func setLocationLabel(text: String?) {
        location = text
    }
    func setCompanyLabel(text: String?) {
        company = text
    }
    func setAvatarImage(image: UIImage?) {
        self.image = image
    }
    func navigateToSignInScreen() {
        navigateToSignInScreenCalled = true
    }
}

class TestSignInPageUI: SignInPageUI {
    var navigateToProfilePageCalled = false

    func navigateToProfilePage() {
        navigateToProfilePageCalled = true
    }
}

class TestRepositoriesUI: RepositoriesUI {
    var reloadDataCalled = false
    var navigateToSignInScreenCalled = false

    func reloadData() {
        reloadDataCalled = true
    }

    func navigateToSignInScreen() {
        navigateToSignInScreenCalled = true
    }
}

class TestCommitsUI: CommitsUI {
    var reloadDataCalled = false
    var navigateToSignInScreenCalled = false

    func reloadData() {
        reloadDataCalled = true
    }

    func navigateToSignInScreen() {
        navigateToSignInScreenCalled = true
    }
}

// MARK: USERDEFAULTS MOCK

class TestUserDefaults: DataStore {
    var setValueForKeyCalled = false
    var objectForKeyCalled = false
    var removeObjectForKeyCalled = false
    var keyValue: [String: Any?] = [:]

    func set(_ value: Any?, forKey defaultName: String) {
        setValueForKeyCalled = true
        keyValue[defaultName] = value
    }
    func removeObject(forKey defaultName: String) {
        removeObjectForKeyCalled = true
        keyValue[defaultName] = nil
    }

    func object(forKey defaultName: String) -> Any? {
        objectForKeyCalled = true
        return keyValue[defaultName] ?? nil
    }
}

// MARK: UIAPPLICATION MOCK

class TestApplication: Application {
    var url: URL?
    var openUrlCalled = false

    func open(_ url: URL, options: [String : Any], completionHandler completion: ((Bool) -> Void)?) {
        self.url = url
        openUrlCalled = true
    }
}

