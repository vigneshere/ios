//
//  TweetTableViewCell.swift
//  SmashTag
//
//  Created by Vignesh Saravanai on 03/06/16.
//  Copyright © 2016 Vignesh Saravanai. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var createdTextLabel: UILabel!
    @IBOutlet weak var tweeterTextLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!

    var tweet : Tweet? {
        didSet {
            updateUI()
        }
    }
    
    private func format( attrString : NSMutableAttributedString,  forMentions mentions : [Mention], withColor color : UIColor ) {
        for mention in mentions {
            attrString.addAttribute(NSForegroundColorAttributeName, value: color, range: mention.nsrange)
        }
    }
    
    private func getFormattedTweetText(tweet : Tweet) -> NSAttributedString {
        
        var tweetStr = tweet.text
        for _ in tweet.media {
            tweetStr += " 📷"
        }
        let tweetAttrString : NSMutableAttributedString = NSMutableAttributedString(string: tweetStr)
        format(tweetAttrString, forMentions: tweet.hashtags, withColor: UIColor.blueColor())
        format(tweetAttrString, forMentions: tweet.urls, withColor: UIColor.magentaColor())
        format(tweetAttrString, forMentions: tweet.userMentions, withColor: UIColor.orangeColor())
        return tweetAttrString
    }
    
    private func updateUI() {
        profileImageView?.image = nil
        createdTextLabel?.text = nil
        tweeterTextLabel?.text = nil
        tweetTextLabel?.attributedText = nil
        
        if let tweet = self.tweet {

            tweetTextLabel?.attributedText = getFormattedTweetText(tweet)

            tweeterTextLabel?.text = "\(tweet.user)"
            
            if let profileImageUrl = tweet.user.profileImageURL {
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                    if let imageData = NSData(contentsOfURL: profileImageUrl) {
                        dispatch_async(dispatch_get_main_queue()) { [weak weakSelf = self] in
                            if profileImageUrl == weakSelf?.tweet?.user.profileImageURL {
                                weakSelf?.profileImageView?.image = UIImage(data: imageData)
                            }
                            else {
                                print("looks like image is not in the view now, skip loading")
                            }
                        }
                    }
                }
            }
            
            let formatter = NSDateFormatter()
            if NSDate().timeIntervalSinceDate(tweet.created) > 24 * 60 * 60 {
                formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            }
            else {
                formatter.timeStyle = NSDateFormatterStyle.ShortStyle
            }
            createdTextLabel?.text = formatter.stringFromDate(tweet.created)
        }
    }
}
