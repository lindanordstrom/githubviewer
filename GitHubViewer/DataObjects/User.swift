//
//  User.swift
//  GitHubViewer
//
//  Created by Linda on 2018-03-07.
//  Copyright © 2018 LindaCCNordstrom. All rights reserved.
//

import Foundation

struct User: Codable {
    var name: String?
    var avatar_url: String?
    var location: String?
    var company: String?
}
