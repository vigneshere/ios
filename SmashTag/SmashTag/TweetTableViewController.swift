//
//  TweetTableViewController.swift
//  SmashTag
//
//  Created by Vignesh Saravanai on 03/06/16.
//  Copyright © 2016 Vignesh Saravanai. All rights reserved.
//

import UIKit
import CoreData

class TweetTableViewController: UITableViewController, UITextFieldDelegate {

    var tweets:Array<[Tweet]> = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var searchString : String? {
        didSet {
            print("SearchString set \(searchString)")
            tweets.removeAll()
            lastTwitterRequest = nil
            searchTweets()
            title = searchString
            searchHistory.addToHistory(searchString!)
            searchTextField?.text = searchString
        }
    }
    
    var twitterRequest : Request? {
        if lastTwitterRequest != nil {
            return lastTwitterRequest?.requestForNewer
        }
        if let query = searchString where !query.isEmpty {
            return Request(search: query + " -filter:retweets", count: 100)
        }
        return nil
    }
    
    private var lastTwitterRequest : Request?
    
    func searchTweets() {
        guard let request = twitterRequest else {
            self.refreshControl?.endRefreshing()
            return
        }
        
        lastTwitterRequest = request
        request.fetchTweets { [weak weakSelf = self] newTweets in
            dispatch_async(dispatch_get_main_queue()) {
                if !newTweets.isEmpty && request == weakSelf?.lastTwitterRequest {
                    weakSelf?.tweets.insert(newTweets, atIndex: 0)
                    weakSelf?.updateDatabase(newTweets)
                }
                print("new tweets \(newTweets.count)" )
                weakSelf?.refreshControl?.endRefreshing()
            }
        }
    }
    
    private func updateDatabase(newTweets: [Tweet]) {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).dataController.managedObjectContext
        context.performBlock {
            let searchText = SearchText.addSearchText(self.searchString!, inManagedObjectContext: context)
            let lastSearch = searchText?.searchedAt
            searchText?.searchedAt = NSDate()
            _ = TweetInfo.addTweets(newTweets, searchText: self.searchString!, lastSearchedAt: lastSearch, inManagedObjectContext: context)
            do {
                try context.save()
            }
            catch let error {
                print("context save failed \(error)")
            }
            
        }
        printDBStats()
    }
    
    private func printDBStats() {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).dataController.managedObjectContext
        context.performBlock {
            if let results = try? context.executeFetchRequest(NSFetchRequest(entityName: "MentionInfo")) {
                print("\(results.count) Mentions")
            }
            let tweetCount = context.countForFetchRequest(NSFetchRequest(entityName: "TweetInfo"), error: nil)
            print("\(tweetCount) Tweets")
        }
        print("done DB stats")
    }
    
    private let searchHistory = SearchHistory()
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        searchHistory.loadHistory()
        
        let showImagesGesture = UISwipeGestureRecognizer(target: self, action: #selector(TweetTableViewController.swipeAction(_:)))
        showImagesGesture.direction = UISwipeGestureRecognizerDirection.Left
        tableView.addGestureRecognizer(showImagesGesture)
              
        //refreshControl can be enabled in storyboard and action can be wired up from storyboard
        //refreshControl = UIRefreshControl()
        //refreshControl?.attributedTitle = NSAttributedString(string: "Pull To Refresh")
        //refreshControl?.addTarget(self, action: #selector(TweetTableViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    

    
    @IBAction func refresh(sender: UIRefreshControl) {
         searchTweets()
    }
    
    func swipeAction(sender: UISwipeGestureRecognizer) {
        print("got swipe")
        performSegueWithIdentifier(Storyboard.ShowImagesSegue, sender: sender)
    }
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(tweets.count - section)"
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }
    
    private struct Storyboard {
        static let TweetCellIdentifier = "Tweet"
        static let ShowImagesSegue = "ShowImage"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TweetCellIdentifier, forIndexPath: indexPath)
        
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweets[indexPath.section][indexPath.row]
        }
        
        return cell
    }

    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField?.delegate = self
            searchTextField?.text = searchString
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchString = textField.text
        return true
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let tweetCell = sender as? TweetTableViewCell {
            if let destVC = segue.destinationViewController.contentViewController as? TweetDetailTableViewController {
                destVC.tweet = tweetCell.tweet
            }
        }
        
        if let _ = sender as? UISwipeGestureRecognizer {
            if let destVC = segue.destinationViewController.contentViewController as? ImagesCollectionViewController {
                destVC.images = tweets.flatten().map { $0.media }.flatMap { $0 }
            }
        }
    }
}

extension UIViewController {
    var contentViewController : UIViewController {
        if let navCon = self as? UINavigationController {
            return navCon.visibleViewController ?? self
        }
        return self
    }
    
    func popToTopView(sender: AnyObject?) {
        guard let tabVC = self.tabBarController,
            let nav = tabVC.viewControllers?[0] as? UINavigationController else {
                return
        }
        tabVC.selectedIndex = 0
        print("\(nav.popToRootViewControllerAnimated(false))")
    }
}
