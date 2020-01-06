//
//  URL+Convenience.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-06.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation

extension URL {
    static var baseURL: URL = URL(string: "https://gigapetbw4.herokuapp.com/api/")!

    func requestUrl(for requestType: APIRequestType) -> URL {
        return self.appendingPathComponent(requestType.rawValue)
    }
}
