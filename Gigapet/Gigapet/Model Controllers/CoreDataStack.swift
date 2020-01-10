//
//  CoreDataStack.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-05.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import CoreData

class CoreDataStack {

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
        in context: NSManagedObjectContext? = nil
    ) throws {
        let moc = context ?? mainContext
        guard moc.hasChanges else { return }
        
        var possibleError: Error?
        moc.performAndWait {
            do {
                try moc.save()
            } catch {
                possibleError = error
            }
        }
        if let error = possibleError { throw error }
    }
}
