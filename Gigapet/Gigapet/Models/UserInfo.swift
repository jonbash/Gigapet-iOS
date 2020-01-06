//
//  UserInfo.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-06.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation

struct UserInfo: Codable {
    var uuid: UUID
    var username: String
    var petName: String
}
