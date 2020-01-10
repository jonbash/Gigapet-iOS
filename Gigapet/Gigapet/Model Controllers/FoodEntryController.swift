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

    private(set) var entries: [FoodEntry]

    private(set) var user: UserInfo

    private var networkHandler: NetworkHandler

    private let _explicitLoader: NetworkLoader?
    private lazy var mockUILoader: NetworkLoader = NetworkMockingSession(
        mockData: mockData(),
        mockError: nil)

    private var loader: NetworkLoader {
        if let explicitLoader = _explicitLoader {
            return explicitLoader
        } else if isUITesting {
            return mockUILoader
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

        let fetchRequest: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
        do {
            self.entries = try CoreDataStack.shared.mainContext.fetch(fetchRequest)
        } catch {
            fatalError("Fetch request failed: \(error)")
        }

        do { try deleteDuplicateLocalEntries()
        } catch { NSLog("Error deleting duplicate local entries: \(error)") }

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
        let context = CoreDataStack.shared.mainContext

        uploadNewEntry(
            FoodEntryRepresentation(
                foodCategory: category,
                foodName: foodName,
                foodAmount: foodAmount,
                dateFed: timestamp,
                identifier: nil),
            context: context,
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
        guard let context = entry.managedObjectContext else {
            addEntry(category: category,
                     foodName: foodName,
                     foodAmount: foodAmount,
                     timestamp: timestamp,
                     completion: completion)
            return
        }

        // update local entry
        context.performAndWait {
            entry.foodCategory = category.rawValue
            entry.foodName = foodName
            entry.foodAmount = Int64(foodAmount)
            entry.dateFed = timestamp
        }

        do { try CoreDataStack.shared.save(in: context)
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
            uploadNewEntry(entryRep, context: context, completion: completion)
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

        do { try deleteLocalEntry(entry) } catch {
            completion(.otherError(error: error))
            return
        }

        let request = APIRequestType
            .delete(user: user, feedingID: entryID)
            .request

        handleRequestWithFetchedEntries(request, completion: completion)
    }

    func deleteAllLocalEntries() {
        for entry in entries {
            guard let context = entry.managedObjectContext else { continue }
            var caughtError: Error?

            context.perform {
                context.delete(entry)
                do {
                    try CoreDataStack.shared.save(in: context)
                } catch {
                    caughtError = error
                }
            }
            if let error = caughtError {
                NSLog("Error deleting entry \(entry.identifier): \(error)")
            }
        }
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

        let context = CoreDataStack.shared.container.newBackgroundContext()

        let existingEntries = try context.fetch(fetchRequest)
        for entry in existingEntries {
            let id = Int(entry.identifier)
            guard let entryRep = repsByID[id] else { continue }

            entry.update(from: entryRep)
            entriesToCreate.removeValue(forKey: id)
        }

        context.performAndWait {
            for representation in entriesToCreate.values {
                entries.append(FoodEntry(from: representation, context: context))
            }
        }
        try CoreDataStack.shared.save(in: context)

        sortEntries()
    }

    private func deleteLocalEntries(notIn ids: [Int]) throws {
        let idsNotToFetch = ids.compactMap { Int64($0) }
        let fetchRequest: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "NOT (identifier IN %@)", idsNotToFetch)

        let context = CoreDataStack.shared.container.newBackgroundContext()

        let entriesToDelete = try context.fetch(fetchRequest)
        for entry in entriesToDelete {
            try deleteLocalEntry(entry)
        }
    }

    private func deleteDuplicateLocalEntries() throws {
        let context = CoreDataStack.shared.mainContext

        var localEntries = self.entries

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

        for entry in entriesToDelete { try deleteLocalEntry(entry) }

        try CoreDataStack.shared.save(in: context)
    }

    private func sortEntries() {
        entries.sort {
            guard let date0 = $0.dateFed, let date1 = $1.dateFed else {
                return false
            }
            return date0 > date1
        }
    }

    private func deleteLocalEntry(_ entry: FoodEntry) throws {
        entries.removeAll { $0 == entry }

        guard let context = entry.managedObjectContext else { return }
        context.performAndWait {
            context.delete(entry)
        }
        try CoreDataStack.shared.save(in: context)
    }
}
