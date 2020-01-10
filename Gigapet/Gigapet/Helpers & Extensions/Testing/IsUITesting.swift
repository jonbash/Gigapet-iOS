//
//  IsUITesting.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-09.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation

var isUITesting: Bool {
    return CommandLine.arguments.contains("UITesting")
}
