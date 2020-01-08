//
//  FoodEntryController.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-06.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import CoreData
import NetworkHandler

class FoodEntryController {

    // MARK: - Properties

    typealias ResultHandler = (Result<[FoodEntry], NetworkError>) -> Void

    private(set) var user: UserInfo
    private(set) var foodEntries: [FoodEntry] = []

    private var networkHandler: NetworkHandler = {
        let handler = NetworkHandler()
        handler.strict200CodeResponse = false
        return handler
    }()

    // MARK: - Init

    init(user: UserInfo) {
        self.user = user
        self.fetchAll { result in
            do {
                self.foodEntries = try result.get()
            } catch {
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
        let context = CoreDataStack.shared.container.newBackgroundContext()
        var newEntryRep: FoodEntryRepresentation?
        context.performAndWait {
            newEntryRep = FoodEntryRepresentation(
                foodCategory: category,
                foodName: foodName,
                foodAmount: foodAmount,
                dateFed: timestamp,
                identifier: nil)
        }
        guard let entryRep = newEntryRep else {
            completion(.failure(.dataCodingError(specifically: NSError())))
            return
        }

        uploadNewEntry(entryRep, context: context, completion: completion)
    }

    func fetchAll(
        completion: @escaping ResultHandler
    ) {
        let request = APIRequestType.fetchAll(user: user).request

        handleFetchedEntries(request: request, completion: completion)
    }

    func updateFoodEntry(
        _ entry: FoodEntry,
        withCategory category: FoodCategory?,
        foodName: String?,
        foodAmount: Int?,
        timestamp: Date?,
        completion: @escaping ResultHandler
    ) {
        let context = CoreDataStack.shared.container.newBackgroundContext()

        // update local entry
        context.performAndWait {
            if let category = category { entry.foodCategory = category.rawValue }
            if let foodName = foodName { entry.foodName = foodName }
            if let foodAmount = foodAmount { entry.foodAmount = Int64(foodAmount) }
            if let timestamp = timestamp { entry.dateFed = timestamp }
        }

        guard let entryRep = entry.representation else {
            completion(.failure(.dataCodingError(specifically: NSError())))
            return
        }

        // if nil ID, then we haven't gotten the ID from the server
        if entry.identifier == FoodEntry.nilID {
            uploadNewEntry(entryRep, context: context, completion: completion)
            return
        }

        // encode data
        var entryData: Data?
        do {
            entryData = try JSONEncoder().encode(entryRep)
        } catch {
            completion(.failure(.dataCodingError(specifically: error)))
        }

        // build request
        var request = APIRequestType
            .update(user: user, feedingID: Int(entry.identifier))
            .request
        request.httpBody = entryData

        handleFetchedEntries(request: request, completion: completion)
    }

    func deleteFoodEntry(
        _ entry: FoodEntry,
        completion: @escaping ResultHandler
    ) {
        let context = CoreDataStack.shared.container.newBackgroundContext()

        context.performAndWait {
            context.delete(entry)
        }

        let request = APIRequestType
            .delete(user: user, feedingID: Int(entry.identifier))
            .request

        handleFetchedEntries(request: request, completion: completion)
    }

    // MARK: - Private Methods

    private func uploadNewEntry(
        _ entryRep: FoodEntryRepresentation,
        context: NSManagedObjectContext,
        completion: @escaping (Result<[FoodEntry], NetworkError>) -> Void
    ) {
        var entryData: Data?
        do {
            entryData = try JSONEncoder().encode(entryRep)
        } catch {
            completion(.failure(.dataCodingError(specifically: error)))
            return
        }

        var request = APIRequestType.create(user: user).request
        request.httpBody = entryData

        handleFetchedEntries(request: request, completion: completion)
    }

    private func handleFetchedEntries(
        request: URLRequest,
        completion: @escaping (Result<[FoodEntry], NetworkError>) -> Void
    ) {
        networkHandler.transferMahCodableDatas(with: request) {
            [weak self] (result: Result<[FoodEntryRepresentation], NetworkError>) in

            var entries = [FoodEntry]()
            var entryReps = [FoodEntryRepresentation]()

            do {
                entryReps = try result.get()
            } catch {
                completion(.failure(.dataCodingError(specifically: error)))
                return
            }

            let context = CoreDataStack.shared.container.newBackgroundContext()

            var registeredEntries = self?.foodEntries


            context.performAndWait {
                for entryRep in entryReps {
                    if let matchingLocalEntry = self?.foodEntries.first(where: {
                        Int($0.identifier) == entryRep.identifier
                    }) {
                        matchingLocalEntry.update(from: entryRep, context: context)

                    } else {
                        let newEntry = FoodEntry(from: entryRep, context: context)
                        entries.append(newEntry)
                    }
                }
            }
            do {
                try CoreDataStack.shared.save(in: context)
            } catch {
                completion(.failure(.otherError(error: error)))
                return
            }

            self?.foodEntries = entries
            completion(.success(entries))
        }
    }
}
