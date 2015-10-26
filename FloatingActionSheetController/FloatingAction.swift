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
    public private(set) var attributedTitle: NSAttributedString?
    
    public init(title: String, handler: ((action :FloatingAction) -> Void)?) {
        self.title = title
        self.handler = handler
    }
    
    public init(attributedTitle: NSAttributedString, handler: ((action :FloatingAction) -> Void)?) {
        self.attributedTitle = attributedTitle
        self.handler = handler
    }
    
    // MARK: Internal
    
    private(set) var handler: ((action: FloatingAction) -> Void)?
}