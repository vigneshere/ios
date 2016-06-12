//
//  WebViewController.swift
//  SmashTag
//
//  Created by Vignesh Saravanai on 11/06/16.
//  Copyright © 2016 Vignesh Saravanai. All rights reserved.
//

import UIKit

class WebViewController: UIViewController { //, UIGestureRecognizerDelegate {
    
    var url : NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = self.url {
            print("\(url)")
            webView.loadRequest(NSURLRequest(URL: url))
        }

        /* going to use toolbar instead of separate button
        toggleButton(backButton)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(WebViewController.showAction(_:)))
        tapRecognizer.delegate = self
        tapRecognizer.numberOfTouchesRequired = 1
        tapRecognizer.numberOfTapsRequired = 1
        webView.addGestureRecognizer(tapRecognizer) */

        webView.opaque = false
        webView.backgroundColor = UIColor.clearColor()
        
        let rightBarButton = UIBarButtonItem(title: "Home", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(UIViewController.popToTopView(_:)))
        self.navigationItem.setRightBarButtonItem(rightBarButton, animated: false)
        

        self.navigationController?.toolbarHidden = false
        self.navigationController?.toolbar.barStyle = UIBarStyle.BlackOpaque
        self.navigationController?.barHideOnTapGestureRecognizer.enabled = true
        self.navigationController?.barHideOnTapGestureRecognizer.numberOfTapsRequired = 1
        self.navigationController?.barHideOnTapGestureRecognizer.numberOfTouchesRequired = 1
        self.navigationController?.barHideOnTapGestureRecognizer.cancelsTouchesInView = false
        self.navigationController?.hidesBarsOnTap = true
        
        let flexiSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        let backB = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Reply , target: self, action: #selector(WebViewController.backAction(_:)))
        let forwardB = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Play , target: self, action: #selector(WebViewController.forwardAction(_:)))
        let refreshB = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh , target: self, action: #selector(WebViewController.refreshAction(_:)))
        let stopB = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop , target: self, action: #selector(WebViewController.stopAction(_:)))
        self.setToolbarItems([backB, flexiSpace, forwardB, flexiSpace, refreshB, flexiSpace, stopB ], animated: false)

        //can be done by changing "Adjust Scroll View Insets" in storyboard
        //self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.toolbarHidden = true
    }

    /*
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func showAction(sender: UITapGestureRecognizer) {
        print("tapped")
        toggleButton(backButton)
    }
    
    private func toggleButton(button: UIButton?) {
        if let button = button {
            button.hidden = !(button.hidden)
        }
    }
     
    @IBOutlet weak var backButton: UIButton!*/
    
    @IBOutlet weak var webView: UIWebView!
    
    
    @IBAction func backAction(sender: UIButton) {
        if webView.canGoBack {
           webView.goBack()
        }
    }
    
    func forwardAction(sender: UIButton) {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    func refreshAction(sender: UIButton) {
         webView.reload()
    }
    
    func stopAction(sender: UIButton) {
        if webView.loading {
            webView.stopLoading()
        }
    }
    
}
