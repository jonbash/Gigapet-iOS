//
//  UserAuth.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-08.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation

struct UserRegistration: Encodable {
    let username: String
    let petname: String
    let password: String
}

struct UserLogin: Encodable {
    let username: String
    let password: String
}
