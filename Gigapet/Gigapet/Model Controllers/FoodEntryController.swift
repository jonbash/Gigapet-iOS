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

    private(set) var entries: [FoodEntry] {
        get {
            localStoreController.entries
        } set {
            localStoreController.entries = newValue
        }
    }

    private(set) var localStoreController = LocalStoreController()
    private(set) var networkController: NetworkController

    // MARK: - Init

    init(user: UserInfo, loader: NetworkLoader? = nil) {
        self.networkController = NetworkController(user: user, loader: loader)

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
        completion: @escaping NetworkCompletion
    ) {
        networkController.uploadNewEntry(
            FoodEntryRepresentation(
                foodCategory: category,
                foodName: foodName,
                foodAmount: foodAmount,
                dateFed: timestamp,
                identifier: nil),
            resultHandler: NetworkResultHandler(
                handler: handleFetchedEntryReps(result:completion:),
                completion: completion))
    }

    func fetchAll(
        completion: @escaping NetworkCompletion
    ) {
        networkController.fetchAll(
            resultHandler: NetworkResultHandler(
                handler: handleFetchedEntryReps(result:completion:),
                completion: completion))
    }

    func updateFoodEntry(
        _ entry: FoodEntry,
        withCategory category: FoodCategory,
        foodName: String,
        foodAmount: Int,
        timestamp: Date,
        completion: @escaping NetworkCompletion
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
            completion(.dataCodingError(
                specifically: GigapetError(
                    text: "Entry rep does not exist for entry")))
            return
        }

        networkController.updateEntry(
            from: entryRep,
            resultHandler: NetworkResultHandler(
                handler: handleFetchedEntryReps(result:completion:),
                completion: completion))
    }

    func deleteFoodEntry(
        _ entry: FoodEntry,
        completion: @escaping NetworkCompletion
    ) {
        // need to grab this before deleting the entry locally
        let entryID = Int(entry.identifier)

        do { try localStoreController.deleteLocalEntry(entry) } catch {
            completion(.otherError(error: error))
            return
        }

        networkController.deleteEntry(
            withID: entryID,
            resultHandler: NetworkResultHandler(
                handler: handleFetchedEntryReps(result:completion:),
                completion: completion))
    }

    func deleteAllLocalEntries() {
        localStoreController.deleteAllLocalEntries()
    }

    // MARK: - Private

    private func handleFetchedEntryReps(
        result: Result<[FoodEntryRepresentation], NetworkError>,
        completion: NetworkCompletion
    ) {
        do {
            let serverEntryReps = try result.get()
            try self.localStoreController.updateLocalEntries(from: serverEntryReps)
            try self.localStoreController.refreshLocalEntries()
        } catch {
            completion(.otherError(error: error))
            return
        }

        completion(nil)
    }
}
