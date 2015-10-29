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
    
    public enum AnimationStyle {
        case SlideUp
        case SlideDown
        case SlideLeft
        case SlideRight
        case Pop
    }
    
    public var animationStyle = AnimationStyle.SlideUp
    public var itemTintColor = UIColor(red:0.13, green:0.13, blue:0.17, alpha:1)
    public var font = UIFont.boldSystemFontOfSize(14)
    public var textColor = UIColor.whiteColor()
    public var dimmingColor = UIColor(white: 0, alpha: 0.7)
    
    public convenience init(animationStyle: AnimationStyle) {
        self.init(nibName: nil, bundle: nil)
        self.animationStyle = animationStyle
    }
    
    public convenience init(actionGroup: FloatingActionGroup..., animationStyle: AnimationStyle = .SlideUp) {
        self.init(nibName: nil, bundle: nil)
        self.animationStyle = animationStyle
        actionGroup.forEach { addActionGroup($0) }
    }
    
    public convenience init(actionGroups: [FloatingActionGroup], animationStyle: AnimationStyle = .SlideUp) {
        self.init(nibName: nil, bundle: nil)
        self.animationStyle = animationStyle
        addActionGroups(actionGroups)
    }
    
    public convenience init(actions: [FloatingAction], animationStyle: AnimationStyle = .SlideUp) {
        self.init(nibName: nil, bundle: nil)
        self.animationStyle = animationStyle
        addActions(actions)
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
    
    public override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .Fade
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if !isShowing {
            showActionSheet()
        }
        if originalStatusBarStyle == nil {
            originalStatusBarStyle = UIApplication.sharedApplication().statusBarStyle
        }
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }
    
    public override func viewWillDisappear(animated: Bool) {
        if let style = originalStatusBarStyle {
            UIApplication.sharedApplication().setStatusBarStyle(style, animated: true)
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
    
    public func addActionGroups(actionGroups: [FloatingActionGroup]) -> Self {
        self.actionGroups += actionGroups
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
    
    public func addActions(actions: [FloatingAction], newGroup: Bool = false) -> Self {
        if let lastGroup = actionGroups.last where !newGroup {
            lastGroup.addActions(actions)
        } else {
            let actionGroup = FloatingActionGroup(actions: actions)
            addActionGroup(actionGroup)
        }
        return self
    }
    
    // MARK: Private
    
    private class ActionButton: UIButton {
        
        private(set) var action: FloatingAction?
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
            setTitle(action.title, forState: .Normal)
            if let color = action.customTintColor {
                backgroundColor = color
            }
            if let color = action.customTextColor {
                setTitleColor(color, forState: .Normal)
            }
            if let font = action.customFont {
                titleLabel?.font = font
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
    private var originalStatusBarStyle: UIStatusBarStyle?
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
        
        if let topButton = actionButtons.last {
            let buttons: [ActionButton]
            let preTransform: CATransform3D
            let transform: CATransform3D
            let topButtonY = topButton.frame.origin.y
            assert(topButtonY > 0, "[FloatingActionSheetController] Too many action items error.")
            switch animationStyle {
            case .SlideUp:
                let bottomPad = view.bounds.height - topButtonY
                buttons = actionButtons.reverse()
                preTransform = CATransform3DMakeTranslation(0, bottomPad, 0)
                transform = CATransform3DMakeTranslation(0, -10, 0)
            case .SlideDown:
                let topPad = CGRectGetMaxY(actionButtons[0].frame)
                buttons = actionButtons
                preTransform = CATransform3DMakeTranslation(0, -topPad, 0)
                transform = CATransform3DMakeTranslation(0, 10, 0)
            case .SlideLeft:
                let rightPad = view.bounds.width - topButton.frame.origin.x
                buttons = actionButtons.reverse()
                preTransform = CATransform3DMakeTranslation(rightPad, 0, 0)
                transform = CATransform3DMakeTranslation(-10, 0, 0)
            case .SlideRight:
                let leftPad = CGRectGetMaxX(topButton.frame)
                buttons = actionButtons.reverse()
                preTransform = CATransform3DMakeTranslation(-leftPad, 0, 0)
                transform = CATransform3DMakeTranslation(10, 0, 0)
            case .Pop:
                buttons = actionButtons.reverse()
                preTransform = CATransform3DMakeScale(0, 0, 1)
                transform = CATransform3DMakeScale(1.1, 1.1, 1)
            }
            
            buttons.enumerate().forEach { index, button in
                button.layer.transform = preTransform
                UIView.animateWithDuration(0.25, delay: NSTimeInterval(index) * 0.05 + 0.05,
                    options: .BeginFromCurrentState,
                    animations: {
                        button.layer.transform = transform
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
        if let topButton = actionButtons.last {
            let buttons: [ActionButton]
            let transform: CATransform3D
            var completion: (ActionButton -> Void)?
            switch animationStyle {
            case .SlideUp:
                let bottomPad = view.bounds.height - topButton.frame.origin.y
                buttons = actionButtons
                transform = CATransform3DMakeTranslation(0, bottomPad, 0)
            case .SlideDown:
                let topPad = CGRectGetMaxY(actionButtons[0].frame)
                buttons = actionButtons.reverse()
                transform = CATransform3DMakeTranslation(0, -topPad, 0)
            case .SlideLeft:
                let leftPad = CGRectGetMaxX(topButton.frame)
                buttons = actionButtons.reverse()
                transform = CATransform3DMakeTranslation(-leftPad, 0, 0)
            case .SlideRight:
                let rightPad = view.bounds.width - topButton.frame.origin.x
                buttons = actionButtons.reverse()
                transform = CATransform3DMakeTranslation(rightPad, 0, 0)
            case .Pop:
                buttons = actionButtons
                transform = CATransform3DMakeScale(0.01, 0.01, 1) // 0.01 = Swift bug
                completion = { $0.layer.transform = CATransform3DMakeScale(0, 0, 1) }
            }
            
            buttons.enumerate().forEach { index, button in
                UIView.animateWithDuration(0.2, delay: NSTimeInterval(index) * 0.05 + 0.05,
                    options: .BeginFromCurrentState,
                    animations: {
                        button.layer.transform = transform
                    }) { _ in
                        completion?(button)
                }
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
        guard let action = button.action else { return }
        if action.handleImmediately {
            action.handler?(action: action)
        }
        dismissActionSheet {
            if !action.handleImmediately {
                action.handler?(action: action)
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