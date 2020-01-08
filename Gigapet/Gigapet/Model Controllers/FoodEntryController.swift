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
        completion: @escaping (NetworkError?) -> Void
    ) {
        let context = CoreDataStack.shared.container.newBackgroundContext()
        var newEntry: FoodEntry?
        context.performAndWait {
            newEntry = FoodEntry(
                category: category,
                foodName: foodName,
                foodAmount: foodAmount,
                dateFed: timestamp,
                identifier: nil,
                context: context)
        }
        guard let entry = newEntry else {
            completion(.none)
            return
        }

        uploadNewEntry(entry, context: context, completion: completion)
    }

    func fetchAll(
        completion: @escaping (Result<[FoodEntry], NetworkError>) -> Void
    ) {
        let request = APIRequestType.fetchAll(user: user).request

        networkHandler.transferMahCodableDatas(with: request
        ) { (result: Result<[FoodEntryRepresentation], NetworkError>) in
            var entries = [FoodEntry]()
            var entryReps = [FoodEntryRepresentation]()

            do {
                entryReps = try result.get()
            } catch {
                completion(.failure(.dataCodingError(specifically: error)))
                return
            }

            let context = CoreDataStack.shared.container.newBackgroundContext()
            context.performAndWait {
                for entryRep in entryReps {
                    entries.append(FoodEntry(from: entryRep, context: context))
                }
            }
            do {
                try CoreDataStack.shared.save(in: context)
            } catch {
                completion(.failure(.otherError(error: error)))
                return
            }

            self.foodEntries = entries
            completion(.success(entries))
        }
    }

    func updateFoodEntry(
        _ entry: FoodEntry,
        withCategory category: FoodCategory?,
        foodName: String?,
        foodAmount: Int?,
        timestamp: Date?,
        completion: @escaping (NetworkError?) -> Void
    ) {
        let context = CoreDataStack.shared.container.newBackgroundContext()

        // update local entry
        context.performAndWait {
            if let category = category { entry.foodCategory = category.rawValue }
            if let foodName = foodName { entry.foodName = foodName }
            if let foodAmount = foodAmount { entry.foodAmount = Int64(foodAmount) }
            if let timestamp = timestamp { entry.dateFed = timestamp }
        }

        // if nil ID, then we haven't gotten the ID from the server
        if entry.identifier == FoodEntry.nilID {
            uploadNewEntry(entry, context: context, completion: completion)
            return
        }

        // encode data
        var entryData: Data?
        do {
            entryData = try JSONEncoder().encode(entry.representation)
        } catch {
            completion(.dataCodingError(specifically: error))
        }

        // build request
        var request = APIRequestType
            .update(user: user, feedingID: Int(entry.identifier))
            .request
        request.httpBody = entryData

        // send request
        networkHandler.transferMahOptionalDatas(with: request) { result in
            do {
                _ = try result.get()
                try CoreDataStack.shared.save(in: context)
            } catch let error as NetworkError {
                completion(error)
            } catch {
                completion(.otherError(error: error))
            }
        }
    }

    func deleteFoodEntry(
        _ entry: FoodEntry,
        completion: @escaping (NetworkError?) -> Void
    ) {
        let context = CoreDataStack.shared.container.newBackgroundContext()

        context.performAndWait {
            context.delete(entry)
        }

        let request = APIRequestType
            .delete(user: user, feedingID: Int(entry.identifier))
            .request

        networkHandler.transferMahOptionalDatas(with: request) { result in
            do {
                _ = try result.get()
                try CoreDataStack.shared.save(in: context)
            } catch let error as NetworkError {
                completion(error)
            } catch {
                completion(.otherError(error: error))
            }
        }
    }

    // MARK: - Private Methods

    private func uploadNewEntry(
        _ entry: FoodEntry,
        context: NSManagedObjectContext,
        completion: @escaping ((NetworkError?) -> Void)
    ) {
        var entryData: Data?
        do {
            entryData = try JSONEncoder().encode(entry.representation)
        } catch {
            completion(.dataCodingError(specifically: error))
            return
        }

        var request = APIRequestType.create(user: user).request
        request.httpBody = entryData

        networkHandler.transferMahCodableDatas(with: request
        ) { (result: Result<FoodEntryRepresentation, NetworkError>) in
            do {
                let entryRep = try result.get()
                entry.identifier = Int64(entryRep.identifier ?? -1)
                try CoreDataStack.shared.save(in: context)
            } catch let error as NetworkError {
                completion(error)
            } catch {
                completion(.otherError(error: error))
            }
        }
    }
}
