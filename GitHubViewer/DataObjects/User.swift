//
//  User.swift
//  GitHubViewer
//
//  Created by Linda on 2018-03-07.
//  Copyright © 2018 LindaCCNordstrom. All rights reserved.
//

import Foundation

class User: NSObject, Codable, NSCoding {
    var login: String?
    var name: String?
    var avatar_url: String?
    var location: String?
    var company: String?

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

