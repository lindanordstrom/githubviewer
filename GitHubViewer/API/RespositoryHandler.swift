//
//  RespositoryHandler.swift
//  GitHubViewer
//
//  Created by Linda on 2018-03-07.
//  Copyright © 2018 LindaCCNordstrom. All rights reserved.
//

import Foundation

protocol RepositoryHandler {
    func getRepositories(closure: @escaping ([Repository]?)->())
    func getCommits(for repo: String, closure: @escaping ([Commit]?)->())
}

class GithubRepositoryHandler: RepositoryHandler {
    static let shared = GithubRepositoryHandler()

    private var githubApiHandler: APIHandler
    private var loginHandler: LoginHandler

    init(githubApiHandler: APIHandler = GithubAPIHandler.shared, loginHandler: LoginHandler = GithubLoginHandler.shared) {
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
            guard let data = data,
                error == nil,
                let repositories = try? JSONDecoder().decode([Repository].self, from: data) else {
                    print(error?.localizedDescription ?? "error fetching data") // TODO HANDLE ERROR
                    closure(nil)
                    return
            }

            let ownRepositories = self.filterOutOnlyOwnRepositories(repos: repositories)

            closure(ownRepositories)
        }
    }

    func getCommits(for repo: String, closure: @escaping ([Commit]?) -> ()) {
        guard let oauthToken = loginHandler.getOauthToken(),
            let username = loginHandler.getSignedInUser()?.login,
            let url = URL(string: "https://api.github.com/repos/\(username)/\(repo)/commits") else {
                closure(nil)
                return
        }

        let param = ["access_token": oauthToken]

        githubApiHandler.networkRequest(url: url, method: .get, parameters: param, headers: nil) { (data, error) in
            guard let data = data,
                error == nil,
                let commits = try? JSONDecoder().decode([Commit].self, from: data) else {
                    print(error?.localizedDescription ?? "error fetching data") // TODO HANDLE ERROR
                    closure(nil)
                    return
            }
            closure(commits)
        }

    }

    private func filterOutOnlyOwnRepositories(repos: [Repository]) -> [Repository] {
        let filteredRepos = repos.flatMap { repo -> Repository? in
            guard repo.owner?.login == loginHandler.getSignedInUser()?.login else { return nil }
            return repo
        }
        return filteredRepos
    }
}

