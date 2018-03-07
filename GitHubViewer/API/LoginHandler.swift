//
//  LoginHandler.swift
//  GitHubViewer
//
//  Created by Linda on 2018-03-07.
//  Copyright © 2018 LindaCCNordstrom. All rights reserved.
//

import UIKit

protocol Application {
    func open(_ url: URL, options: [String : Any], completionHandler completion: ((Bool) -> Swift.Void)?)
}

extension UIApplication: Application {}

class LoginHandler {
    static let shared = LoginHandler()

    var dataStore: DataStore
    var githubApiHandler: APIHandler
    var application: Application

    init(dataStore: DataStore = UserDefaults.standard, githubApiHandler: APIHandler = GithubAPIHandler.shared, application: Application = UIApplication.shared) {
        self.dataStore = dataStore
        self.githubApiHandler = githubApiHandler
        self.application = application
    }

    func hasOauthToken() -> Bool {
        return dataStore.string(forKey: "OauthToken") != nil
    }

    func navigateToLoginPage() {
        let urlString = "https://github.com/login/oauth/authorize?client_id=\(GitHubHiddenConstants.clientId)&scope=repo&state=TEST_STATE"
        guard let url = URL(string: urlString) else { return }
        application.open(url, options: [:], completionHandler: nil)
    }

    func getToken(url: URL) {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        var code: String?
        guard let items = components?.queryItems else { return } // TODO HANDLE ERROR
        for item in items {
            if item.name.lowercased() == "code" {
                code = item.value
                break
            }
        }

        guard let getTokenURL = URL(string: "https://github.com/login/oauth/access_token"),
            let recievedCode = code else { return } // TODO HANDLE ERROR

        let params = ["client_id": GitHubHiddenConstants.clientId, "client_secret": GitHubHiddenConstants.clientSecret, "code": recievedCode]

        let headers = ["Accept": "application/json"]

        githubApiHandler.fetchJSON(url: getTokenURL, parameters: params, headers: headers) { (data, error) in
            guard let data = data, error == nil else {
                print(error) // TODO HANDLE ERROR
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let accessToken = json["access_token"] {
                    self.dataStore.set(accessToken, forKey: "OauthToken") // TODO KEYCHAIN
                    print(accessToken)
                }
            } catch {
                print(error) // TODO HANDLE ERROR
            }
        }
    }
}

