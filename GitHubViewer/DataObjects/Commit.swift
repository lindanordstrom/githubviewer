//
//  Commits.swift
//  GitHubViewer
//
//  Created by Linda on 2018-03-10.
//  Copyright © 2018 LindaCCNordstrom. All rights reserved.
//

import Foundation

struct Commit: Codable {
    var commit: CommitDetails?
}

struct CommitDetails: Codable {
    var message: String?
    var author: Author?
}

struct Author: Codable {
    var date: String?
}
