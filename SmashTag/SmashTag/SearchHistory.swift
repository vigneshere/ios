//
//  SearchHistory.swift
//  SmashTag
//
//  Created by Vignesh Saravanai on 08/06/16.
//  Copyright © 2016 Vignesh Saravanai. All rights reserved.
//

import Foundation

class SearchHistory {
    
    var history : [String] = [String]()
    
    func loadHistory() {
        if let storedHistory = NSUserDefaults.standardUserDefaults().objectForKey("TweetSearchHistory") as? [String] {
            history = storedHistory.map { $0 }
        }
    }
    
    func addToHistory(newSearch: String) {
        if let index = history.indexOf(newSearch.lowercaseString) {
            history.removeAtIndex(index)
        }
        history.insert(newSearch.lowercaseString, atIndex: 0)
        saveHistory()
    }
    
    func clearHistory() {
        history.removeAll()
        saveHistory()
    }
    
    func removeHistoryAt(let index: Int) {
        if history.count > index {
            history.removeAtIndex(index)
        }
        saveHistory()
    }
    
    func saveHistory() {
        NSUserDefaults.standardUserDefaults().setObject(history, forKey: "TweetSearchHistory")
    }
}