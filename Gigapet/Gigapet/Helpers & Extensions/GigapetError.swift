//
//  GigapetError.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-08.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation

struct GigapetError: Error {
    var text: String

    // temporarily for compatibility
    func other(_ text: String) -> GigapetError {
        return GigapetError(text: text)
    }
}
