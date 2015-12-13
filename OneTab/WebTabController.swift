//
//  ViewController.swift
//  OneTab
//
//  Created by Alexander Semenov on 12/12/15.
//  Copyright © 2015 X-mass Three. All rights reserved.
//

import UIKit
import WebKit
import RMDateSelectionViewController

class WebTabController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var bottomBar: UIToolbar!
    @IBOutlet weak var topBar: UINavigationBar!
    @IBOutlet weak var webViewContainer: SwiperViewContainer!
    @IBOutlet weak var swipeBackroudView: UIView!

    @IBOutlet weak var setReminderSwipeView: UIView!
    @IBOutlet weak var webViewProgress: UIProgressView!
    var webView: WKWebView!
    var baseUrl: NSURL?
    var contentLoaded: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        initWebView()
        initNotificationGesture()
        webView.navigationDelegate = self
        webView.loadRequest(NSURLRequest(URL: self.baseUrl!))
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveReminder:", name:"receiveReminder" , object: nil)

    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
            NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc func didReceiveReminder(notification: NSNotification){
        let urlStr = notification.userInfo!["url"] as! String
        let host = notification.userInfo!["host"] as! String
        let title = notification.userInfo!["title"] as! String
        let alert = UIAlertController(title: title, message: "You reminder for \(host)", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Open", style: .Default, handler: {
            (action: UIAlertAction) -> Void in
            let url = NSURL(string: urlStr)!
            self.webView.loadRequest(NSURLRequest(URL: url))
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
         self.presentViewController(alert, animated: true, completion: nil)
    }

    private func initWebView() {
        webView = WKWebView(frame: self.webViewContainer.frame)
        webViewContainer.swipeBackroudView = swipeBackroudView
        webViewContainer.addSubview(webView)
        webViewContainer.contentView = webView;
        
        webView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        let insets = UIEdgeInsetsMake(topBar.frame.size.height, 0, bottomBar.frame.size.height, 0)
        webView.scrollView.contentInset = insets
        webView.scrollView.scrollIndicatorInsets = insets
        webView.allowsBackForwardNavigationGestures = true
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String:AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "estimatedProgress" {
            webViewProgress.progress = Float(webView.estimatedProgress)
        }
    }

    @IBAction func goBack(sender: AnyObject) {
        if (webView.canGoBack){
            webView.goBack()
        } else {
            webView.stopLoading()
            self.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    @IBAction func refreshPage(sender: AnyObject) {
        if (self.contentLoaded) {
            webView.reload()
        } else {
            webView.stopLoading()
            webView.loadRequest(NSURLRequest(URL: self.baseUrl!))
        }
    }
    
    @IBAction func newInitialPage(sender: AnyObject) {
        if (webView.canGoBack){
            webView.loadRequest(NSURLRequest(URL: self.baseUrl!))
        }
    }
    
    // MARK: - Swipe
    private func initNotificationGesture(){
        webViewContainer.callback = {
            NSLog("Swipe callback called!")
            let datePicker = RMDateSelectionViewController(style: .White)!
            datePicker.title = "Remind later"
            datePicker.message = "Great! Now choose time or place to remind about this page"
           
            
            datePicker.addAction(RMAction(title: "Choose place", style: .Done, andHandler:  { (action: RMActionController) -> Void in
                    let alert = UIAlertController(title: "Ooooops", message: "Coming soon...", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                    self.presentViewController(alert, animated: true, completion: nil)
                })
                
            })!)
            
            datePicker.addAction(RMAction(title: "Use time", style: .Done, andHandler:  { (action: RMActionController) -> Void in
                    if let dateController = action as? RMDateSelectionViewController {
                              NotificationManager.sharedInstance.addReminder(dateController.datePicker.date, navigationItem: self.webView.backForwardList.currentItem!)
                    }
                    self.goBack(action)
            })!)
       
            datePicker.addAction(RMAction(title: "Cancel", style: .Cancel, andHandler: nil)!)
            
           
            let groupedAction = RMGroupedAction(style: .Additional, andActions:
                [self.datePickerActionForMinutes(5),
                self.datePickerActionForMinutes(15),
                self.datePickerActionForMinutes(30),
                self.datePickerActionForMinutes(45)]);
            datePicker.addAction(groupedAction!)
            
            let tommorowAction = RMAction(title: "Tomorrow", style: .Additional) { controller -> Void in
                if let dateController = controller as? RMDateSelectionViewController {
                    //adding 1 day - TODO this shoud set predefined time for ex 8.am
                    dateController.datePicker.date = NSDate().dateByAddingTimeInterval(60*60*24);
                }
            }!
            tommorowAction.dismissesActionController = false;
            datePicker.addAction(tommorowAction)
            datePicker.datePicker.minimumDate = NSDate()
            datePicker.datePicker.date = NSDate(timeIntervalSinceNow: 300) // 5 min by default
            self.presentViewController(datePicker, animated: true, completion: nil)
        }
    }
    
    func datePickerActionForMinutes(minutes: Int) -> (RMAction) {
        let minAction = RMAction(title: "\(minutes) Min", style: .Additional) { controller -> Void in
            if let dateController = controller as? RMDateSelectionViewController {
                dateController.datePicker.date = NSDate(timeIntervalSinceNow: Double(minutes)*60);
            }
        }
        minAction!.dismissesActionController = false;
        return minAction!
    }
    
    // MARK: - WKWebViewNavigationDelegate
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        webViewProgress.hidden = true
        NSLog("didFailNavigation %@, error %@", navigation, error)
    }

    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        webViewProgress.hidden = true
        NSLog("didFailNavigation %@, error %@", navigation, error)
    }

    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        webViewProgress.hidden = false
    }

    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        webViewProgress.hidden = true
        self.topBar.items![0].title = webView.URL!.host
        self.contentLoaded = true
    }

}

