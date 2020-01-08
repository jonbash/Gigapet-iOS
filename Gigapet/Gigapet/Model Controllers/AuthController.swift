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

    func fetchCurrentUserInfo() throws -> UserInfo? {
        guard
            let userIDString = keychain[.currentUserIDKey],
            let userID = Int(userIDString),
            let userData = try keychain.getData(.userInfoKey(for: userID))
            else { return nil }

        return try JSONDecoder().decode(UserInfo.self, from: userData)
    }

    func putUserInfoInKeychain(_ userInfo: UserInfo) throws {
        let userData = try JSONEncoder().encode(userInfo)
        keychain[data: .userInfoKey(for: userInfo.id)] = userData
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
        networkHandler.transferMahDatas(with: request
        ) { (result: Result<Data, NetworkError>) in
            do {
                let userData = try result.get()
                print("got data: \(userData)")
                let userInfo = try JSONDecoder().decode(UserInfo.self, from: userData)
                print("got user info: \(userInfo)")
                try self.putUserInfoInKeychain(userInfo)
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
