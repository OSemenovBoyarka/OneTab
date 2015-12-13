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
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveReminder:", name:"receiveReminder" , object: nil)
        if let reminder = NotificationManager.sharedInstance.pendingReminder {
            showReminder(reminder)
            NotificationManager.sharedInstance.pendingReminder = nil
        }

    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc func didReceiveReminder(notification: NSNotification){
        NotificationManager.sharedInstance.pendingReminder = nil
        
        let reminder = WebPageReminder()
        reminder.url = notification.userInfo!["url"] as! String
        reminder.host = notification.userInfo!["host"] as! String
        reminder.title =  notification.userInfo!["title"] as! String
        showReminder(reminder)
    }
    
    
    func showReminder(reminder: WebPageReminder){
        let alert = UIAlertController(title: title, message: "You reminder for \(reminder.host)", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Open", style: .Default, handler: {
            (action: UIAlertAction) -> Void in
            let url = NSURL(string: reminder.url)!
            let webViewVC = self.storyboard?.instantiateViewControllerWithIdentifier("webViewController") as! WebTabController
            webViewVC.baseUrl = url
            self.presentViewController(webViewVC, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }



}
