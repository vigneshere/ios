//
//  MentionInfo.swift
//  SmashTag
//
//  Created by Vignesh Saravanai on 18/06/16.
//  Copyright © 2016 Vignesh Saravanai. All rights reserved.
//

import Foundation
import CoreData

@objc(MentionInfo)
class MentionInfo: NSManagedObject {

    class func addMention(mentionText: String, inManagedObjectContext context: NSManagedObjectContext) -> MentionInfo? {
        let request = NSFetchRequest(entityName: "MentionInfo")
        request.predicate = NSPredicate(format: "text = %@", mentionText)
        if let mention = (try? context.executeFetchRequest(request))?.first as? MentionInfo {
            return mention
        }
        if let mention = NSEntityDescription.insertNewObjectForEntityForName("MentionInfo", inManagedObjectContext: context) as? MentionInfo {
            mention.text = mentionText
            mention.type = (mentionText.hasPrefix("@") ? "UserMention" : "HashTagMention")
            return mention
        }
        return nil
    }

}
