//
//  Application.swift
//  GitHubViewer
//
//  Created by Linda on 2018-03-07.
//  Copyright © 2018 LindaCCNordstrom. All rights reserved.
//

import UIKit

protocol Application {
    func open(_ url: URL, options: [String : Any], completionHandler completion: ((Bool) -> Swift.Void)?)
}

extension UIApplication: Application {}
