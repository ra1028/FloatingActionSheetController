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
    }
    
    @IBAction private dynamic func handleShowButton(sender: UIButton) {
        let action1 = FloatingAction(title: "Action1") {
            print($0.title)
        }
        let action2 = FloatingAction(title: "Action2") {
            print($0.title)
        }
        let action3 = FloatingAction(title: "Action3") {
            print($0.title)
        }
        let action4 = FloatingAction(title: "Action3") {
            print($0.title)
        }
        let action5 = FloatingAction(title: "Action3") {
            print($0.title)
        }
        let action6 = FloatingAction(title: "Action3") {
            print($0.title)
        }
        let actionGroup1 = FloatingActionGroup(action: action1, action2)
        let actionGroup2 = FloatingActionGroup(action: action3, action4, action5, action6)
        FloatingActionSheetController(actionGroup: actionGroup1, actionGroup2)
            .present(self)
    }
}

