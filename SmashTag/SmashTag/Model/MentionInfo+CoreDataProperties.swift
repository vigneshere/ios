//
//  MentionInfo+CoreDataProperties.swift
//  SmashTag
//
//  Created by Vignesh Saravanai on 19/06/16.
//  Copyright © 2016 Vignesh Saravanai. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension MentionInfo {

    @NSManaged var text: String?
    @NSManaged var type: String?
    @NSManaged var searchCounts: NSSet?
    @NSManaged var tweets: NSSet?

}
