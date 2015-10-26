//
//  FloatingActionSheetController.swift
//  FloatingActionSheetController
//
//  Created by Ryo Aoyama on 10/25/15.
//  Copyright © 2015 Ryo Aoyama. All rights reserved.
//

import UIKit

public class FloatingActionSheetController: UIViewController {
    
    // MARK: Public
    
    public var itemTintColor = UIColor(red:0.13, green:0.13, blue:0.17, alpha:1)
    public var font = UIFont.boldSystemFontOfSize(14)
    public var textColor = UIColor.whiteColor()
    public var dimmingColor = UIColor(white: 0, alpha: 0.7)
    
    public convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    public convenience init(actionGroup: FloatingActionGroup...) {
        self.init(nibName: nil, bundle: nil)
        actionGroup.forEach { addActionGroup($0) }
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configure()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    public override func prefersStatusBarHidden() -> Bool {
        return UIApplication.sharedApplication().statusBarHidden
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if !isShowing {
            showActionSheet()
        }
    }
    
    public func present(inViewController: UIViewController, completion: (() -> Void)? = nil) -> Self {
        inViewController.presentViewController(self, animated: true, completion: completion)
        return self
    }
    
    public func dismiss() -> Self {
        dismissActionSheet()
        return self
    }
    
    public func addActionGroup(actionGroup: FloatingActionGroup...) -> Self {
        actionGroups += actionGroup
        return self
    }
    
    public func addAction(action: FloatingAction..., newGroup: Bool = false) -> Self {        
        if let lastGroup = actionGroups.last where !newGroup {
            action.forEach { lastGroup.addAction($0) }
        } else {
            let actionGroup = FloatingActionGroup()
            action.forEach { actionGroup.addAction($0) }
            addActionGroup(actionGroup)
        }
        return self
    }
    
    // MARK: Private
    
    private class ActionButton: UIButton {
        
        private(set) var action: FloatingAction?
        private var handler: ((action: FloatingAction) -> Void)?
        private var defaultBackgroundColor: UIColor?
        
        override var highlighted: Bool {
            didSet {
                guard oldValue != highlighted else { return }
                if highlighted {
                    defaultBackgroundColor = backgroundColor
                    backgroundColor = highlightedColor(defaultBackgroundColor)
                } else {
                    backgroundColor = defaultBackgroundColor
                    defaultBackgroundColor = nil
                }
            }
        }
        
        func configure(action: FloatingAction) {
            self.action = action
            handler = action.handler
            setTitle(action.title, forState: .Normal)
            _ = action.customTintColor.map {
                backgroundColor = $0
            }
            _ = action.customTextColor.map {
                setTitleColor($0, forState: .Normal)
            }
            _ = action.customFont.map {
                titleLabel?.font = $0
            }
        }
        
        private func highlightedColor(originalColor: UIColor?) -> UIColor? {
            guard let originalColor = originalColor else { return nil }
            var hue: CGFloat = 0, saturatioin: CGFloat = 0,
            brightness: CGFloat = 0, alpha: CGFloat = 0
            if originalColor.getHue(
                &hue,
                saturation: &saturatioin,
                brightness: &brightness,
                alpha: &alpha) {
                    return UIColor(hue: hue, saturation: saturatioin, brightness: brightness * 0.75, alpha: alpha)
            }
            return originalColor
        }
    }
    
    private var actionGroups = [FloatingActionGroup]()
    private var actionButtons = [ActionButton]()
    private var isShowing = false
    
    private weak var dimmingView: UIControl!
    
    private func showActionSheet() {
        isShowing = true
        dimmingView.backgroundColor = dimmingColor
        
        let itemHeight: CGFloat = 50
        let itemSpacing: CGFloat = 10
        let groupSpacing: CGFloat = 30
        var previousGroupLastButton: ActionButton?
        
        actionGroups.reverse().forEach {            
            var previousButton: ActionButton?
            $0.actions.reverse().forEach {
                let button = createSheetButton($0)
                view.addSubview(button)
                var constraints = NSLayoutConstraint.constraintsWithVisualFormat(
                    "H:|-(spacing)-[button]-(spacing)-|",
                    options: [],
                    metrics: ["spacing": itemSpacing],
                    views: ["button": button]
                )
                if let previousButton = previousButton {
                    constraints +=
                    NSLayoutConstraint.constraintsWithVisualFormat(
                        "V:[button(height)]-spacing-[previous]",
                        options: [],
                        metrics: ["height": itemHeight,"spacing": itemSpacing],
                        views: ["button": button, "previous": previousButton]
                    )
                } else if let previousGroupLastButton = previousGroupLastButton {
                    constraints +=
                        NSLayoutConstraint.constraintsWithVisualFormat(
                            "V:[button(height)]-spacing-[previous]",
                            options: [],
                            metrics: ["height": itemHeight, "spacing": groupSpacing],
                            views: ["button": button, "previous": previousGroupLastButton]
                    )
                } else {
                    constraints +=
                        NSLayoutConstraint.constraintsWithVisualFormat(
                            "V:[button(height)]-spacing-|",
                            options: [],
                            metrics: ["height": itemHeight,"spacing": itemSpacing],
                            views: ["button": button]
                    )
                }
                view.addConstraints(constraints)
                previousButton = button
                previousGroupLastButton = button
                actionButtons.append(button)
            }
        }
        view.layoutIfNeeded()
        
        if let topButtonY = actionButtons.last?.frame.origin.y {
            let bottomPad = view.bounds.height - topButtonY
            actionButtons.reverse().enumerate().forEach { index, button in
                button.layer.transform = CATransform3DMakeTranslation(0, bottomPad, 1)
                UIView.animateWithDuration(0.25, delay: NSTimeInterval(index) * 0.05 + 0.05,
                    options: .BeginFromCurrentState,
                    animations: {
                        button.layer.transform = CATransform3DMakeTranslation(0, -10, 1)
                    }) { _ in
                        UIView.animateWithDuration(0.2, delay: 0,
                            options: [.BeginFromCurrentState, .CurveEaseOut],
                            animations: {
                                button.layer.transform = CATransform3DIdentity
                            }, completion: nil)
                }
            }
        }
    }
    
    private func dismissActionSheet(completion: (() -> Void)? = nil) {
        self.dismissViewControllerAnimated(true, completion: completion)
        if let topButtonY = actionButtons.last?.frame.origin.y {
            let bottomPad = view.bounds.height - topButtonY
            actionButtons.enumerate().forEach { index, button in
                UIView.animateWithDuration(0.2, delay: NSTimeInterval(index) * 0.05 + 0.05,
                    options: .BeginFromCurrentState,
                    animations: {
                        button.layer.transform = CATransform3DMakeTranslation(0, bottomPad, 1)
                    }, completion: nil)
            }
        }
    }
    
    private func createSheetButton(action: FloatingAction) -> ActionButton {
        let button = ActionButton(type: .Custom)
        button.layer.cornerRadius = 4
        button.backgroundColor = itemTintColor
        button.titleLabel?.textAlignment = .Center
        button.titleLabel?.font = font
        button.setTitleColor(textColor, forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configure(action)
        button.addTarget(self, action: "didSelectItem:", forControlEvents: .TouchUpInside)
        return button
    }
    
    private dynamic func didSelectItem(button: ActionButton) {
        dismissActionSheet {
            if let action = button.action {
                button.handler?(action: action)
            }
        }
    }
    
    private func configure() {
        view.backgroundColor = .clearColor()
        modalPresentationStyle = .Custom
        transitioningDelegate = self
        
        let dimmingView = UIControl()
        dimmingView.addTarget(self, action: "handleTapDimmingView", forControlEvents: .TouchUpInside)
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimmingView)
        self.dimmingView = dimmingView
        
        view.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|-0-[dimmingView]-0-|",
                options: [],
                metrics: nil,
                views: ["dimmingView": dimmingView]
                )
                + NSLayoutConstraint.constraintsWithVisualFormat(
                    "H:|-0-[dimmingView]-0-|",
                    options: [],
                    metrics: nil,
                    views: ["dimmingView": dimmingView]
            )
        )
    }
    
    private dynamic func handleTapDimmingView() {
        dismissActionSheet()
    }
}

