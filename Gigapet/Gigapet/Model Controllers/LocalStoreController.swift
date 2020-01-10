//
//  LocalStoreController.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-10.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import CoreData

class LocalStoreController {

    // MARK: - Properties
    
    let coreDataStack = CoreDataStack()

    var entries: [FoodEntry] = []

    // MARK: - Init

    init() {
        if isUITesting {
            self.entries = []
            deleteAllLocalEntries()
        }

        let fetchRequest: NSFetchRequest<FoodEntry> = FoodEntry.fetchRequest()
        do {
            self.entries = try coreDataStack.mainContext.fetch(fetchRequest)
        } catch {
            fatalError("Fetch request failed: \(error)")
        }

        do { try deleteDuplicateLocalEntries()
        } catch { NSLog("Error deleting duplicate local entries: \(error)") }
    }

    // MARK: - Update

    func refreshLocalEntries() throws {
        self.entries = sortedEntries(
            try getAllLocalEntries(using: coreDataStack.mainContext))
    }

    func updateLocalEntry(
        _ entry: FoodEntry,
        withCategory category: FoodCategory,
        name: String,
        dateFed: Date,
        foodAmount: Int
    ) throws {
        guard let context = entry.managedObjectContext else {
            let context = coreDataStack.container.newBackgroundContext()
            _ = FoodEntry(
                category: category,
                foodName: name,
                foodAmount: foodAmount,
                dateFed: dateFed,
                identifier: nil,
                context: context)
            try coreDataStack.save(in: context)
            return
        }

        // update local entry
        context.performAndWait {
            entry.foodCategory = category.rawValue
            entry.foodName = name
            entry.foodAmount = Int64(foodAmount)
            entry.dateFed = dateFed
        }

        try coreDataStack.save(in: context)
    }

    func updateLocalEntries(
        from serverReps: [FoodEntryRepresentation]
    ) throws {
        let context = coreDataStack.container.newBackgroundContext()

        let localEntries: [FoodEntry] = try context.fetch(FoodEntry.fetchRequest())

        var entriesByID = [Int: FoodEntry]()
        for entry in localEntries { entriesByID[Int(entry.identifier)] = entry }

        for rep in serverReps {
            guard let id = rep.identifier else { continue }

            if let localEntry = entriesByID[id] {
                localEntry.update(from: rep, context: context)
            } else {
                _ = FoodEntry(from: rep, context: context)
            }
        }
        try coreDataStack.save(in: context)

        self.entries = sortedEntries(self.entries)
    }

    // MARK: - Delete

    func deleteLocalEntry(_ entry: FoodEntry) throws {
        entries.removeAll { $0 == entry }

        guard let context = entry.managedObjectContext else { return }
        context.performAndWait {
            context.delete(entry)
        }
        try coreDataStack.save(in: context)
    }

    func deleteDuplicateLocalEntries() throws {
        let context = coreDataStack.container.newBackgroundContext()

        var localEntries = try getAllLocalEntries(using: context)

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

        try coreDataStack.save(in: context)
    }

    func deleteAllLocalEntries() {
        for entry in entries {
            guard let context = entry.managedObjectContext else { continue }
            var caughtError: Error?

            context.perform {
                context.delete(entry)
                do {
                    try context.save()
                } catch {
                    caughtError = error
                }
            }
            if let error = caughtError {
                NSLog("Error deleting entry \(entry.identifier): \(error)")
            }
        }
    }

    // MARK: - Private

    private func getAllLocalEntries(
        using context: NSManagedObjectContext
    ) throws -> [FoodEntry] {
        var fetchedEntries = [FoodEntry]()
        var caughtError: Error?

        context.performAndWait {
            do {
                fetchedEntries = try context.fetch(FoodEntry.fetchRequest())
            } catch {
                caughtError = error
            }
        }
        if let error = caughtError { throw error }

        return sortedEntries(fetchedEntries)
    }

    private func sortedEntries(_ entries: [FoodEntry]) -> [FoodEntry] {
        return entries.sorted {
            guard let date0 = $0.dateFed, let date1 = $1.dateFed else {
                return false
            }
            return date0 > date1
        }
    }
}
