//
//  TweetImageTableViewCell.swift
//  SmashTag
//
//  Created by Vignesh Saravanai on 05/06/16.
//  Copyright © 2016 Vignesh Saravanai. All rights reserved.
//

import UIKit

class TweetImageTableViewCell: UITableViewCell {
    
    var mediaItem : MediaItem? {
        didSet {
            loadImage()
        }
    }
    
    @IBOutlet weak var tImageView: UIImageView!
    
    private func loadImage() {
        
        guard let imageUrl = self.mediaItem?.url else {
              //let imageView = self.tImageView else {
            return
        }

        //looks like this can be done easily without constraint
        //below code works too and might be required for some other application
        //where it is required to set constraints in code
        /*if let aspectRatio = self.mediaItem?.aspectRatio {
            let constraint = NSLayoutConstraint(item: imageView,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.Equal,
                toItem: imageView,
                attribute: NSLayoutAttribute.Width,
                multiplier: CGFloat(1/aspectRatio),
                constant: 0)
            constraint.priority = 999
            imageView.addConstraint(constraint);
        }*/
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            if let imageData = NSData(contentsOfURL: imageUrl) {
                dispatch_async(dispatch_get_main_queue()) { [weak wSelf = self] in
                    if imageUrl == wSelf?.mediaItem?.url {
                        wSelf?.tImageView?.image = UIImage(data: imageData)
                    }
                }

            }
        }
    }

}
