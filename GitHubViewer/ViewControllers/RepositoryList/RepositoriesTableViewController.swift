//
//  RepositoriesTableViewController.swift
//  GitHubViewer
//
//  Created by Linda on 2018-03-08.
//  Copyright © 2018 LindaCCNordstrom. All rights reserved.
//

import UIKit

protocol RepositoriesUI {
    func reloadData()
    func navigateToSignInScreen()
}

class RepositoriesTableViewController: UITableViewController, RepositoriesUI {

    private var presenter: RepositoriesPresenter?

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = RepositoriesPresenter(ui: self)
        presenter?.loadRepositoriesContent()
    }

    func reloadData() {
        tableView.reloadData()
    }

    func navigateToSignInScreen() {
        navigationController?.popToRootViewController(animated: true)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.numberOfRepositories() ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? RepositoriesTableViewCell

        presenter?.formatCell(at: indexPath.item) { repository in
            cell?.titleLabel.text = repository.name
            cell?.languageLabel.text = repository.language
            cell?.starsLabel.text = String(describing: repository.stargazers_count ?? 0)
            cell?.watchersLabel.text = String(describing: repository.watchers_count ?? 0)
            cell?.forksLabel.text = String(describing: repository.forks ?? 1)
        }

        return cell ?? UITableViewCell()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selectedRow = tableView.indexPathForSelectedRow?.row,
            let nextVC = segue.destination as? CommitsTableViewController {
            nextVC.repositoryName = presenter?.getSelectedRepositoryName(index: selectedRow)
        }
    }
}

