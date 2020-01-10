//
//  FoodEntryController.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-06.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation
import NetworkHandler

class FoodEntryController {

    // MARK: - Properties

    typealias ResultHandler = (NetworkError?) -> Void

    private(set) var entries: [FoodEntry] {
        get {
            localStoreController.entries
        } set {
            localStoreController.entries = newValue
        }
    }
    private(set) var user: UserInfo

    private(set) var localStoreController = LocalStoreController()
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

    init(user: UserInfo, loader: NetworkLoader? = nil) {
        self.user = user
        self._explicitLoader = loader

        self.networkHandler = NetworkHandler()
        networkHandler.strict200CodeResponse = false

        fetchAll { result in
            if let error = result {
                NSLog("Error fetching food entries in FoodEntryController initialization: \(error)")
            }
        }
    }

    // MARK: CRUD

    func addEntry(
        category: FoodCategory,
        foodName: String,
        foodAmount: Int,
        timestamp: Date = Date(),
        completion: @escaping ResultHandler
    ) {
        uploadNewEntry(
            FoodEntryRepresentation(
                foodCategory: category,
                foodName: foodName,
                foodAmount: foodAmount,
                dateFed: timestamp,
                identifier: nil),
            completion: completion)
    }

    func fetchAll(
        completion: @escaping ResultHandler
    ) {
        let request = APIRequestType.fetchAll(user: user).request

        handleRequestWithFetchedEntries(request, completion: completion)
    }

    func updateFoodEntry(
        _ entry: FoodEntry,
        withCategory category: FoodCategory,
        foodName: String,
        foodAmount: Int,
        timestamp: Date,
        completion: @escaping ResultHandler
    ) {
        do {
            try localStoreController.updateLocalEntry(
                entry,
                withCategory: category,
                name: foodName,
                dateFed: timestamp,
                foodAmount: foodAmount)
        } catch {
            completion(.otherError(error: error))
            return
        }

        guard let entryRep = entry.representation else {
            completion(.dataCodingError(specifically: GigapetError(
                text: "Entry rep does not exist for entry")))
            return
        }

        // if nil ID, then we haven't gotten the ID from the server
        if entry.identifier == FoodEntry.nilID {
            uploadNewEntry(entryRep, completion: completion)
            return
        }

        // encode data
        var entryData: Data?
        do { entryData = try JSONEncoder().encode(entryRep)
        } catch {
            completion(.dataCodingError(specifically: error))
            return
        }

        // build request
        var request = APIRequestType
            .update(user: user, feedingID: Int(entry.identifier))
            .request
        request.httpBody = entryData

        handleRequestWithFetchedEntries(request, completion: completion)
    }

    func deleteFoodEntry(
        _ entry: FoodEntry,
        completion: @escaping ResultHandler
    ) {
        // need to grab this before deleting the entry locally
        let entryID = Int(entry.identifier)

        do { try localStoreController.deleteLocalEntry(entry) } catch {
            completion(.otherError(error: error))
            return
        }

        let request = APIRequestType
            .delete(user: user, feedingID: entryID)
            .request

        handleRequestWithFetchedEntries(request, completion: completion)
    }

    func deleteAllLocalEntries() {
        localStoreController.deleteAllLocalEntries()
    }

    // MARK: - Sync Helpers

    private func uploadNewEntry(
        _ entryRep: FoodEntryRepresentation,
        completion: @escaping ResultHandler
    ) {
        var entryData: Data?
        do {
            entryData = try JSONEncoder().encode(entryRep)
        } catch {
            completion(.dataCodingError(specifically: error))
            return
        }

        var request = APIRequestType.create(user: user).request
        request.httpBody = entryData

        handleRequestWithFetchedEntries(request, completion: completion)
    }

    private func handleRequestWithFetchedEntries(
        _ request: URLRequest,
        completion: @escaping ResultHandler
    ) {
        networkHandler.transferMahCodableDatas(
            with: request,
            session: loader
        ) { (result: Result<[FoodEntryRepresentation], NetworkError>) in
            var serverEntryReps = [FoodEntryRepresentation]()

            do {
                serverEntryReps = try result.get()
            } catch let error as NetworkError {
                completion(error)
                return
            } catch {
                completion(.otherError(error: error))
            }

            do {
                try self.localStoreController.updateLocalEntries(from: serverEntryReps)
                try self.localStoreController.refreshLocalEntries()
            } catch {
                completion(.otherError(error: error))
                return
            }

            completion(nil)
        }
    }
}
