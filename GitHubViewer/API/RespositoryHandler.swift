//
//  RespositoryHandler.swift
//  GitHubViewer
//
//  Created by Linda on 2018-03-07.
//  Copyright © 2018 LindaCCNordstrom. All rights reserved.
//

import Foundation

class RepositoryHandler {
    static let shared = RepositoryHandler()

    var githubApiHandler: APIHandler
    var loginHandler: LoginHandler

    init(githubApiHandler: APIHandler = GithubAPIHandler.shared, loginHandler: LoginHandler = LoginHandler.shared) {
        self.githubApiHandler = githubApiHandler
        self.loginHandler = loginHandler
    }

    func getRepositories(closure: @escaping ([Repository]?)->()) {
        guard let oauthToken = loginHandler.getOauthToken(),
            let url = URL(string: "https://api.github.com/user/repos") else {
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
                let repositories = try JSONDecoder().decode([Repository].self, from: data)
                closure(repositories)
            } catch {
                closure(nil)
            }
        }
    }
}

