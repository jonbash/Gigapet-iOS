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

    private let networkHandler = NetworkHandler()

    // MARK: - Init

    init(user: UserInfo) {
        self.user = user
    }

    // MARK: CRUD

    func addEntry(
        category: FoodCategory,
        foodName: String,
        foodAmount: Int,
        timestamp: Date = Date(),
        completion: @escaping ((NetworkError?) -> Void)
    ) {
        let context = CoreDataStack.shared.container.newBackgroundContext()
        var entry: FoodEntry?
        context.performAndWait {
            entry = FoodEntry(
                category: category,
                foodName: foodName,
                foodAmount: foodAmount,
                dateFed: timestamp,
                identifier: nil,
                context: context)
        }

        var entryData: Data?
        do {
            entryData = try JSONEncoder().encode(entry?.representation)
        } catch {
            completion(.dataCodingError(specifically: error))
        }

        var request = URL.base.request(for: .create(userID: user.id))
        request.httpBody = entryData
        // TODO: complete request for adding entry

        networkHandler.transferMahOptionalDatas(with: request) { result in
            self.handlePost(context: context, result: result, completion: completion)
            // TODO: set entry identifier
        }
    }

    func fetchAll(
        completion: @escaping (Result<[FoodEntry], NetworkError>) -> Void
    ) {
        let context = CoreDataStack.shared.container.newBackgroundContext()
        var request = URL.base.request(for: .fetchAll(userID: user.id))
        // TODO: complete rest of request

        networkHandler.transferMahCodableDatas(with: request
        ) { (result: Result<[FoodEntry.Representation], NetworkError>) in
            var entries = [FoodEntry]()
            var entryReps = [FoodEntry.Representation]()

            do {
                entryReps = try result.get()
            } catch {
                completion(.failure(.dataCodingError(specifically: error)))
                return
            }

            for entryRep in entryReps {
                entries.append(FoodEntry(from: entryRep, context: context))
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
        if entry.identifier == -1 {

        }
        let context = CoreDataStack.shared.container.newBackgroundContext()

        context.performAndWait {
            if let category = category { entry.foodCategory = category.rawValue }
            if let foodName = foodName { entry.foodName = foodName }
            if let foodAmount = foodAmount { entry.foodAmount = Int64(foodAmount) }
            if let timestamp = timestamp { entry.dateFed = timestamp }
        }

        var entryData: Data?
        do {
            entryData = try JSONEncoder().encode(entry.representation)
        } catch {
            completion(.dataCodingError(specifically: error))
        }

        var request = URL.base.request(for:
            .update(userID: user.id, feedingID: Int(entry.identifier)))
        request.httpBody = entryData
        // TODO: complete rest of request

        networkHandler.transferMahOptionalDatas(with: request) { result in
            self.handlePost(context: context, result: result, completion: completion)
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

        var request = URL.base.request(for:
            .delete(userID: user.id, feedingID: Int(entry.identifier)))
        // TODO: complete rest of request

        networkHandler.transferMahOptionalDatas(with: request) { result in
            self.handlePost(context: context, result: result, completion: completion)
        }
    }

    // MARK: - Private Methods

    private func handlePost(
        context: NSManagedObjectContext,
        result: Result<Data?, NetworkError>,
        completion: (NetworkError?) -> Void
    ) {
        do {
            _ = try result.get()
            var error: Error?
            context.performAndWait {
                guard context.hasChanges else { return }
                do {
                    try context.save()
                } catch let thisError {
                    error = thisError
                }
            }
            if let error = error {
                completion(.otherError(error: error))
            } else {
                completion(nil)
            }
        } catch let error as NetworkError {
            completion(error)
        } catch {
            completion(.otherError(error: error))
        }
    }
    
}
