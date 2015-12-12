//
//  ViewController.swift
//  OneTab
//
//  Created by Alexander Semenov on 12/12/15.
//  Copyright © 2015 X-mass Three. All rights reserved.
//

import UIKit
import WebKit

class WebTabController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var bottomBar: UIToolbar!
    @IBOutlet weak var topBar: UINavigationBar!
    @IBOutlet weak var webViewContainer: UIView!

    @IBOutlet weak var webViewProgress: UIProgressView!
    var webView: WKWebView!
    var baseUrl: NSURL?
    var contentLoaded: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        initWebView()
        webView.navigationDelegate = self
        webView.loadRequest(NSURLRequest(URL: self.baseUrl!))
    }

    private func initWebView() {
        webView = WKWebView(frame: self.webViewContainer.frame)
        webViewContainer.addSubview(webView)
        webView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        let insets = UIEdgeInsetsMake(topBar.frame.size.height, 0, bottomBar.frame.size.height, 0)
        webView.scrollView.contentInset = insets
        webView.scrollView.scrollIndicatorInsets = insets
        webView.allowsBackForwardNavigationGestures = true
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
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
        webView.reload()
    }
    
    @IBAction func newInitialPage(sender: AnyObject) {
        if (webView.canGoBack){
            webView.loadRequest(NSURLRequest(URL: self.baseUrl!))
        }
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

