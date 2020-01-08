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
    case create(user: UserInfo)
    case fetchAll(user: UserInfo)
    case update(user: UserInfo, feedingID: Int)
    case delete(user: UserInfo, feedingID: Int)

    var endpoint: String {
        switch self {
        case .register:
            return "register"
        case .login:
            return "login"
        case .create(let user), .fetchAll(let user):
            return "auth/\(user.id)/pet"
        case .update(let user, let feedingID), .delete(let user, let feedingID):
            return "auth/\(user.id)/pet/\(feedingID)"
        }
    }

    var needsJSON: Bool {
        switch self {
        case .register, .login, .create, .update: return true
        default: return false
        }
    }

    var token: String? {
        switch self {
        case .create(let user),
             .update(let user, _),
             .fetchAll(let user),
             .delete(let user, _):

            return user.token
        default:
            return nil
        }
    }

    var request: URLRequest {
        var request = URLRequest(url: URL.base.appendingPathComponent(self.endpoint))

        if self.needsJSON {
            request.addValue("application/json",
                             forHTTPHeaderField: "Content-Type")
        }
        if let token = self.token {
            request.addValue(token, forHTTPHeaderField: "authentication")
        }

        switch self {
        case .register, .login:
            request.httpMethod = HTTPMethods.post.rawValue
        case .create:
            request.httpMethod = HTTPMethods.post.rawValue
        case .update:
            request.httpMethod = HTTPMethods.put.rawValue
        case .fetchAll:
            request.httpMethod = HTTPMethods.get.rawValue
        case .delete:
            request.httpMethod = HTTPMethods.delete.rawValue
        }

        return request
    }
}
