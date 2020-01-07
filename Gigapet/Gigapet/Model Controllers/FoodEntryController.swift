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
        timestamp: Date = Date(),
        uuid: UUID = UUID(),
        completion: @escaping ((NetworkError?) -> Void)
    ) {
        let context = CoreDataStack.shared.container.newBackgroundContext()
        var entry: FoodEntry?
        context.performAndWait {
            entry = FoodEntry(category: category,
                timestamp: timestamp,
                uuid: uuid,
                context: context)
        }

        var entryData: Data?
        do {
            entryData = try JSONEncoder().encode(entry?.representation)
        } catch {
            completion(.dataCodingError(specifically: error))
        }

        var request = URL.base.requestUrl(for: .create).request
        request.httpBody = entryData
        // TODO: complete request for adding entry

        networkHandler.transferMahOptionalDatas(with: request) { result in
            self.handlePost(context: context, result: result, completion: completion)
        }
    }

    func fetchAll(
        completion: @escaping (Result<[FoodEntry], NetworkError>) -> Void
    ) {
        let context = CoreDataStack.shared.container.newBackgroundContext()
        var request = URL.base.requestUrl(for: .fetchAll).request
        // TODO: complete rest of request

        networkHandler.transferMahCodableDatas(with: request)
        { (result: Result<[FoodEntry.Representation], NetworkError>) in
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
        timestamp: Date?,
        completion: @escaping (NetworkError?) -> Void
    ) {
        let context = CoreDataStack.shared.container.newBackgroundContext()

        context.performAndWait {
            if let category = category { entry.foodCategory = category.rawValue }
            if let timestamp = timestamp { entry.timestamp = timestamp }
        }

        var entryData: Data?
        do {
            entryData = try JSONEncoder().encode(entry.representation)
        } catch {
            completion(.dataCodingError(specifically: error))
        }

        var request = URL.base.requestUrl(for: .update).request
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

        var request = URL.base.requestUrl(for: .delete).request
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
