//
//  FloatingAction.swift
//  FloatingActionSheetController
//
//  Created by Ryo Aoyama on 10/25/15.
//  Copyright © 2015 Ryo Aoyama. All rights reserved.
//

import UIKit

public final class FloatingAction {
    
    // MARK: Public
    
    public private(set) var title: String?
    public var tintColor: UIColor?
    public var textColor: UIColor?
    public var font: UIFont?
    
    public init(title: String, handleImmediately: Bool = false, handler: ((FloatingAction) -> Void)?) {
        self.title = title
        self.handleImmediately = handleImmediately
        self.handler = handler
    }
    
    // MARK: Internal
    
    private(set) var handler: ((FloatingAction) -> Void)?
    private(set) var handleImmediately = false
}
