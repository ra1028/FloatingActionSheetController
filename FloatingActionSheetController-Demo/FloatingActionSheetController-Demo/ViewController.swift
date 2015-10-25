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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("aaaaaaaa")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        print("uuuuuu")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
//        let actionSheet = UIAlertController(title: "aaaa", message: "aaaaa", preferredStyle: .ActionSheet)
//        (0...3).forEach {
//            let action = UIAlertAction(title: "a\($0)", style: .Default, handler: nil)
//            actionSheet.addAction(action)
//        }
//        let des = UIAlertAction(title: "des", style: UIAlertActionStyle.Destructive, handler: nil)
//        actionSheet.addAction(des)
//        let cancel1 = UIAlertAction(title: "c1", style: .Cancel, handler: nil)
//        actionSheet.addAction(cancel1)
//        presentViewController(actionSheet, animated: true, completion: nil)
        
        let action1 = FloatingAction(title: "Action1") {
            print($0.title)
        }
        let action2 = FloatingAction(title: "Action2") {
            print($0.title)
        }
        let actionGroup1 = FloatingActionGroup(action: action1, action2)
        let actionSheet = FloatingActionSheetController(actionGroup: actionGroup1)
        presentViewController(actionSheet, animated: true, completion: nil)
    }
}

