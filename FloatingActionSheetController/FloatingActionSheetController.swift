//
//  FloatingActionSheetController.swift
//  FloatingActionSheetController
//
//  Created by Ryo Aoyama on 10/25/15.
//  Copyright © 2015 Ryo Aoyama. All rights reserved.
//

import UIKit

open class FloatingActionSheetController: UIViewController, UIViewControllerTransitioningDelegate {
    
    // MARK: Public
    
    public enum AnimationStyle {
        case slideUp
        case slideDown
        case slideLeft
        case slideRight
        case pop
    }
    
    open var animationStyle = AnimationStyle.slideUp
    open var itemTintColor = UIColor(red:0.13, green:0.13, blue:0.17, alpha:1)
    open var font = UIFont.boldSystemFont(ofSize: 14)
    open var textColor = UIColor.white
    open var dimmingColor = UIColor(white: 0, alpha: 0.7)
    open var pushBackScale: CGFloat = 0.85
    
    public convenience init(animationStyle: AnimationStyle) {
        self.init(nibName: nil, bundle: nil)
        self.animationStyle = animationStyle
    }
    
    public convenience init(actionGroup: FloatingActionGroup..., animationStyle: AnimationStyle = .slideUp) {
        self.init(nibName: nil, bundle: nil)
        self.animationStyle = animationStyle
        actionGroup.forEach { add(actionGroup: $0) }
    }
    
    public convenience init(actionGroups: [FloatingActionGroup], animationStyle: AnimationStyle = .slideUp) {
        self.init(nibName: nil, bundle: nil)
        self.animationStyle = animationStyle
        add(actionGroups: actionGroups)
    }
    
    public convenience init(actions: [FloatingAction], animationStyle: AnimationStyle = .slideUp) {
        self.init(nibName: nil, bundle: nil)
        self.animationStyle = animationStyle
        add(actions: actions)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configure()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    open override var prefersStatusBarHidden: Bool {
        return UIApplication.shared.isStatusBarHidden
    }
    
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isShowing {
            showActionSheet()
        }
        if originalStatusBarStyle == nil {
            originalStatusBarStyle = UIApplication.shared.statusBarStyle
        }
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        if let style = originalStatusBarStyle {
            UIApplication.shared.setStatusBarStyle(style, animated: true)
        }
    }
    
    @discardableResult
    public func present(in inViewController: UIViewController, completion: (() -> Void)? = nil) -> Self {
        inViewController.present(self, animated: true, completion: completion)
        return self
    }
    
    @discardableResult
    public func dismiss() -> Self {
        dismissActionSheet()
        return self
    }
    
    @discardableResult
    public func add(actionGroup: FloatingActionGroup...) -> Self {
        actionGroups += actionGroup
        return self
    }
    
    @discardableResult
    public func add(actionGroups: [FloatingActionGroup]) -> Self {
        self.actionGroups += actionGroups
        return self
    }
    
    @discardableResult
    public func add(action: FloatingAction..., newGroup: Bool = false) -> Self {
        if let lastGroup = actionGroups.last, !newGroup {
            action.forEach { lastGroup.add(action: $0) }
        } else {
            let actionGroup = FloatingActionGroup()
            action.forEach { actionGroup.add(action: $0) }
            add(actionGroup: actionGroup)
        }
        return self
    }
    
    @discardableResult
    public func add(actions: [FloatingAction], newGroup: Bool = false) -> Self {
        if let lastGroup = actionGroups.last, !newGroup {
            lastGroup.add(actions: actions)
        } else {
            let actionGroup = FloatingActionGroup(actions: actions)
            add(actionGroup: actionGroup)
        }
        return self
    }
    
    // MARK: Private
    
