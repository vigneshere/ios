//
//  TweetInfo.swift
//  SmashTag
//
//  Created by Vignesh Saravanai on 18/06/16.
//  Copyright © 2016 Vignesh Saravanai. All rights reserved.
//

import Foundation
import CoreData

@objc(TweetInfo)
class TweetInfo: NSManagedObject {
    
    class func addTweets(tweetArr: [Tweet], searchText: String,
                         lastSearchedAt lastSearchTime: NSDate?,
                                        inManagedObjectContext context: NSManagedObjectContext) -> [TweetInfo] {
        
        var tweetIds = tweetArr.map { $0.id }
        var tweetHash = [String: Tweet]()
        tweetHash.append(tweetArr.map {($0.id, $0)})
        var tweetInfoArr = updateTweets(tweetIds, WithTweetHash: tweetHash,
                                        searchText: searchText,
                                        lastSearchedAt: lastSearchTime,
                                        inManagedObjectContext: context);
        let oldTweetIds = tweetInfoArr.filter { $0.uniqid != nil }.map { $0.uniqid! }
        print("old tweet count \(oldTweetIds.count)")
        tweetIds = tweetIds.filter { !oldTweetIds.contains($0) }
        for tweetId in tweetIds {
            if let tweet = tweetHash[tweetId],
                let tweetInfo = addNewTweet(tweet, searchText: searchText,
                                            inManagedObjectContext: context) {
                tweetInfoArr.append(tweetInfo)
            }
        }
        print("new tweet count \(tweetIds.count) \(tweetInfoArr.count)")
        return tweetInfoArr
    }
    
    class func updateTweets(tweetIds: [String], WithTweetHash tweetHash:[String: Tweet],
                            searchText: String, lastSearchedAt lastSearchTime: NSDate?,
                            inManagedObjectContext context: NSManagedObjectContext) -> [TweetInfo] {
        
        let request = NSFetchRequest(entityName: "TweetInfo")
        request.predicate = NSPredicate(format: "uniqid IN %@", tweetIds)
        if let oldTweets = try? context.executeFetchRequest(request) ,
            let oldTweetInfoArr = oldTweets as? [TweetInfo] {
            for oldTweetInfo in oldTweetInfoArr {
                if let oldTweetId = oldTweetInfo.uniqid,
                    let oldTweet = tweetHash[oldTweetId] {
                    updateTweet(oldTweetInfo, WithTweet: oldTweet,
                                searchText: searchText,
                                lastSearchedAt: lastSearchTime,
                                inManagedObjectContext: context)
                }
            }
            return oldTweetInfoArr
        }
        return [TweetInfo]()
    }
    
    class func addTweetInfo(tweet: Tweet, searchText: String,
                            lastSearchedAt lastSearchTime: NSDate?,
                                           inManagedObjectContext context: NSManagedObjectContext) -> TweetInfo? {
        let request = NSFetchRequest(entityName: "TweetInfo")
        request.predicate = NSPredicate(format: "uniqid = %@", tweet.id)
        if let tweetInfo = (try? context.executeFetchRequest(request))?.first as? TweetInfo {
            updateTweet(tweetInfo, WithTweet: tweet,
                        searchText: searchText,
                        lastSearchedAt: lastSearchTime,
                        inManagedObjectContext: context)
        }
        return addNewTweet(tweet, searchText: searchText,
                           inManagedObjectContext: context)
    }
    
    class func updateTweet(tweetInfo: TweetInfo, WithTweet tweet: Tweet, searchText: String,
                           lastSearchedAt lastSearchTime: NSDate?,
                                          inManagedObjectContext context: NSManagedObjectContext) {
        
        let newTweet = (lastSearchTime?.compare(tweet.created) == NSComparisonResult.OrderedAscending) ? true : false
        let mentions = tweet.hashtags + tweet.userMentions
        for mention in mentions {
            SearchMentionCount.addMentionCountForNewTweet(newTweet, mentionText: mention.keyword,
                                                          searchText: searchText,
                                                          inManagedObjectContext: context)
        }
    }
    
    class func addNewTweet(twitterInfo: Tweet, searchText: String,
                           inManagedObjectContext context: NSManagedObjectContext) -> TweetInfo? {
        if let tweet = NSEntityDescription.insertNewObjectForEntityForName("TweetInfo", inManagedObjectContext: context) as? TweetInfo {
            tweet.uniqid = twitterInfo.id
            tweet.text = twitterInfo.text
            let tMentions = tweet.mutableSetValueForKey("mentions")
            let mentions = twitterInfo.hashtags + twitterInfo.userMentions
            for mention in mentions {
                if let mentionInfo = SearchMentionCount.addMentionCountForNewTweet(true, mentionText: mention.keyword,
                                                                                   searchText: searchText,
                                                                                   inManagedObjectContext: context) {
                    tMentions.addObject(mentionInfo)
                }
            }
            return tweet
        }
        return nil
    }
    
}

extension Dictionary {
    mutating func append(keyValTupleArr: [(Key, Value)]) {
        for keyValTuple in keyValTupleArr {
            self[keyValTuple.0] = keyValTuple.1
        }
    }
}
