//
//  FoodController.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-06.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation
import NetworkHandler

class FoodController {

    // MARK: - Properties

    private(set) var user: UserInfo?
    private(set) var foodEntries: [FoodEntry] = []

    private let networkHandler = NetworkHandler()

    private let baseURL = URL(string: "https://gigapetbw4.herokuapp.com/api/")!

    // MARK: - Init

    init() {}

    // MARK: Authentication

    // TODO: Make result success type whatever actual received data is
    func register(
        withUsername username: String,
        password: String,
        completion: @escaping ((Error?) -> Void)
    ) {
        let request = URLRequest(url: baseURL.url(for: .register))
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
        let request = URLRequest(url: baseURL.url(for: .login))
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

    // MARK: CRUD

    func addEntry(
        category: FoodCategory,
        timestamp: Date = Date(),
        uuid: UUID = UUID(),
        completion: @escaping ((NetworkError?) -> Void)
    ) {
        let entry = FoodEntry(
            category: category,
            timestamp: timestamp,
            uuid: uuid)
        do {
            let entryData = try JSONEncoder().encode(entry)
        } catch {
            completion(.dataCodingError(specifically: error))
        }

        let request = URLRequest(url: baseURL.url(for: .create))

        request.httpBody
        // TODO: complete request for adding entry

        networkHandler.transferMahOptionalDatas(with: request) { result in
            do {
                _ = try result.get()
                completion(nil)
            } catch let error as NetworkError {
                completion(error)
            } catch {
                completion(.otherError(error: error))
            }
        }
    }

    func fetchAll(
        completion: @escaping (Result<[FoodEntry], NetworkError>) -> Void
    ) {

    }

    // MARK: - Private Methods

    
}
