//
//  FloatingAction.swift
//  FloatingActionSheetController
//
//  Created by Ryo Aoyama on 10/25/15.
//  Copyright © 2015 Ryo Aoyama. All rights reserved.
//

import UIKit

public struct FloatingAction {
    
    // MARK: Public
    
    public private(set) var title: String?
    public var customTintColor: UIColor?
    public var customTextColor: UIColor?
    public var customFont: UIFont?
    
    public init(title: String, afterDismiss: Bool = false, handler: ((action :FloatingAction) -> Void)?) {
        self.title = title
        self.handler = handler
    }
    
    // MARK: Internal
    
    private(set) var handler: ((action: FloatingAction) -> Void)?
    private(set) var afterDismiss = false
}