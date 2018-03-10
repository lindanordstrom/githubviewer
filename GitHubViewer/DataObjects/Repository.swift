//
//  Repository.swift
//  GitHubViewer
//
//  Created by Linda on 2018-03-07.
//  Copyright © 2018 LindaCCNordstrom. All rights reserved.
//

import Foundation

struct Repository: Codable {
    var name: String?
    var language: String?
    var stargazers_count: Int?
    var watchers_count: Int?
    var forks: Int?
    var owner: Owner?
}

struct Owner: Codable {
    var login: String?
}
