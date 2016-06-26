//
//  SearchHistoryTableViewController.swift
//  SmashTag
//
//  Created by Vignesh Saravanai on 08/06/16.
//  Copyright © 2016 Vignesh Saravanai. All rights reserved.
//

import UIKit

class SearchHistoryTableViewController: UITableViewController {
    
    private let searchHistory = SearchHistory()
    
    private var history : [String] {
        searchHistory.loadHistory()
        return searchHistory.history
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
  
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Storyboard.RecentSearchSr
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }
    
    private struct Storyboard {
        static let CellIdentifier = "SearchItem"
        static let TweetSearchSegue = "Search"
        static let PopularSegue = "PopularSegue"
        static let RecentSearchSr = "Recent Searches"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = history[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let tabVC = self.tabBarController,
            let nav = tabVC.viewControllers?[0] as? UINavigationController else {
            return
        }
        tabVC.selectedIndex = 0
        print("\(nav.popToRootViewControllerAnimated(false))")
        if let tweetVC = nav.topViewController as? TweetTableViewController {
            print("Setting search string \(history[indexPath.row])")
            tweetVC.searchString = history[indexPath.row]
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            searchHistory.removeHistoryAt(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(Storyboard.PopularSegue, sender: history[indexPath.row])
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let searchText = sender as? String {
            if let destVC = segue.destinationViewController.contentViewController as? PopularMentionTableViewController {
                destVC.searchText = searchText
            }
        }
    }
}
