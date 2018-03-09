//
//  RepositoriesPresenter.swift
//  GitHubViewer
//
//  Created by Linda on 2018-03-08.
//  Copyright © 2018 LindaCCNordstrom. All rights reserved.
//

import Foundation
import UIKit

class RepositoriesPresenter {

    private let ui: RepositoriesUI
    private let loginHandler: LoginHandler
    private let repositoryHandler: RepositoryHandler
    private var repos: [Repository]?

    init(ui: RepositoriesUI, loginHandler: LoginHandler = GithubLoginHandler.shared, repositoryHandler: RepositoryHandler = GithubRepositoryHandler.shared) {
        self.ui = ui
        self.loginHandler = loginHandler
        self.repositoryHandler = repositoryHandler
    }

    func loadRepositoriesContent() {
        if loginHandler.hasOauthToken() {
            repositoryHandler.getRepositories() { repos in
                guard let repos = repos else {
                    // TODO ADD SOME ERROR MESSAGE
                    self.signUserOut()
                    return
                }
                self.repos = repos
                self.ui.reloadData()
            }
        } else {
            signUserOut()
        }
    }

    func numberOfRepositories() -> Int {
        return repos?.count ?? 0
    }

    func formatCell(at index: Int, closure: (Repository)->Void) {
        guard let repos = repos else { return }
        closure(repos[index])
    }

    private func signUserOut() {
        loginHandler.clearOauthToken()
        ui.navigateToSignInScreen()
    }
}

