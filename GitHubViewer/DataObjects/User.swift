//
//  User.swift
//  GitHubViewer
//
//  Created by Linda on 2018-03-07.
//  Copyright © 2018 LindaCCNordstrom. All rights reserved.
//

import Foundation


// Note:
// The user object needs to conform to NSObject and NSCoding to be able
// to be stored in UserDefaults
class User: NSObject, Codable, NSCoding {
    var login: String?
    var name: String?
    var avatar_url: String?
    var location: String?
    var company: String?

    init(login: String?, name: String?, avatar_url: String?, location: String?, company: String?) {
        self.login = login
        self.name = name
        self.avatar_url = avatar_url
        self.location = location
        self.company = company
    }

    required init?(coder aDecoder: NSCoder) {
        login = aDecoder.decodeObject(forKey: "login") as? String
        name = aDecoder.decodeObject(forKey: "name") as? String
        avatar_url = aDecoder.decodeObject(forKey: "avatar_url") as? String
        location = aDecoder.decodeObject(forKey: "location") as? String
        company = aDecoder.decodeObject(forKey: "company") as? String
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(login, forKey: "login")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(avatar_url, forKey: "avatar_url")
        aCoder.encode(location, forKey: "location")
        aCoder.encode(company, forKey: "company")
    }
}

