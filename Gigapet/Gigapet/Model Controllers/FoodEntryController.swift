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

    typealias ResultHandler = (NetworkError?) -> Void

    private(set) var user: UserInfo

    lazy var fetchedResultsController: NSFetchedResultsController<FoodEntry> = {
        let fetchRequest: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "dateFed", ascending: false)]
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: CoreDataStack.shared.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        do {
            try frc.performFetch()
        } catch {
            fatalError("Error initializing fetched results controller: \(error)")
        }

        return frc
    }()

    private var networkHandler: NetworkHandler = {
        let handler = NetworkHandler()
        handler.strict200CodeResponse = false
        return handler
    }()

    // MARK: - Init

    init(user: UserInfo) {
        self.user = user

        do { try deleteDuplicateLocalEntries() }
        catch { NSLog("Error deleting duplicate local entries: \(error)") }

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
            completion(.dataCodingError(specifically: NSError()))
            return
        }

        uploadNewEntry(entryRep, context: context, completion: completion)
    }

    func fetchAll(
        completion: @escaping ResultHandler
    ) {
        let request = APIRequestType.fetchAll(user: user).request

        handleRequestWithFetchedEntries(request, completion: completion)
    }

    func updateFoodEntry(
        _ entry: FoodEntry,
        withCategory category: FoodCategory?,
        foodName: String?,
        foodAmount: Int?,
        timestamp: Date?,
        completion: @escaping ResultHandler
    ) {
        guard let context = entry.managedObjectContext else {
            NSLog("Error updating entry: entry context is nil")
            completion(.otherError(error: NSError()))
            return
        }

        // update local entry
        context.performAndWait {
            if let category = category { entry.foodCategory = category.rawValue }
            if let foodName = foodName { entry.foodName = foodName }
            if let foodAmount = foodAmount { entry.foodAmount = Int64(foodAmount) }
            if let timestamp = timestamp { entry.dateFed = timestamp }
        }

        guard let entryRep = entry.representation else {
            completion(.dataCodingError(specifically: NSError()))
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
            completion(.dataCodingError(specifically: error))
            return
        }

        do {
            try CoreDataStack.shared.save(in: context)
        } catch {
            completion(.otherError(error: error))
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
        guard let context = entry.managedObjectContext else {
            NSLog("Error deleting entry: entry context is nil")
            completion(.otherError(error: NSError()))
            return
        }

        context.performAndWait {
            context.delete(entry)
            do {
                try context.save()
            } catch {
                completion(.otherError(error: error))
                return
            }
        }

        let request = APIRequestType
            .delete(user: user, feedingID: Int(entry.identifier))
            .request

        handleRequestWithFetchedEntries(request, completion: completion)
    }

    // MARK: - Sync Helpers

    private func uploadNewEntry(
        _ entryRep: FoodEntryRepresentation,
        context: NSManagedObjectContext,
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

        handleRequestWithFetchedEntries(request) { fetchError in
            if let error = fetchError {
                completion(error)
            } else {
                context.performAndWait {
                    _ = FoodEntry(from: entryRep, context: context)
                }

                do {
                    try CoreDataStack.shared.save(in: context)
                    completion(nil)
                } catch {
                    completion(.otherError(error: error))
                }
            }
        }
    }

    private func handleRequestWithFetchedEntries(
        _ request: URLRequest,
        completion: @escaping ResultHandler
    ) {
        networkHandler.transferMahCodableDatas(with: request
        ) { (result: Result<[FoodEntryRepresentation], NetworkError>) in

            var serverEntryReps = [FoodEntryRepresentation]()

            do {
                serverEntryReps = try result.get()
            } catch {
                completion(.dataCodingError(specifically: error))
                return
            }

            do {
                try self.updateLocalEntries(from: serverEntryReps)
                try CoreDataStack.shared.save()
            } catch {
                completion(.otherError(error: error))
            }

            completion(nil)
        }
    }

    // MARK: - Local Helpers

    private func updateLocalEntries(
        from serverReps: [FoodEntryRepresentation]
    ) throws {
        let idsToFetch = serverReps.compactMap { $0.identifier }
        let repsByID = Dictionary(
            uniqueKeysWithValues: zip(idsToFetch, serverReps)
        )
        var entriesToCreate = repsByID

        let fetchRequest: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", idsToFetch)

        try deleteLocalEntries(notIn: idsToFetch)

        var caughtError: Error?
        let context = CoreDataStack.shared.container.newBackgroundContext()
        context.performAndWait {
            do {
                let existingEntries = try context.fetch(fetchRequest)
                for entry in existingEntries {
                    let id = Int(entry.identifier)
                    guard
                        let entryRep = repsByID[id]
                        else { continue }
                    entry.update(from: entryRep)
                    entriesToCreate.removeValue(forKey: id)
                }
                for representation in entriesToCreate.values {
                    _ = FoodEntry(from: representation, context: context)
                }
                try CoreDataStack.shared.save(in: context)
            } catch { caughtError = error }
        }
        if let error = caughtError { throw error }
    }

    private func deleteLocalEntries(notIn ids: [Int]) throws {
        let idsNotToFetch = ids.compactMap { Int64($0) }
        let fetchRequest: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "NOT (identifier IN %@)", idsNotToFetch)

        var caughtError: Error?

        let context = CoreDataStack.shared.container.newBackgroundContext()
        context.performAndWait {
            do {
                let entriesToDelete = try context.fetch(fetchRequest)
                for entry in entriesToDelete { context.delete(entry) }
                try context.save()
            } catch { caughtError = error }
        }
        if let error = caughtError { throw error }
    }

    private func deleteDuplicateLocalEntries() throws {
        let context = CoreDataStack.shared.container.newBackgroundContext()

        var caughtError: Error?
        var localEntries = [FoodEntry]()
        context.performAndWait {
            do { localEntries = try context.fetch(FoodEntry.fetchRequest()) }
            catch { caughtError = error }
        }
        if let error = caughtError { throw error }

        var entriesToDelete = [FoodEntry]()
        var i = 0
        while i < localEntries.count {
            let entry = localEntries[i]
            var j = i + 1
            while j < localEntries.count {
                if entry.identifier == localEntries[j].identifier {
                    entriesToDelete.append(localEntries.remove(at: j))
                } else { j += 1 }
            }
            i += 1
        }

        context.performAndWait {
            for entry in entriesToDelete { context.delete(entry) }
        }

        try CoreDataStack.shared.save(in: context)
    }
}
