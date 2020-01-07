//
//  AuthController.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-06.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation
import NetworkHandler
import KeychainAccess

class AuthController {

    // MARK: - Properties

    typealias CompletionHandler = (Result<UserInfo, Error>) -> Void

    private let networkHandler = NetworkHandler()

    private let keychain = Keychain(service: .keychainKey)

    // MARK: - Keychain Access

    func fetchCurrentUserInfo() -> UserInfo? {
        guard
            let userIDString = keychain[.currentUserIDKey],
            let userID = Int(userIDString),
            let token = keychain[.tokenKey(forUserID: userIDString)]
            else { return nil }

        return UserInfo(id: userID, token: token)
    }

    func putUserInfoInKeychain(_ userInfo: UserInfo, for userID: String) {
        let userIDString = String(userInfo.id)
        keychain[.currentUserIDKey] = userIDString
        keychain[.tokenKey(forUserID: userIDString)] = userInfo.token
    }

    // MARK: - Authentication

    func register(
        withUsername username: String,
        petName: String,
        password: String,
        completion: @escaping CompletionHandler
    ) {
        var request = URL.base.request(for: .register)

        do {
            request.httpBody = try JSONEncoder().encode(UserRegistration(
                username: username,
                petname: petName,
                password: password))
        } catch {
            completion(.failure(NetworkError.otherError(error: error)))
            return
        }

        handleRequest(request, completion: completion)
    }

    func logIn(
        withUsername username: String,
        password: String,
        completion: @escaping CompletionHandler
    ) {
        var request = URL.base.request(for: .login)

        do {
            request.httpBody = try JSONEncoder().encode(UserLogin(
                username: username,
                password: password))
        } catch {
            completion(.failure(NetworkError.otherError(error: error)))
            return
        }

        handleRequest(request, completion: completion)
    }

    // MARK: - Private

    private func handleRequest(
        _ request: URLRequest,
        completion: @escaping CompletionHandler
    ) {
        networkHandler.transferMahCodableDatas(with: request
        ) { (result: Result<UserInfo, NetworkError>) in
            do {
                let userInfo = try result.get()
                completion(.success(userInfo))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - UserAuth

    private struct UserRegistration: Encodable {
        let username: String
        let petname: String
        let password: String
    }
    
    private struct UserLogin: Encodable {
        let username: String
        let password: String
    }
}
