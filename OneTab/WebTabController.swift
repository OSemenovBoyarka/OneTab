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

class WebTabController: UIViewController {
    
    @IBOutlet weak var bottomBar: UIToolbar!
    @IBOutlet weak var topBar: UINavigationBar!
    @IBOutlet weak var webViewContainer: UIView!

    var webView: WKWebView!
    var baseUrl: NSURL?

    override func viewDidLoad() {
        super.viewDidLoad()
        initWebView()
        webView.loadRequest(NSURLRequest(URL:self.baseUrl!))
    }

    private func initWebView(){
        webView = WKWebView()
        webViewContainer.addSubview(webView)
        webView.autoPinEdgesToSuperviewEdges()
        webView.scrollView.contentInset = UIEdgeInsetsMake(topBar.frame.size.height, 0, bottomBar.frame.size.height, 0)
    }

    @IBAction func closePage(sender: AnyObject) {
        self.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
    }

}

