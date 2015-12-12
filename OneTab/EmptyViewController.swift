//
//  EmptyViewController.swift
//  OneTab
//
//  Created by Alexander Semenov on 12/12/15.
//  Copyright © 2015 X-mass Three. All rights reserved.
//

import UIKit

class EmptyViewController: UIViewController {

    @IBOutlet weak var greetingsLabel: UILabel!
    @IBOutlet weak var newPageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.greetingsLabel.text = NSLocalizedString("GREETING_INITIAL", comment: "")
        self.newPageButton.setTitle(NSLocalizedString("NEW_PAGE_INITIAL", comment: ""), forState: .Normal)
    }
    
    @IBAction func newTabClicked(sender: AnyObject) {
        let webViewVC = self.storyboard?.instantiateViewControllerWithIdentifier("webViewController") as! WebTabController
        let url = NSURL(string: "https://google.com")!
        webViewVC.baseUrl = url
        presentViewController(webViewVC, animated: true, completion: {
            self.greetingsLabel.text = NSLocalizedString("GREETING_NORMAL", comment: "")
            self.newPageButton.setTitle(NSLocalizedString("NEW_PAGE_NORMAL", comment: ""), forState: .Normal)
        })
    }
}
