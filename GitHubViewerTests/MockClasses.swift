//
//  MockClasses.swift
//  GitHubViewerTests
//
//  Created by Linda on 2018-03-08.
//  Copyright © 2018 LindaCCNordstrom. All rights reserved.
//

import Foundation
@testable import GitHubViewer

class TestUserDefaults: DataStore {
    var setValueForKeyCalled = false
    var stringForKeyCalled = false
    var key: String?
    var value: String?

    func set(_ value: Any?, forKey defaultName: String) {
        self.key = defaultName
        self.value = value as? String
        setValueForKeyCalled = true
    }

    func string(forKey: String) -> String? {
        stringForKeyCalled = true
        key = forKey
        return value
    }
}

class TestApiHandler: APIHandler {
    var url: URL?
    var parameters: [String: Any]?
    var headers: [String: String]?
    var networkRequestWasCalled = false
    var data: Data?
    var error: Error?


    func networkRequest(url: URL, method: RequestMethod, parameters: [String: Any]?, headers: [String: String]?, closure: @escaping ((Data?, Error? ) -> Void)) {
        self.url = url
        self.parameters = parameters
        self.headers = headers
        if data != nil {
            closure(data, nil)
        } else if error != nil {
            closure(nil, error)
        }
        networkRequestWasCalled = true
    }
}

class TestApplication: Application {
    var url: URL?
    var openUrlCalled = false

    func open(_ url: URL, options: [String : Any], completionHandler completion: ((Bool) -> Void)?) {
        self.url = url
        openUrlCalled = true
    }
}
