//
//  ProfilePageViewController.swift
//  GitHubViewer
//
//  Created by Linda on 2018-03-08.
//  Copyright © 2018 LindaCCNordstrom. All rights reserved.
//

import UIKit

protocol ProfilePageUI {
    func toggleSpinner(on: Bool)
    func clearAllValues()
    func showButton()
    func setNameLabel(text: String?)
    func setLocationLabel(text: String?)
    func setCompanyLabel(text: String?)
    func setAvatarImage(image: UIImage?)
    func navigateToSignInScreen()
}

class ProfilePageViewController: UIViewController, ProfilePageUI {

    private var presenter: ProfilePagePresenter?
    private let spinner = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var showRepositoriesButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = ProfilePagePresenter(ui: self)
        presenter?.loadProfilePageContent()
        navigationItem.setHidesBackButton(true, animated: false)
    }

    func toggleSpinner(on: Bool) {
        if on {
            spinner.startAnimating()
            spinner.center = view.center
            view.addSubview(spinner)
        } else {
            spinner.stopAnimating()
            spinner.removeFromSuperview()
        }
    }

    func clearAllValues() {
        nameLabel.text = ""
        locationLabel.text = ""
        companyLabel.text = ""
        avatarImageView.image = nil
        showRepositoriesButton.isHidden = true
    }

    func showButton() {
        showRepositoriesButton.isHidden = false
    }

    func setNameLabel(text: String?) {
        nameLabel.text = text
    }

    func setLocationLabel(text: String?) {
        locationLabel.text = text
    }

    func setCompanyLabel(text: String?) {
        companyLabel.text = text
    }

    func setAvatarImage(image: UIImage?) {
        avatarImageView.image = image ?? #imageLiteral(resourceName: "githubImage")
    }

    func navigateToSignInScreen() {
        navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func signOutButtonPressed(_ sender: Any) {
        presenter?.signUserOut()
    }
}
