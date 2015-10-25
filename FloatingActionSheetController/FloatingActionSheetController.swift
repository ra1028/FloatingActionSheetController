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
    public var itemHighlightedColor = UIColor(red:0.09, green:0.1, blue:0.13, alpha:1)
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
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if !isShowing {
            showActionSheet()
        }
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
        
        var defaultBackgroudColor = UIColor(red:0.13, green:0.13, blue:0.17, alpha:1)
        var highlightedBackgroundColor = UIColor(red:0.09, green:0.1, blue:0.13, alpha:1)
        private(set) var action: FloatingAction?
        private var handler: ((action: FloatingAction) -> Void)?
        
        override var highlighted: Bool {
            didSet {
                backgroundColor = highlighted ? highlightedBackgroundColor : defaultBackgroudColor
            }
        }
        
        func configure(action: FloatingAction) {
            self.action = action
            handler = action.handler
            setTitle(action.title, forState: .Normal)
            setAttributedTitle(action.attributedTitle, forState: .Normal)
        }
    }
    
    private var actionGroups = [FloatingActionGroup]()
    private var isShowing = false
    
    private func showActionSheet() {
        isShowing = true
        view.backgroundColor = dimmingColor
        
        let itemHeight: CGFloat = 50
        let itemSpacing: CGFloat = 8
        let groupSpacing: CGFloat = 25
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
        dismissViewControllerAnimated(true) {
            if let action = button.action {
                button.handler?(action: action)
            }
        }
    }
    
    private func configure() {
        modalPresentationStyle = .Custom
        transitioningDelegate = self
        
        let controlView = UIControl()
        controlView.addTarget(self, action: "handleTapDimmingView", forControlEvents: .TouchUpInside)
        controlView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlView)
        
        view.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|-0-[controlView]-0-|",
                options: [],
                metrics: nil,
                views: ["controlView": controlView]
                )
                + NSLayoutConstraint.constraintsWithVisualFormat(
                    "H:|-0-[controlView]-0-|",
                    options: [],
                    metrics: nil,
                    views: ["controlView": controlView]
            )
        )
    }
    
    private dynamic func handleTapDimmingView() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension FloatingActionSheetController: UIViewControllerTransitioningDelegate {
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
}