//
//  LoginHandler.swift
//  GitHubViewer
//
//  Created by Linda on 2018-03-07.
//  Copyright © 2018 LindaCCNordstrom. All rights reserved.
//

import UIKit

protocol LoginHandler {
    func getOauthToken() -> String?
    func hasOauthToken() -> Bool
    func clearUserDetails()
    func getSignedInUser() -> User?
    func navigateToLoginPage(closure: @escaping ()->Void)
    func getToken(url: URL)
    func getUserDetails(closure: @escaping (User?)->())
}

class GithubLoginHandler: LoginHandler {
    static let shared = GithubLoginHandler()

    private var dataStore: DataStore
    private var githubApiHandler: APIHandler
    private var application: Application
    private var accessTokenRecievedClosure: (()->Void)?

    init(dataStore: DataStore = UserDefaults.standard, githubApiHandler: APIHandler = GithubAPIHandler.shared, application: Application = UIApplication.shared) {
        self.dataStore = dataStore
        self.githubApiHandler = githubApiHandler
        self.application = application
    }

    func getOauthToken() -> String? {
        return dataStore.object(forKey: Constants.UserDefaultsConstants.oauthToken) as? String
    }

    func hasOauthToken() -> Bool {
        return getOauthToken() != nil
    }

    func clearUserDetails() {
        dataStore.removeObject(forKey: Constants.UserDefaultsConstants.oauthToken)
        dataStore.removeObject(forKey: Constants.UserDefaultsConstants.signedInUser)
    }

    func getSignedInUser() -> User? {
        guard let userAsData = dataStore.object(forKey: Constants.UserDefaultsConstants.signedInUser) as? Data else { return nil }
        return NSKeyedUnarchiver.unarchiveObject(with: userAsData) as? User
    }

    // NOTE:
    // Opens the web browser and lets the user sign in via githubs web flow
    // when app is relaunched the appDelegate should receive an URL with a token
    // and call the loginhandlers getToken function
    func navigateToLoginPage(closure: @escaping ()->Void) {
        accessTokenRecievedClosure = closure
        let urlString = "https://github.com/login/oauth/authorize?client_id=\(GitHubHiddenConstants.clientId)&scope=repo%20user&state=TEST_STATE" // TODO STORE STRINGS
        guard let url = URL(string: urlString) else { return }
        application.open(url, options: [:], completionHandler: nil)
    }

    private func getCodeFrom(url: URL) -> String? {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let items = components?.queryItems else { return nil }
        for item in items {
            if item.name.lowercased() == "code" {
                return item.value
            }
        }
        return nil
    }

    // Note:
    // Will be called from AppDelegate when app is relaunched from githubs webflow
    // Fetches the access token based on the code received in the URL
    // Sets the access token in UserDefaults
    func getToken(url: URL) {
        guard let recievedCode = getCodeFrom(url: url),
            let getTokenURL = URL(string: "https://github.com/login/oauth/access_token") else {
                return // TODO HANDLE ERROR
        }

        let params = ["code": recievedCode, "client_id": GitHubHiddenConstants.clientId, "client_secret": GitHubHiddenConstants.clientSecret]
        let headers =  ["Accept": "application/json"]

        githubApiHandler.networkRequest(url: getTokenURL, method: .post, parameters: params, headers: headers) { (data, error) in
            guard let data = data,
                error == nil,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let accessToken = json?["access_token"] else {
                    print(error?.localizedDescription ?? "error fetching data") // TODO HANDLE ERROR
                    return
            }
            self.dataStore.set(accessToken, forKey: Constants.UserDefaultsConstants.oauthToken) // TODO KEYCHAIN
            self.accessTokenRecievedClosure?()
        }
    }

    // Note:
    // Fetches the user details from the user connected to the access token
    // Sets the signed in user in UserDefaults and the user is then sent through the closure
    func getUserDetails(closure: @escaping (User?)->()) {
        guard let oauthToken = getOauthToken(),
            let url = URL(string: "https://api.github.com/user") else {
                closure(nil)
                return
        }

        let param = ["access_token": oauthToken]

        githubApiHandler.networkRequest(url: url, method: .get, parameters: param, headers: nil) { (data, error) in
            guard let data = data,
                error == nil,
                let user = try? JSONDecoder().decode(User.self, from: data) else {
                    print(error?.localizedDescription ?? "error fetching data") // TODO HANDLE ERROR
                    closure(nil)
                    return
            }
            let userAsData = NSKeyedArchiver.archivedData(withRootObject: user)
            self.dataStore.set(userAsData, forKey: Constants.UserDefaultsConstants.signedInUser)
            closure(user)
        }
    }
}

