//
//  FloatingActionGroup.swift
//  FloatingActionSheetController
//
//  Created by Ryo Aoyama on 10/25/15.
//  Copyright © 2015 Ryo Aoyama. All rights reserved.
//

import UIKit

public final class FloatingActionGroup {
    
    // MARK: Public
    
    public init() {}
    
    public init(action: FloatingAction...) {
        action.forEach { add(action: $0) }
    }
    
    public init(actions: [FloatingAction]) {
        add(actions: actions)
    }
    
    @discardableResult
    public func add(action: FloatingAction...) -> FloatingActionGroup {
        actions += action
        return self
    }
    
    @discardableResult
    public func add(actions: [FloatingAction]) -> FloatingActionGroup {
        self.actions += actions
        return self
    }
    
    // MARK: Internal
    
    private(set) var actions = [FloatingAction]()
}
