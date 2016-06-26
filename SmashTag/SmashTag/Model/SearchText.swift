//
//  SearchText.swift
//  SmashTag
//
//  Created by Vignesh Saravanai on 18/06/16.
//  Copyright © 2016 Vignesh Saravanai. All rights reserved.
//

import Foundation
import CoreData


class SearchText: NSManagedObject {

    class func addSearchText(searchText: String, inManagedObjectContext context: NSManagedObjectContext) -> SearchText? {
        let request = NSFetchRequest(entityName: "SearchText")
        request.predicate = NSPredicate(format: "text = %@", searchText)
        if let searchT = (try? context.executeFetchRequest(request))?.first as? SearchText {
            return searchT
        }
        if let searchT = NSEntityDescription.insertNewObjectForEntityForName("SearchText", inManagedObjectContext: context) as? SearchText {
            searchT.text = searchText
            return searchT
        }
        return nil
    }
}
