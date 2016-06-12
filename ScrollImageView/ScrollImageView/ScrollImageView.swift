//
//  ScrollImageView.swift
//  ScrollImageView
//
//  Created by Vignesh Saravanai on 18/05/16.
//  Copyright © 2016 Vignesh Saravanai. All rights reserved.
//

import UIKit

class ScrollImageViewController: UIViewController {
    
    var imageURL : NSURL? {
        didSet {
            if let url = imageURL {
                if let imageData = NSData(contentsOfURL: url) {
                    image = UIImage(data: imageData)
                }
            }
        }
    }
    
    var imageView = UIImageView()
    
    var image : UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentSize = imageView.frame.size
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
        scrollView.contentSize = imageView.frame.size
        
        imageURL = NSURL(string: "http://www.planwallpaper.com/static/images/butterfly-wallpaper.jpeg")
    }

}
