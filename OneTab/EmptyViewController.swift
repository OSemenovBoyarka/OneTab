//
//  EmptyViewController.swift
//  OneTab
//
//  Created by Alexander Semenov on 12/12/15.
//  Copyright © 2015 X-mass Three. All rights reserved.
//

import UIKit

class EmptyViewController: UIViewController {

    @IBAction func newTabClicked(sender: AnyObject) {
        let webViewVC = self.storyboard?.instantiateViewControllerWithIdentifier("webViewController") as! WebTabController
        let url = NSURL(string: "https://google.com")!
        webViewVC.baseUrl = url
        presentViewController(webViewVC, animated: true, completion: nil)
    }
}
