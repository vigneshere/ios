//
//  DataController.swift
//  SmashTag
//
//  Created by Vignesh Saravanai on 17/06/16.
//  Copyright © 2016 Vignesh Saravanai. All rights reserved.
//

import UIKit
import CoreData

class DataController: NSObject {
    var managedObjectContext: NSManagedObjectContext
    override init() {
        guard let modelURL = NSBundle.mainBundle().URLForResource("Model", withExtension: "momd") else {
            fatalError("Error loading model from bundle")
        }
        
        guard let mom = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = psc
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            if let docsDir = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first {
                let storeURL = docsDir.URLByAppendingPathComponent("Model.sqlite")
                do {
                    try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
                } catch {
                    fatalError("Error migrating store: \(error)")
                }
            }
        }
    }
}
