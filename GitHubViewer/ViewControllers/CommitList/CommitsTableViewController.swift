//
//  CommitsTableViewController.swift
//  GitHubViewer
//
//  Created by Linda on 2018-03-10.
//  Copyright © 2018 LindaCCNordstrom. All rights reserved.
//

import UIKit

protocol CommitsUI {
    func reloadData()
    func navigateToSignInScreen()
}

class CommitsTableViewController: UITableViewController, CommitsUI {

    private var presenter: CommitsListPresenter?

    var repositoryName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = CommitsListPresenter(ui: self)
        presenter?.loadCommitsContent(for: repositoryName)
        title = repositoryName
    }

    func reloadData() {
        tableView.reloadData()
    }

    func navigateToSignInScreen() {
        navigationController?.popToRootViewController(animated: true)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.numberOfCommits() ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CommitsTableViewCell

        presenter?.formatCell(at: indexPath.item) { commit in
            cell?.messageLabel.text = commit.commit?.message
            cell?.dateLabel.text = commit.commit?.author?.date
        }

        return cell ?? UITableViewCell()
    }
}
