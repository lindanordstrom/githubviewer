//
//  APIHandler.swift
//  GitHubViewer
//
//  Created by Linda on 2018-03-07.
//  Copyright © 2018 LindaCCNordstrom. All rights reserved.
//

import UIKit
import Alamofire

typealias RequestMethod = HTTPMethod

protocol APIHandler {
    func networkRequest(url: URL, method: RequestMethod, parameters: [String: Any]?, headers: [String: String]?, closure: @escaping ((Data?, Error? ) -> Void))
}

// Note:
// The Accept header will always be set to application/vnd.github.v3+json
// unless explicitly specified in the headers parameter
class GithubAPIHandler: APIHandler {
    static let shared = GithubAPIHandler()

    func networkRequest(url: URL, method: RequestMethod, parameters: [String: Any]?, headers: [String: String]?, closure: @escaping ((Data?, Error? ) -> Void)) {
        var headers = headers ?? [:]
        headers["Accept"] = headers["Accept"] ?? "application/vnd.github.v3+json"

        Alamofire.request(url, method: method, parameters: parameters, headers: headers).responseData { response in
            switch response.result {
            case .success(let value):
                closure(value, nil)
            case .failure(let error):
                closure(nil, error)
            }
        }
    }
}

