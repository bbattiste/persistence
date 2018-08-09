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
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    // Load the persistent store
    func load(completion: (() -> Void)? = nil ) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            
            completion?()
            
        }
    }
    
}
