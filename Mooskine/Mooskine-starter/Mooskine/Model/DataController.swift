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
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    // Load the persistent store
    func load() {
        persistentContainer.loadPersistentStores { storeDescription, error in
            
            
        }
    }
    
}
