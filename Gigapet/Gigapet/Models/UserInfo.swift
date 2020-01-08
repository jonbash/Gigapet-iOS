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
    var petname: String

    init(id: Int, token: String, petname: String) {
        self.id = id
        self.token = token
        self.petname = petname
    }
}

// MARK: Decodable

extension UserInfo: Decodable {
    enum TopLevelKey: CodingKey {
        case token
        case user
        case saved
    }

    enum UserKey: CodingKey {
        case id
        case username
        case password
        case petname
    }

    init(from decoder: Decoder) throws {
        let topContainer = try decoder.container(keyedBy: TopLevelKey.self)
        var userContainer: KeyedDecodingContainer<UserInfo.UserKey>

        do {
             userContainer = try topContainer.nestedContainer(
                keyedBy: UserKey.self,
                forKey: .user)
        } catch {
            userContainer = try topContainer.nestedContainer(
                keyedBy: UserKey.self,
                forKey: .saved)
        }

        self.token = try topContainer.decode(String.self, forKey: .token)
        self.id = try userContainer.decode(Int.self, forKey: .id)
        self.petname = try userContainer.decode(String.self, forKey: .petname)
    }
}

// MARK: Encodable

extension UserInfo: Encodable {
    func encode(to encoder: Encoder) throws {
        var topContainer = encoder.container(keyedBy: TopLevelKey.self)
        var userContainer = topContainer.nestedContainer(
            keyedBy: UserKey.self,
            forKey: .user)

        try topContainer.encode(token, forKey: .token)
        try userContainer.encode(id, forKey: .id)
        try userContainer.encode(petname, forKey: .petname)
    }
}
