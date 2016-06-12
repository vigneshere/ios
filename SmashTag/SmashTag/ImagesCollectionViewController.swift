//
//  ImagesCollectionViewController.swift
//  SmashTag
//
//  Created by Vignesh Saravanai on 10/06/16.
//  Copyright © 2016 Vignesh Saravanai. All rights reserved.
//

import UIKit

class ImagesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = UIColor.whiteColor()
        let rightBarButton = UIBarButtonItem(title: "Home", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(UIViewController.popToTopView(_:)))
        self.navigationItem.setRightBarButtonItem(rightBarButton, animated: false)
    }
    
    var images = [MediaItem]()
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    @IBAction func ShowTweets(sender: UISwipeGestureRecognizer) {
        performSegueWithIdentifier(Storyboard.ShowTweetsSegue, sender: sender)
    }
    
    private struct Storyboard {
        static let ShowTweetsSegue = "ShowTweets"
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath)
        
        if let imageCell = cell as? ImageCollectionViewCell {
            imageCell.mediaItem = images[indexPath.row]
        }

        return cell
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var size = CGSize(width: collectionView.frame.size.width/3, height: 100)
        size.height = size.width/CGFloat(images[indexPath.row].aspectRatio)
        return size
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
