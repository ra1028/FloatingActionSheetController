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

