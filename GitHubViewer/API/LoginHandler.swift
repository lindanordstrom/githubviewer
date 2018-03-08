//
//  LoginHandler.swift
//  GitHubViewer
//
//  Created by Linda on 2018-03-07.
//  Copyright © 2018 LindaCCNordstrom. All rights reserved.
//

import UIKit

class LoginHandler {
    static let shared = LoginHandler()

    private var dataStore: DataStore
    private var githubApiHandler: APIHandler
    private var application: Application

    init(dataStore: DataStore = UserDefaults.standard, githubApiHandler: APIHandler = GithubAPIHandler.shared, application: Application = UIApplication.shared) {
        self.dataStore = dataStore
        self.githubApiHandler = githubApiHandler
        self.application = application
    }

    func getOauthToken() -> String? {
        return dataStore.string(forKey: "OauthToken")
    }

    func hasOauthToken() -> Bool {
        return getOauthToken() != nil
    }

    func navigateToLoginPage() {
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

    func getToken(url: URL) {
        guard let recievedCode = getCodeFrom(url: url),
            let getTokenURL = URL(string: "https://github.com/login/oauth/access_token") else {
            return // TODO HANDLE ERROR
        }

        let params = ["code": recievedCode]

        githubApiHandler.networkRequest(url: getTokenURL, method: .post, parameters: params, headers: nil) { (data, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "error fetching data") // TODO HANDLE ERROR
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let accessToken = json["access_token"] {
                        self.dataStore.set(accessToken, forKey: "OauthToken") // TODO KEYCHAIN
                        print(accessToken)
                }
            } catch {
                print(error.localizedDescription) // TODO HANDLE ERROR
            }
        }
    }

    func getUserDetails(closure: @escaping (User?)->()) {
        guard let oauthToken = getOauthToken(),
            let url = URL(string: "https://api.github.com/user") else {
                closure(nil)
                return
        }

        let param = ["access_token": oauthToken]

        githubApiHandler.networkRequest(url: url, method: .get, parameters: param, headers: nil) { (data, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "error fetching data") // TODO HANDLE ERROR
                closure(nil)
                return
            }

            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                closure(user)
            } catch {
                closure(nil)
            }
        }
    }
}

