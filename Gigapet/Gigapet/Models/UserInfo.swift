//
//  UserInfo.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-06.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation

struct UserInfo {
    var id: Int
    var token: String

    init(id: Int, token: String) {
        self.id = id
        self.token = token
    }
}

extension UserInfo: Decodable {

    // MARK: Decodable

    enum TopLevelKey: CodingKey {
        case token
        case saved
    }

    enum UserKey: CodingKey {
        case id
    }

    init(from decoder: Decoder) throws {
        let topContainer = try decoder.container(keyedBy: TopLevelKey.self)
        let userContainer = try topContainer.nestedContainer(
            keyedBy: UserKey.self,
            forKey: .saved)

        self.token = try topContainer.decode(String.self, forKey: .token)
        self.id = try userContainer.decode(Int.self, forKey: .id)
    }
}
