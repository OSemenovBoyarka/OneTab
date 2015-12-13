//
//  SwiperViewContainer.swift
//  OneTab
//
//  Created by Alexander Semenov on 12/12/15.
//  Copyright © 2015 X-mass Three. All rights reserved.
//

import UIKit
import WebKit

class SwiperViewContainer: UIView, UICollisionBehaviorDelegate, UIGestureRecognizerDelegate {
    
    
 
    private var animator: UIDynamicAnimator?
    private var snapBehaviour: UISnapBehavior?
    private var attachmentBehaviour: UIAttachmentBehavior?
    private var panGesture: UIPanGestureRecognizer?
    
    var callback: (Void -> Void)?
           //TODO insert default collision detect view
    var swipeBackroudView: UIView?
    
    init(frame: CGRect, leftInset: CGFloat, rightInset: CGFloat) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    var contentView: WKWebView?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let contentView = contentView {
            if (panGesture == nil) {
                panGesture = UIPanGestureRecognizer(target: self, action: "contentViewDragged:")
                contentView.scrollView.addGestureRecognizer(panGesture!)
                panGesture?.delegate = self
                panGesture?.minimumNumberOfTouches = 1
            }
            
            contentView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
         
            animator?.removeAllBehaviors()
            animator = UIDynamicAnimator(referenceView: self)
            let dynamicBehaviour = UIDynamicItemBehavior(items: [contentView])
            dynamicBehaviour.allowsRotation = false
            animator?.addBehavior(dynamicBehaviour)
            snapBehaviour = UISnapBehavior(item: contentView, snapToPoint: CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)))
            animator?.addBehavior(snapBehaviour!)
            
     
            
            animator?.updateItemUsingCurrentState(contentView)
        }
    }
    
    override func addSubview(view: UIView) {
        super.addSubview(view)
        if let contentView = contentView {
            self.bringSubviewToFront(contentView)
        }
    }
    
    func contentViewDragged(pan: UIPanGestureRecognizer) {
        var center = pan.locationInView(self)
        switch pan.state {
            case .Began:
                attachmentBehaviour = UIAttachmentBehavior(item: contentView!, offsetFromCenter: UIOffsetZero, attachedToAnchor: center)
                animator?.addBehavior(attachmentBehaviour!)
                animator?.removeBehavior(snapBehaviour!)
            case .Changed:
                if (abs(pan.translationInView(self).x) >= swipeBackroudView?.frame.size.width){
                    if let callback = callback {
                        callback()
                    }
                    // forcing gesture to cancel
                    panGesture?.enabled = false
                    panGesture?.enabled = true
                    return
                }
                
                center.y = CGRectGetMidY(self.bounds)
                attachmentBehaviour?.anchorPoint = center
            case .Ended, .Cancelled:
                animator?.removeBehavior(attachmentBehaviour!)
                animator?.addBehavior(snapBehaviour!)
                attachmentBehaviour = nil
                contentView?.allowsBackForwardNavigationGestures = true
            default: break
        }
    }
    
    
    // :MARK: UIGestureRecognizerDelegate
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let contentView = contentView {
            let gestureStartPoint = gestureRecognizer.locationInView(contentView);
            NSLog("Pan should Begin at  %f, webViewFrameWidth: %f", gestureStartPoint.x, contentView.frame.size.width)
         
            let begin = (contentView.frame.size.width - gestureStartPoint.x) < 40
            contentView.allowsBackForwardNavigationGestures = !begin
            return begin
        } else {
            return false
        }
    }
    
}