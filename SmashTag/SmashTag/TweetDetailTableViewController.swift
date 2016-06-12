//
//  TweetDetailTableViewController.swift
//  SmashTag
//
//  Created by Vignesh Saravanai on 05/06/16.
//  Copyright © 2016 Vignesh Saravanai. All rights reserved.
//

import UIKit

class TweetDetailTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //not required using heightForCell delegate/datasource method instead
        //tableView.estimatedRowHeight = tableView.rowHeight
        //tableView.rowHeight = UITableViewAutomaticDimension
        
        let rightBarButton = UIBarButtonItem(title: "Home", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(UIViewController.popToTopView(_:)))
        self.navigationItem.setRightBarButtonItem(rightBarButton, animated: false)
    }
    
    private enum Mentions: Int  {
        case Media = 0
        case Urls
        case HashTags
        case UserMentions
    }
    
    private struct MentionProp {
        var name : String
        var cellType : String
        var item : [AnyObject]?
        
        init(name: String, cellType: String, item: [AnyObject]?) {
            self.item = (item == nil) ? [AnyObject]() : item
            self.name = (self.item!.count > 0) ? name : ""
            self.cellType = cellType
        }
    }
    
    private var mentions = Array<MentionProp>();
    
    var tweet : Tweet? {
        didSet {
            guard let _ = tweet else {
                return
            }
            populateMentions()
        }
    }

    private func populateMentions() {
        mentions.append(MentionProp(name: "Media", cellType: Storyboard.TweetImageCellIdentifier, item: tweet?.media))
        mentions.append(MentionProp(name: "Urls", cellType: Storyboard.TweetUrlMentionCellIdentifier, item: tweet?.urls.map {$0.keyword } ))
        mentions.append(MentionProp(name: "HashTags", cellType: Storyboard.TweetMentionCellIdentifier, item: tweet?.hashtags.map { $0.keyword } ))
        var userMentions = tweet?.userMentions.map { $0.keyword }
        userMentions?.append("@\(tweet!.user.screenName)")
        mentions.append(MentionProp(name: "UserMentions", cellType: Storyboard.TweetMentionCellIdentifier, item: userMentions))
    }
    
    private struct Storyboard {
        static let TweetImageCellIdentifier = "TweetImage"
        static let TweetMentionCellIdentifier = "TweetMention"
        static let TweetUrlMentionCellIdentifier = "TweetUrlMention"
        static let TweetMentionSegue = "SearchMention"
        static let TweetImageSegue = "ShowImage"
        static let LoadUrlSegue = "LoadUrl"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mentions[section].name
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return mentions.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentions[section].item!.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if Mentions(rawValue: indexPath.section) == Mentions.Media,
          let media = mentions[indexPath.section].item?[indexPath.row] as? MediaItem {
            return tableView.frame.size.width / CGFloat(media.aspectRatio)
        }
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
 
        let cell = tableView.dequeueReusableCellWithIdentifier(mentions[indexPath.section].cellType, forIndexPath: indexPath)
        
        if Mentions(rawValue: indexPath.section) == Mentions.Media {
            if let tweetImageCell = cell as? TweetImageTableViewCell,
               let media = mentions[indexPath.section].item?[indexPath.row] as? MediaItem {
               tweetImageCell.mediaItem = media
            }
        }
        else {
            if let mention = mentions[indexPath.section].item?[indexPath.row] as? String {
                cell.textLabel?.text = mention
            }
        }
        return cell
    }
    
    /*
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if Mentions(rawValue: indexPath.section) == Mentions.Urls {
            if let urlMention = mentions[indexPath.section].item?[indexPath.row] as? String {
                if let url = NSURL(string: urlMention) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
        }
    }*/
 
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("Segue \(segue.identifier)")
        if segue.identifier == Storyboard.TweetImageSegue,
            let cell = sender as? TweetImageTableViewCell,
            let destVC = segue.destinationViewController.contentViewController as? ImageViewController,
            let url = cell.mediaItem?.url {
            destVC.imageURL = url
            return
        }
        
       
        if segue.identifier == Storyboard.TweetMentionSegue,
            let cell = sender as? UITableViewCell,
            let destVC = segue.destinationViewController as? UITabBarController,
            let tweetVC = destVC.viewControllers?[0].contentViewController as? TweetTableViewController {
            print("Segue to TweetTableViewController")
            destVC.selectedIndex = 0
            tweetVC.searchString = cell.textLabel?.text
        }
        
        if segue.identifier == Storyboard.LoadUrlSegue,
            let cell = sender as? UITableViewCell,
            let destVC = segue.destinationViewController as? WebViewController,
            let url = cell.textLabel?.text {
            destVC.url = NSURL(string: url)
        }
    }

}
