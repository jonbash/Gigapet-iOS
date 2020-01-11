//
//  NetworkController.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-10.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation
import NetworkHandler

class NetworkController {

    // MARK: - Properties

    private(set) var user: UserInfo

    private var networkHandler: NetworkHandler

    private let _explicitLoader: NetworkLoader?
    private lazy var mockUILoader: NetworkLoader = {
        do {
            let data = try mockData()
            return NetworkMockingSession(
                mockData: data,
                mockError: nil)
        } catch { fatalError("Mock data is bad") }
    }()

    private var loader: NetworkLoader {
        if isUITesting {
            return mockUILoader
        } else if let explicitLoader = _explicitLoader {
            return explicitLoader
        } else {
            return URLSession.shared
        }
    }

    // MARK: - Init

    init(user: UserInfo, loader: NetworkLoader?) {
        self.user = user
        self._explicitLoader = loader

        self.networkHandler = NetworkHandler()
        networkHandler.strict200CodeResponse = false
    }

    // MARK: - Public CRUD

    func uploadNewEntry(
        _ entryRep: FoodEntryRepresentation,
        resultHandler: NetworkResultHandler
    ) {
        var entryData: Data?
        do {
            entryData = try JSONEncoder().encode(entryRep)
        } catch {
            return
        }

        var request = APIRequestType.create(user: user).request
        request.httpBody = entryData

        handleRequestWithFetchedEntries(request, resultHandler: resultHandler)
    }

    func fetchAll(
        resultHandler: NetworkResultHandler
    ) {
        let request = APIRequestType.fetchAll(user: user).request

        handleRequestWithFetchedEntries(request, resultHandler: resultHandler)
    }

    func updateEntry(
        from entryRep: FoodEntryRepresentation,
        resultHandler: NetworkResultHandler
    ) {
        // if nil ID, then we haven't gotten the ID from the server
        guard
            let entryID = entryRep.identifier,
            entryID != Int(FoodEntry.nilID) else {
                uploadNewEntry(entryRep, resultHandler: resultHandler)
                return
        }

        // encode data
        var entryData: Data?
        do { entryData = try JSONEncoder().encode(entryRep)
        } catch {
            resultHandler.handleResults(.failure(.dataCodingError(specifically: error)))
            return
        }

        // build request
        var request: URLRequest = APIRequestType
            .update(user: user, feedingID: Int(entryID))
            .request

        request.httpBody = entryData

        handleRequestWithFetchedEntries(request, resultHandler: resultHandler)
    }

    func deleteEntry(
        withID entryID: Int,
        resultHandler: NetworkResultHandler
    ) {
        let request = APIRequestType
            .delete(user: user, feedingID: entryID)
            .request

        handleRequestWithFetchedEntries(request, resultHandler: resultHandler)
    }

    // MARK: - Private

    private func handleRequestWithFetchedEntries(
        _ request: URLRequest,
        resultHandler: NetworkResultHandler
    ) {
        networkHandler.transferMahCodableDatas(
            with: request,
            session: loader
        ) { (result: Result<[FoodEntryRepresentation], NetworkError>) in
            var serverEntryReps = [FoodEntryRepresentation]()

            do {
                serverEntryReps = try result.get()
            } catch let error as NetworkError {
                resultHandler.handleResults(.failure(error))
                return
            } catch {
                resultHandler.handleResults(.failure(.otherError(error: error)))
                return
            }

            resultHandler.handleResults(.success(serverEntryReps))
        }
    }
}