extension FloatingActionSheetController: UIViewControllerTransitioningDelegate {
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FloatingTransitionAnimator(dimmingView: dimmingView)
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let delay = NSTimeInterval(actionButtons.count) * 0.03
        return FloatingTransitionAnimator(dimmingView: dimmingView, delay: delay, forwardTransition: false)
    }
}

private final class FloatingTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var forwardTransition = true
    let dimmingView: UIView
    var delay: NSTimeInterval = 0
    
    init(dimmingView: UIView, delay: NSTimeInterval = 0, forwardTransition: Bool = true) {
        self.dimmingView = dimmingView
        super.init()
        self.delay = delay
        self.forwardTransition = forwardTransition
    }
    
    @objc func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }

    @objc func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let containerView = transitionContext.containerView(),
            fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
            toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
            else { return }
        let duration = transitionDuration(transitionContext)
        
        if forwardTransition {
            containerView.addSubview(toVC.view)
            UIView.animateWithDuration(duration, delay: 0,
                usingSpringWithDamping: 1, initialSpringVelocity: 0,
                options: .BeginFromCurrentState,
                animations: {
                    fromVC.view.layer.transform = CATransform3DMakeScale(0.85, 0.85, 1)
                    self.dimmingView.alpha = 0
                    self.dimmingView.alpha = 1
                }) { _ in
                    transitionContext.completeTransition(true)
            }
        } else {
            UIView.animateWithDuration(duration, delay: delay,
                usingSpringWithDamping: 1, initialSpringVelocity: 0,
                options: .BeginFromCurrentState,
                animations: {
                    toVC.view.layer.transform = CATransform3DIdentity
                    self.dimmingView.alpha = 0
                }) { _ in
                    transitionContext.completeTransition(true)
            }
        }
    }
}