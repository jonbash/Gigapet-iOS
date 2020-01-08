//
//  CoreDataStack.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-05.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import CoreData

class CoreDataStack {
    // MARK: - Singleton

    static let shared = CoreDataStack()

    private init() {}

    // MARK: - Properties

    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Gigapet")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    var mainContext: NSManagedObjectContext { container.viewContext }

    // MARK: - Methods

    func save(
        in context: NSManagedObjectContext = CoreDataStack.shared.mainContext
    ) throws {
        guard context.hasChanges else { return }
        var possibleError: Error?
        context.performAndWait {
            do {
                try context.save()
            } catch {
                possibleError = error
            }
        }
        if let error = possibleError { throw error }
    }
}
