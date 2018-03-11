//
//  CommitsListPresenter.swift
//  GitHubViewer
//
//  Created by Linda on 2018-03-10.
//  Copyright © 2018 LindaCCNordstrom. All rights reserved.
//

import Foundation

class CommitsListPresenter {
    private let ui: CommitsUI
    private let loginHandler: LoginHandler
    private let repositoryHandler: RepositoryHandler
    private var commits: [Commit]?

    init(ui: CommitsUI, loginHandler: LoginHandler = GithubLoginHandler.shared, repositoryHandler: RepositoryHandler = GithubRepositoryHandler.shared) {
        self.ui = ui
        self.loginHandler = loginHandler
        self.repositoryHandler = repositoryHandler
    }

    func loadCommitsContent(for repo: String?) {
        if let repo = repo,
            loginHandler.hasOauthToken() {
            repositoryHandler.getCommits(for: repo) { commits in
                guard let commits = commits else {
                    // TODO ADD SOME ERROR MESSAGE
                    self.signUserOut()
                    return
                }
                self.commits = commits
                self.ui.reloadData()
            }
        } else {
            signUserOut()
        }
    }

    func numberOfCommits() -> Int {
        return commits?.count ?? 0
    }

    func formatCell(at index: Int, closure: (Commit)->Void) {
        guard let commits = commits else { return }
        var commit = commits[index]
        if let dateTimeString = commit.commit?.author?.date {
            commit.commit?.author?.date = format(dateTimeString: dateTimeString)
        }
        closure(commit)
    }

    private func signUserOut() {
        loginHandler.clearUserDetails()
        ui.navigateToSignInScreen()
    }

    private func format(dateTimeString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        guard let dateObj = dateFormatter.date(from: dateTimeString) else { return nil }
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.string(from: dateObj)
    }
}
