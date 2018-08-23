//
//  Notebook+Extensions.swift
//  Mooskine
//
//  Created by Bryan's Air on 8/23/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation
import CoreData

// Sets creation date from ititialization
extension Notebook {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
