//
//  SignInPageViewController.swift
//  GitHubViewer
//
//  Created by Linda on 2018-03-09.
//  Copyright © 2018 LindaCCNordstrom. All rights reserved.
//

import UIKit

protocol SignInPageUI {
    func navigateToProfilePage()
}

class SignInPageViewController: UIViewController, SignInPageUI {

    private var presenter: SignInPagePresenter?

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = SignInPagePresenter(ui: self)
        presenter?.navigateToProfilePageIfUserIsSignedIn()
    }

    func navigateToProfilePage() {
        guard let profilePageViewController = storyboard?.instantiateViewController(withIdentifier: "profilePageViewController") as? ProfilePageViewController else { return }

        navigationController?.pushViewController(profilePageViewController, animated: true)
    }

    @IBAction func SignInButtonPressed(_ sender: Any) {
        presenter?.launchLoginWebFlow()
    }
}
