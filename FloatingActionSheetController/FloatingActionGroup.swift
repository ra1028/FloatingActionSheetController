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
        action.forEach { addAction($0) }
    }
    
    public init(actions: [FloatingAction]) {
        addActions(actions)
    }
    
    public func addAction(action: FloatingAction...) -> FloatingActionGroup {
        actions += action
        return self
    }
    
    public func addActions(actions: [FloatingAction]) -> FloatingActionGroup {
        self.actions += actions
        return self
    }
    
    // MARK: Internal
    
    private(set) var actions = [FloatingAction]()
}