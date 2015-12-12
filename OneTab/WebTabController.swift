//
//  ViewController.swift
//  OneTab
//
//  Created by Alexander Semenov on 12/12/15.
//  Copyright © 2015 X-mass Three. All rights reserved.
//

import UIKit
import WebKit
import PureLayout

class WebTabController: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var bottomBar: UIToolbar!
    @IBOutlet weak var topBar: UINavigationBar!
    @IBOutlet weak var webViewContainer: UIView!

    @IBOutlet weak var webViewProgress: UIProgressView!
    var webView: WKWebView!
    var baseUrl: NSURL?

    override func viewDidLoad() {
        super.viewDidLoad()
        initWebView()
        webView.navigationDelegate = self
        webView.loadRequest(NSURLRequest(URL:self.baseUrl!))
    }

    private func initWebView(){
        webView = WKWebView()
        webViewContainer.addSubview(webView)
        webView.autoPinEdgesToSuperviewEdges()
        webView.scrollView.contentInset = UIEdgeInsetsMake(topBar.frame.size.height, 0, bottomBar.frame.size.height, 0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "estimatedProgress" {
            webViewProgress.progress = Float(webView.estimatedProgress)
        }
    }

    @IBAction func closePage(sender: AnyObject) {
        self.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
        webView.stopLoading()

    }
    
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
    }

}

