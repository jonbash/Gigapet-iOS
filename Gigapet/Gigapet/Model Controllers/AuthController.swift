//
//  AuthController.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-06.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation
import NetworkHandler

class AuthController {
    private let networkHandler = NetworkHandler()
    private(set) var user: UserInfo?

    // TODO: Make result success type whatever actual received data is
    func register(
        withUsername username: String,
        password: String,
        completion: @escaping ((Error?) -> Void)
    ) {
        let request = URL.baseURL.requestUrl(for: .register).request
        // TODO: add data for username/login/headers/etc

        networkHandler.transferMahCodableDatas(with: request)
        { (result: Result<UserInfo, NetworkError>) in
            do {
                self.user = try result.get()
                completion(nil)
            } catch let error as NetworkError {
                completion(error)
            } catch {
                completion(NetworkError.otherError(error: error))
            }
        }
    }

    // TODO: Make result success type whatever actual received data is
    func logIn(
        withUsername username: String,
        password: String,
        completion: @escaping ((NetworkError?) -> Void)
    ) {
        let request = URL.baseURL.requestUrl(for: .login).request
        // TODO: add data for username/login/headers/etc

        networkHandler.transferMahCodableDatas(with: request)
        { (result: Result<UserInfo, NetworkError>) in
            do {
                self.user = try result.get()
                completion(nil)
            } catch let error as NetworkError {
                completion(error)
            } catch {
                completion(.otherError(error: error))
            }
        }
    }
}
