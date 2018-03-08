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

class GithubAPIHandler: APIHandler {
    // Ideas from https://grokswift.com/alamofire-OAuth2/
    static let shared = GithubAPIHandler()

    private let clientId = GitHubHiddenConstants.clientId
    private let clientSecret = GitHubHiddenConstants.clientSecret

    func networkRequest(url: URL, method: RequestMethod, parameters: [String: Any]?, headers: [String: String]?, closure: @escaping ((Data?, Error? ) -> Void)) {
        var parameters = parameters ?? [:]
        var headers = headers ?? [:]
        parameters["client_id"] = GitHubHiddenConstants.clientId
        parameters["client_secret"] = GitHubHiddenConstants.clientSecret
        headers["Accept"] = "application/json"

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

