//
//  DataStore.swift
//  GitHubViewer
//
//  Created by Linda on 2018-03-07.
//  Copyright © 2018 LindaCCNordstrom. All rights reserved.
//

import Foundation

protocol DataStore {
    func set(_ value: Any?, forKey defaultName: String)
    func string(forKey: String) -> String?
}

extension UserDefaults: DataStore {}
