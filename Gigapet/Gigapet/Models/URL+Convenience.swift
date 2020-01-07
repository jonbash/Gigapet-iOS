//
//  URL+Convenience.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-06.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation
import NetworkHandler

extension URL {
    static var base: URL = URL(string: "https://gigapetbw4.herokuapp.com/")!

    func requestUrl(for requestType: APIRequestType) -> URL {
        return self.appendingPathComponent(requestType.rawValue)
    }

    func request(for requestType: APIRequestType) -> URLRequest {
        var request = self.appendingPathComponent(requestType.rawValue).request

        switch requestType {
        case .register, .login, .create, .update:
            request.httpMethod = HTTPMethods.post.rawValue
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        case .fetchAll:
            request.httpMethod = HTTPMethods.get.rawValue
        case .delete:
            request.httpMethod = HTTPMethods.delete.rawValue
        }

        return request
    }
}
