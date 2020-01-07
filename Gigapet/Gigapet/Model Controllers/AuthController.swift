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

    // TODO: Make result success type whatever actual received data is
    func register(
        withUsername username: String,
        password: String,
        completion: @escaping (Result<UserInfo, NetworkError>) -> Void
    ) {
        var request = URL.base.request(for: .register)

        do {
            request.httpBody = try JSONEncoder().encode(UserAuth(
                username: username,
                password: password))
        } catch {
            completion(.failure(.otherError(error: error)))
            return
        }

        networkHandler.transferMahCodableDatas(with: request, completion: completion)
    }

    // TODO: Make result success type whatever actual received data is
    func logIn(
        withUsername username: String,
        password: String,
        completion: @escaping (Result<UserInfo, NetworkError>) -> Void
    ) {
        var request = URL.base.request(for: .login)

        do {
            request.httpBody = try JSONEncoder().encode(UserAuth(
                username: username,
                password: password))
        } catch {
            completion(.failure(.otherError(error: error)))
            return
        }

        networkHandler.transferMahCodableDatas(with: request, completion: completion)
    }

    // MARK: - UserAuth
    
    private struct UserAuth: Codable {
        let username: String
        let password: String
    }
}
