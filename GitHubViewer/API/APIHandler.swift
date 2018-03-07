//
//  APIHandler.swift
//  GitHubViewer
//
//  Created by Linda on 2018-03-07.
//  Copyright © 2018 LindaCCNordstrom. All rights reserved.
//

import UIKit
import Alamofire

class GithubAPIHandler: APIHandler {
    // Ideas from https://grokswift.com/alamofire-OAuth2/
    static let shared = GithubAPIHandler()

    private let clientId = GitHubHiddenConstants.clientId
    private let clientSecret = GitHubHiddenConstants.clientSecret

    func fetchJSON(url: URL, parameters: [String: Any]? = nil, headers: [String: String]? = nil, closure: @escaping ((Data?, Error? ) -> Void)) {
        Alamofire.request(url, method: .post, parameters: parameters, headers: headers).responseData { response in
            switch response.result {
            case .success(let value):
                closure(value, nil)
            case .failure(let error):
                closure(nil, error)
            }
        }
    }
}

protocol APIHandler {
    func fetchJSON(url: URL, parameters: [String: Any]?, headers: [String: String]?, closure: @escaping ((Data?, Error? ) -> Void))
}