    fileprivate class ActionButton: UIButton {
        
        fileprivate var action: FloatingAction?
        private var defaultBackgroundColor: UIColor?
        
        override fileprivate var isHighlighted: Bool {
            didSet {
                guard oldValue != isHighlighted else { return }
                if isHighlighted {
                    defaultBackgroundColor = backgroundColor
                    backgroundColor = highlightedColor(defaultBackgroundColor)
                } else {
                    backgroundColor = defaultBackgroundColor
                    defaultBackgroundColor = nil
                }
            }
        }
        
        func configure(_ action: FloatingAction) {
            self.action = action
            setTitle(action.title, for: .normal)
            
            if let color = action.tintColor {
                backgroundColor = color
            }
            if let color = action.textColor {
                setTitleColor(color, for: .normal)
            }
            if let font = action.font {
                titleLabel?.font = font
            }
        }
        
        private func highlightedColor(_ originalColor: UIColor?) -> UIColor? {
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
    fileprivate weak var dimmingView: UIControl!
    
    private func showActionSheet() {
        isShowing = true
        dimmingView.backgroundColor = dimmingColor
        
        let itemHeight: CGFloat = 50
        let itemSpacing: CGFloat = 10
        let groupSpacing: CGFloat = 30
        var previousGroupLastButton: ActionButton?
        
        actionGroups.reversed().forEach {            
            var previousButton: ActionButton?
            $0.actions.reversed().forEach {
                let button = createSheetButton($0)
                view.addSubview(button)
                var constraints = NSLayoutConstraint.constraints(
                    withVisualFormat: "H:|-(spacing)-[button]-(spacing)-|",
                    options: [],
                    metrics: ["spacing": itemSpacing],
                    views: ["button": button]
                )
                if let previousButton = previousButton {
                    constraints +=
                    NSLayoutConstraint.constraints(
                        withVisualFormat: "V:[button(height)]-spacing-[previous]",
                        options: [],
                        metrics: ["height": itemHeight,"spacing": itemSpacing],
                        views: ["button": button, "previous": previousButton]
                    )
                } else if let previousGroupLastButton = previousGroupLastButton {
                    constraints +=
                        NSLayoutConstraint.constraints(
                            withVisualFormat: "V:[button(height)]-spacing-[previous]",
                            options: [],
                            metrics: ["height": itemHeight, "spacing": groupSpacing],
                            views: ["button": button, "previous": previousGroupLastButton]
                    )
                } else {
                  if #available(iOS 11.0, *) {
                    constraints += [button.heightAnchor.constraint(equalToConstant: itemHeight),
                      button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -itemSpacing)
                    ]
                  } else {
                    constraints +=
                      NSLayoutConstraint.constraints(
                        withVisualFormat: "V:[button(height)]-spacing-|",
                        options: [],
                        metrics: ["height": itemHeight,"spacing": itemSpacing],
                        views: ["button": button]
                    )
                  }
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
            case .slideUp:
                let bottomPad = view.bounds.height - topButtonY
                buttons = actionButtons.reversed()
                preTransform = CATransform3DMakeTranslation(0, bottomPad, 0)
                transform = CATransform3DMakeTranslation(0, -10, 0)
            case .slideDown:
                let topPad = actionButtons[0].frame.maxY
                buttons = actionButtons
                preTransform = CATransform3DMakeTranslation(0, -topPad, 0)
                transform = CATransform3DMakeTranslation(0, 10, 0)
            case .slideLeft:
                let rightPad = view.bounds.width - topButton.frame.origin.x
                buttons = actionButtons.reversed()
                preTransform = CATransform3DMakeTranslation(rightPad, 0, 0)
                transform = CATransform3DMakeTranslation(-10, 0, 0)
            case .slideRight:
                let leftPad = topButton.frame.maxX
                buttons = actionButtons.reversed()
                preTransform = CATransform3DMakeTranslation(-leftPad, 0, 0)
                transform = CATransform3DMakeTranslation(10, 0, 0)
            case .pop:
                buttons = actionButtons.reversed()
                preTransform = CATransform3DMakeScale(0, 0, 1)
                transform = CATransform3DMakeScale(1.1, 1.1, 1)
            }
            
            buttons.enumerated().forEach { index, button in
                button.layer.transform = preTransform
                UIView.animate(withDuration: 0.25, delay: TimeInterval(index) * 0.05 + 0.05,
                    options: .beginFromCurrentState,
                    animations: {
                        button.layer.transform = transform
                    }) { _ in
                        UIView.animate(withDuration: 0.2, delay: 0,
                            options: [.beginFromCurrentState, .curveEaseOut],
                            animations: {
                                button.layer.transform = CATransform3DIdentity
                            }, completion: nil)
                }
            }
        }
    }
    
    private func dismissActionSheet(_ completion: (() -> Void)? = nil) {
        self.dismiss(animated: true, completion: completion)
        if let topButton = actionButtons.last {
            let buttons: [ActionButton]
            let transform: CATransform3D
            var completion: ((ActionButton) -> Void)?
            switch animationStyle {
            case .slideUp:
                let bottomPad = view.bounds.height - topButton.frame.origin.y
                buttons = actionButtons
                transform = CATransform3DMakeTranslation(0, bottomPad, 0)
            case .slideDown:
                let topPad = actionButtons[0].frame.maxY
                buttons = actionButtons.reversed()
                transform = CATransform3DMakeTranslation(0, -topPad, 0)
            case .slideLeft:
                let leftPad = topButton.frame.maxX
                buttons = actionButtons.reversed()
                transform = CATransform3DMakeTranslation(-leftPad, 0, 0)
            case .slideRight:
                let rightPad = view.bounds.width - topButton.frame.origin.x
                buttons = actionButtons.reversed()
                transform = CATransform3DMakeTranslation(rightPad, 0, 0)
            case .pop:
                buttons = actionButtons
                transform = CATransform3DMakeScale(0.01, 0.01, 1) // 0.01 = Swift bug
                completion = { $0.layer.transform = CATransform3DMakeScale(0, 0, 1) }
            }
            
            buttons.enumerated().forEach { index, button in
                UIView.animate(withDuration: 0.2, delay: TimeInterval(index) * 0.05 + 0.05,
                    options: .beginFromCurrentState,
                    animations: {
                        button.layer.transform = transform
                    }) { _ in
                        completion?(button)
                }
            }
        }
    }
    
    private func createSheetButton(_ action: FloatingAction) -> ActionButton {
        let button = ActionButton(type: .custom)
        button.layer.cornerRadius = 4
        button.backgroundColor = itemTintColor
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = font
        button.setTitleColor(textColor, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configure(action)
        button.addTarget(self, action: #selector(FloatingActionSheetController.didSelectItem(_:)), for: .touchUpInside)
        return button
    }
    
    @objc private dynamic func didSelectItem(_ button: ActionButton) {
        guard let action = button.action else { return }
        
        if action.handleImmediately {
            action.handler?(action)
        }
        dismissActionSheet {
            if !action.handleImmediately {
                action.handler?(action)
            }
        }
    }
    
    private func configure() {
        view.backgroundColor = .clear
        modalPresentationStyle = .custom
        transitioningDelegate = self
        
        let dimmingView = UIControl()
        dimmingView.addTarget(self, action: #selector(FloatingActionSheetController.handleTapDimmingView), for: .touchUpInside)
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimmingView)
        self.dimmingView = dimmingView
        
        view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[dimmingView]-0-|",
                options: [],
                metrics: nil,
                views: ["dimmingView": dimmingView]
                )
                + NSLayoutConstraint.constraints(
                    withVisualFormat: "H:|-0-[dimmingView]-0-|",
                    options: [],
                    metrics: nil,
                    views: ["dimmingView": dimmingView]
            )
        )
    }
    
    @objc private dynamic func handleTapDimmingView() {
        dismissActionSheet()
    }
  
  public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return FloatingTransitionAnimator(dimmingView: dimmingView, pushBackScale: pushBackScale)
  }
  
