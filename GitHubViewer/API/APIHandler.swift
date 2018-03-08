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
//            print("Request: \(String(describing: response.request))")   // original url request
//            print("Response: \(String(describing: response.response))") // http url response
//            print("Result: \(response.result)")                         // response serialization result
//
//            if let json = response.result.value {
//                print("JSON: \(json)") // serialized json response
//            }
//
//            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
//                print("Data: \(utf8Text)") // original server data as UTF8 string
//            }

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
    func networkRequest(url: URL, method: RequestMethod, parameters: [String: Any]?, headers: [String: String]?, closure: @escaping ((Data?, Error? ) -> Void))
}

