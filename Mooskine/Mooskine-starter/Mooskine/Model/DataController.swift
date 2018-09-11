//
//  DataController.swift
//  Mooskine
//
//  Created by Bryan's Air on 8/8/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    // Create the persistent container
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var backgroundContext: NSManagedObjectContext!
    
    init(modelName: String) {
        // temporary background context: task based background check with debug flag on next line
        persistentContainer = NSPersistentContainer(name: modelName)
    
        
    }
    
    func configureContexts() {
        // 2. long-lived newBackgroundContext: factory method to create background context that sticks around
        backgroundContext = persistentContainer.newBackgroundContext()
        
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        //set background thread to be athoritative version of data
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        
//        persistentContainer.performBackgroundTask { context in
//            doSomeSlowWork()
//            try? context.save()
//        }
//
//        viewContext.perform {
//            doSomeWork()
//        }
//
//        viewContext.performAndWait {
//            doSomeWork()
//        }
    }
    
    // Load the persistent store
    func load(completion: (() -> Void)? = nil ) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            
            self.autoSaveViewContext()
            self.configureContexts()
            completion?()
        }
    }
}

extension DataController {
    func autoSaveViewContext(interval: TimeInterval = 30) {
        // Could use NSTimer instead for more control, like pausing timer
        
        print("autosaving")
        guard interval > 0 else {
            print("cannot set negative autosave interval")
            return
        }
        
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}