  public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    let delay = TimeInterval(actionButtons.count) * 0.03
    return FloatingTransitionAnimator(dimmingView: dimmingView, pushBackScale: pushBackScale, delay: delay, forwardTransition: false)
  }

}

private final class FloatingTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var forwardTransition = true
    let dimmingView: UIView
    let pushBackScale: CGFloat
    var delay: TimeInterval = 0
    
    init(dimmingView: UIView, pushBackScale: CGFloat, delay: TimeInterval = 0, forwardTransition: Bool = true) {
        self.dimmingView = dimmingView
        self.pushBackScale = pushBackScale
        super.init()
        self.delay = delay
        self.forwardTransition = forwardTransition
    }
    
    @objc func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    @objc func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else { return }
        
        let containerView = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)
        
        if forwardTransition {
            containerView.addSubview(toVC.view)
            UIView.animate(withDuration: duration, delay: 0,
                usingSpringWithDamping: 1, initialSpringVelocity: 0,
                options: .beginFromCurrentState,
                animations: {
                    fromVC.view.layer.transform = CATransform3DMakeScale(self.pushBackScale, self.pushBackScale, 1)
                    self.dimmingView.alpha = 0
                    self.dimmingView.alpha = 1
                }) { _ in
                    transitionContext.completeTransition(true)
            }
        } else {
            UIView.animate(withDuration: duration, delay: delay,
                usingSpringWithDamping: 1, initialSpringVelocity: 0,
                options: .beginFromCurrentState,
                animations: {
                    toVC.view.layer.transform = CATransform3DIdentity
                    self.dimmingView.alpha = 0
                }) { _ in
                    transitionContext.completeTransition(true)
            }
        }
    }
}
