//
//  ImageCollectionViewCell.swift
//  SmashTag
//
//  Created by Vignesh Saravanai on 10/06/16.
//  Copyright © 2016 Vignesh Saravanai. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    var mediaItem : MediaItem? {
        didSet {
            loadImage()
        }
    }
    
    @IBOutlet weak var tImageView: UIImageView!
    
    private func loadImage() {
        
        guard let imageUrl = self.mediaItem?.url,
            let imageView = self.tImageView else {
            return
        }
        
        if let aspectRatio = self.mediaItem?.aspectRatio {
            let constraint = NSLayoutConstraint(item: imageView,
                                                attribute: NSLayoutAttribute.Height,
                                                relatedBy: NSLayoutRelation.Equal,
                                                toItem: imageView,
                                                attribute: NSLayoutAttribute.Width,
                                                multiplier: CGFloat(1/aspectRatio),
                                                constant: 0)
            constraint.priority = 999
            imageView.addConstraint(constraint);
        }
        
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
