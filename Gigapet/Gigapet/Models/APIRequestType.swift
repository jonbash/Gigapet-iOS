//
//  APIRequestType.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-06.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation

enum APIRequestType: String {
    case register = "auth/register"
    case login = "auth/login"
    case create
    case fetchAll
    case update
    case delete
}
