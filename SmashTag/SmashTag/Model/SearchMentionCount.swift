//
//  SearchMentionCount.swift
//  SmashTag
//
//  Created by Vignesh Saravanai on 18/06/16.
//  Copyright © 2016 Vignesh Saravanai. All rights reserved.
//

import Foundation
import CoreData


class SearchMentionCount: NSManagedObject {

    class func addMentionCountForNewTweet(newTweet: Bool, mentionText: String, searchText: String,
                                          inManagedObjectContext context: NSManagedObjectContext) -> MentionInfo? {
        let request = NSFetchRequest(entityName: "SearchMentionCount")
        request.predicate = NSPredicate(format: "mention.text = %@ and searchText.text = %@", mentionText, searchText)
        if let smCount = (try? context.executeFetchRequest(request))?.first as? SearchMentionCount {
            if newTweet == true {
                smCount.count = NSNumber(integer: smCount.count!.integerValue + 1)
            }
            return smCount.mention
        }
        if let smCount = NSEntityDescription.insertNewObjectForEntityForName("SearchMentionCount", inManagedObjectContext: context) as? SearchMentionCount {
            smCount.count = 1
            smCount.searchText = SearchText.addSearchText(searchText, inManagedObjectContext: context)
            smCount.mention = MentionInfo.addMention(mentionText, inManagedObjectContext: context)
            return smCount.mention
        }
        return nil
    }
}
