//
//  UserInfo.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-06.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation

struct UserInfo: Decodable {
    var id: Int
    let username: String
    let password: String
    var token: String

    enum TopLevelKey: CodingKey {
        case token
        case saved
    }

    enum UserKey: CodingKey {
        case id
        case username
        case password
    }

    init(from decoder: Decoder) throws {
        let topContainer = try decoder.container(keyedBy: TopLevelKey.self)
        let userContainer = try topContainer.nestedContainer(
            keyedBy: UserKey.self,
            forKey: .saved)

        self.token = try topContainer.decode(String.self, forKey: .token)
        self.id = try userContainer.decode(Int.self, forKey: .id)
        self.username = try userContainer.decode(String.self, forKey: .username)
        self.password = try userContainer.decode(String.self, forKey: .password)
    }
}
