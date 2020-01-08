//
//  APIRequestType.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-06.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation

enum APIRequestType {
    case register
    case login
    case create(userID: Int)
    case fetchAll(userID: Int)
    case update(userID: Int, feedingID: Int)
    case delete(userID: Int, feedingID: Int)

    func endpoint() -> String {
        switch self {
        case .register:
            return "register"
        case .login:
            return "login"
        case .create(let userID), .fetchAll(let userID):
            return "auth/\(userID)/pet"
        case .update(let userID, let feedingID), .delete(let userID, let feedingID):
            return "auth/\(userID)/pet/\(feedingID)"
        @unknown default:
            fatalError("Unaccounted-for API Request Type")
        }
    }
}
