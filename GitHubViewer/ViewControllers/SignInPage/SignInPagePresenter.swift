//
//  SignInPagePresenter.swift
//  GitHubViewer
//
//  Created by Linda on 2018-03-09.
//  Copyright © 2018 LindaCCNordstrom. All rights reserved.
//

import Foundation
import UIKit

class SignInPagePresenter {
    private let ui: SignInPageUI
    private let loginHandler: LoginHandler

    init(ui: SignInPageUI, loginHandler: LoginHandler = GithubLoginHandler.shared) {
        self.ui = ui
        self.loginHandler = loginHandler
    }

    func navigateToProfilePageIfUserIsSignedIn() {
        if loginHandler.hasOauthToken() {
            ui.navigateToProfilePage()
        }
    }

    func launchLoginWebFlow() {
        loginHandler.navigateToLoginPage() {
            self.navigateToProfilePageIfUserIsSignedIn()
        }
    }
}

