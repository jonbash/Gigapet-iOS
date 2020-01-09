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

    private lazy var networkHandler: NetworkHandler = {
        let handler = NetworkHandler()
        handler.strict200CodeResponse = false
        return handler
    }()

    private let keychain = Keychain(service: .keychainKey)

    // MARK: - Keychain Access

    func fetchCurrentUserInfo() throws -> UserInfo? {
        guard let userIDString = try keychain.getString(.currentUserIDKey),
            let userID = Int(userIDString),
            let userData = try keychain.getData(.userInfoKey(for: userID))
            else { return nil }

        return try JSONDecoder().decode(UserInfo.self, from: userData)
    }

    func putUserInfoInKeychain(_ userInfo: UserInfo) throws {
        let userData = try JSONEncoder().encode(userInfo)
        try keychain.set(String(userInfo.id), key: .currentUserIDKey)
        try keychain.set(userData, key: .userInfoKey(for: userInfo.id))
    }

    // MARK: - Authentication

    func register(
        withUsername username: String,
        petName: String,
        password: String,
        completion: @escaping CompletionHandler
    ) {
        var request = APIRequestType.register.request

        do {
            request.httpBody = try JSONEncoder().encode(UserRegistration(
                username: username,
                password: password,
                petname: petName))
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
        var request = APIRequestType.login.request

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
                try self.putUserInfoInKeychain(userInfo)
                completion(.success(userInfo))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
