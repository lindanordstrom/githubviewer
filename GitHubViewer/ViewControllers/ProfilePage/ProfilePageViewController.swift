//
//  ProfilePageViewController.swift
//  GitHubViewer
//
//  Created by Linda on 2018-03-08.
//  Copyright © 2018 LindaCCNordstrom. All rights reserved.
//

import UIKit

protocol ProfilePageUI {
    func clearAllValues()
    func setNameLabel(text: String?)
    func setLocationLabel(text: String?)
    func setCompanyLabel(text: String?)
    func setAvatarImage(image: UIImage?)
}

class ProfilePageViewController: UIViewController, ProfilePageUI {

    private var presenter: ProfilePagePresenter?

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = ProfilePagePresenter(ui: self)
        presenter?.loadProfilePageContent()
    }

    func clearAllValues() {
        nameLabel.text = ""
        locationLabel.text = ""
        companyLabel.text = ""
        avatarImageView.image = #imageLiteral(resourceName: "githubImage")
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

    @IBAction func signOutButtonPressed(_ sender: Any) {

    }

    @IBAction func showRepositoriesButtonPressed(_ sender: Any) {

    }

}
