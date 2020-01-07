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

    func endpoint(userID: Int? = nil, feedingID: Int? = nil) -> String? {
        switch self {
        case .register, .login:
            return self.rawValue
        case .create, .fetchAll:
            guard let userID = userID else { return nil }
            return "\(userID)/pet"
        case .update, .delete:
            guard
                let userID = userID,
                let feedingID = feedingID
                else { return nil }
            return "\(userID)/pet/\(feedingID)"
        @unknown default:
            fatalError("Unaccounted-for API Request Type")
        }
    }
}
