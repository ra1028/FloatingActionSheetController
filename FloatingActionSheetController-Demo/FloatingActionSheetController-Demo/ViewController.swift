//
//  ViewController.swift
//  FloatingActionSheetController-Demo
//
//  Created by Ryo Aoyama on 10/25/15.
//  Copyright © 2015 Ryo Aoyama. All rights reserved.
//

import UIKit
import FloatingActionSheetController

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure() {
        title = "Examples"
        view.backgroundColor = UIColor(red:0.14, green:0.16, blue:0.2, alpha:1)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        let actions1 = (0...1).map {
            FloatingAction(title: "Action\($0)") {
                print($0.title)
            }
        }
        let actions2 = (2...5).map {
            FloatingAction(title: "Action\($0)") {
                print($0.title)
            }
        }
        let actionGroup1 = FloatingActionGroup(actions: actions1)
        let actionGroup2 = FloatingActionGroup(actions: actions2)
        FloatingActionSheetController(actionGroup: actionGroup1, actionGroup2)
            .present(self)
    }
}

