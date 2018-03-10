//
//  ProfilePagePresenter.swift
//  GitHubViewer
//
//  Created by Linda on 2018-03-08.
//  Copyright © 2018 LindaCCNordstrom. All rights reserved.
//

import Foundation
import UIKit

class ProfilePagePresenter {

    private let ui: ProfilePageUI
    private let loginHandler: LoginHandler

    init(ui: ProfilePageUI, loginHandler: LoginHandler = GithubLoginHandler.shared) {
        self.ui = ui
        self.loginHandler = loginHandler
    }

    func loadProfilePageContent() {
        ui.clearAllValues()
        if loginHandler.hasOauthToken() {
            loginHandler.getUserDetails() { user in
                guard let user = user else {
                    // TODO ADD SOME ERROR MESSAGE
                    self.signUserOut()
                    return
                }
                self.ui.setNameLabel(text: user.name)
                self.ui.setLocationLabel(text: user.location)
                self.ui.setCompanyLabel(text: user.company)
                self.ui.setAvatarImage(image: self.getImageFrom(urlString: user.avatar_url))
            }
        } else {
            signUserOut()
        }
    }

    func signUserOut() {
        loginHandler.clearUserDetails()
        ui.navigateToSignInScreen()
    }

    private func getImageFrom(urlString: String?) -> UIImage? {
        guard let urlString = urlString,
            let url = URL(string: urlString),
            let data = try? Data(contentsOf: url) else { return nil }

        return UIImage(data: data)
    }
}

