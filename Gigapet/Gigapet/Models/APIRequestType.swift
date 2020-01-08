//
//  APIRequestType.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-06.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation
import NetworkHandler

enum APIRequestType {
    case register
    case login
    case create(userID: Int)
    case fetchAll(userID: Int)
    case update(userID: Int, feedingID: Int)
    case delete(userID: Int, feedingID: Int)

    var endpoint: String {
        switch self {
        case .register:
            return "register"
        case .login:
            return "login"
        case .create(let userID), .fetchAll(let userID):
            return "auth/\(userID)/pet"
        case .update(let userID, let feedingID), .delete(let userID, let feedingID):
            return "auth/\(userID)/pet/\(feedingID)"
        }
    }

    var request: URLRequest {
        var request = URLRequest(url: URL.base.appendingPathComponent(self.endpoint))

        switch self {
        case .register, .login, .create:
            request.httpMethod = HTTPMethods.post.rawValue
            request.addValue("application/json",
                             forHTTPHeaderField: "Content-Type")
        case .update(_, _):
            request.httpMethod = HTTPMethods.put.rawValue
            request.addValue("application/json",
                             forHTTPHeaderField: "Content-Type")
        case .fetchAll:
            request.httpMethod = HTTPMethods.get.rawValue
        case .delete:
            request.httpMethod = HTTPMethods.delete.rawValue
        }

        return request
    }
}
