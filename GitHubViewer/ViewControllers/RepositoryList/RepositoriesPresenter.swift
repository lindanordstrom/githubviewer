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
    private var repos: [Repository]?

    init(ui: RepositoriesUI) {
        self.ui = ui
    }

    func loadRepositoriesContent() {
        if GithubLoginHandler.shared.hasOauthToken() {
            RepositoryHandler.shared.getRepositories() { repos in
                guard let repos = repos else {
                    return // TODO HANDLE WHEN NO REPO IS RETURNED
                }
                self.repos = repos
                self.ui.reloadData()
            }
        } else {
            GithubLoginHandler.shared.navigateToLoginPage()
        }
    }

    func numberOfRepositories() -> Int {
        return repos?.count ?? 0
    }

    func formatCell(at index: Int, closure: (Repository)->Void) {
        guard let repos = repos else { return }
        closure(repos[index])
    }
}

