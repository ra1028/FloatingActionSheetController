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
    
    // MARK: Public

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureDataSources()
    }
    
    // MARK: Private
    
    private class PaddingLabel: UILabel {
        private override func drawTextInRect(rect: CGRect) {
            let insets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
            super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
        }
    }
    
    private struct RowData {
        var title: String?
        var handler: (() -> Void)?
    }
    private struct DataSource {
        var sectionTitle: String?
        var rowDatas = [RowData]()
    }
    
    private var dataSources = [DataSource]()
    private weak var displayLabel: UILabel!
    
    private func configure() {
        title = "Examples"
        view.backgroundColor = UIColor(red:0.14, green:0.16, blue:0.2, alpha:1)
        
        let displayLabel = PaddingLabel(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
        displayLabel.backgroundColor = UIColor(red:0.93, green:0.95, blue:0.96, alpha:1)
        displayLabel.text = "Select example from below."
        displayLabel.textColor = UIColor(red:0.48, green:0.52, blue:0.58, alpha:1)
        displayLabel.font = .boldSystemFontOfSize(14)
        
        let tableView = UITableView(frame: .zero, style: .Grouped)
        tableView.tableHeaderView = displayLabel
        tableView.backgroundColor = .clearColor()
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.delaysContentTouches = false
        tableView.separatorStyle = .None
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(HeaderView.self, forHeaderFooterViewReuseIdentifier: "HeaderView")
        tableView.registerNib(UINib(nibName: "TableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "TableViewCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        self.displayLabel = displayLabel
        
        view.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|-0-[tableView]-0-|",
                options: [],
                metrics: nil,
                views: ["tableView": tableView]
                )
                + NSLayoutConstraint.constraintsWithVisualFormat(
                    "H:|-0-[tableView]-0-|",
                    options: [],
                    metrics: nil,
                    views: ["tableView": tableView]
            )
        )
    }
    
    private func configureDataSources() {
        var standardRows = [RowData]()
        standardRows.append(
            RowData(title: "2 : 1") { [weak self] in
                if let sSelf = self {
                    let group1 = FloatingActionGroup(actions:
                        (1...2).map {
                            FloatingAction(title: "Action\($0)") {
                                sSelf.display($0)
                            }
                        }
                    )
                    let group2 = FloatingActionGroup(action:
                        FloatingAction(title: "Action3") {
                            sSelf.display($0)
                        }
                    )
                    FloatingActionSheetController(actionGroup: group1, group2)
                        .present(sSelf)
                }
            }
        )
        standardRows.append(
            RowData(title: "1 : 4") { [weak self] in
                if let sSelf = self {
                    let group1 = FloatingActionGroup(action:
                        FloatingAction(title: "Action1") {
                            sSelf.display($0)
                        }
                    )
                    let group2 = FloatingActionGroup(actions:
                        (2...5).map {
                            FloatingAction(title: "Action\($0)") {
                                sSelf.display($0)
                            }
                        }
                    )
                    FloatingActionSheetController(actionGroup: group1, group2)
                        .present(sSelf)
                }
            }
        )
        standardRows.append(
            RowData(title: "1 : 3 : 1") { [weak self] in
                if let sSelf = self {
                    let group1 = FloatingActionGroup(action:
                        FloatingAction(title: "Action1") {
                            sSelf.display($0)
                        }
                    )
                    let group2 = FloatingActionGroup(actions:
                        (2...4).map {
                            FloatingAction(title: "Action\($0)") {
                                sSelf.display($0)
                            }
                        }
                    )
                    let group3 = FloatingActionGroup(action:
                        FloatingAction(title: "Action5") {
                            sSelf.display($0)
                        }
                    )
                    FloatingActionSheetController(actionGroup: group1, group2, group3)
                        .present(sSelf)
                }
            }
        )
        standardRows.append(
            RowData(title: "2 : 2 : 2") { [weak self] in
                if let sSelf = self {
                    let group1 = FloatingActionGroup(actions:
                        (1...2).map {
                            FloatingAction(title: "Action\($0)") {
                                sSelf.display($0)
                            }
                        }
                    )
                    let group2 = FloatingActionGroup(actions:
                        (3...4).map {
                            FloatingAction(title: "Action\($0)") {
                                sSelf.display($0)
                            }
                        }
                    )
                    let group3 = FloatingActionGroup(actions:
                        (5...6).map {
                            FloatingAction(title: "Action\($0)") {
                                sSelf.display($0)
                            }
                        }
                    )
                    FloatingActionSheetController(actionGroup: group1, group2, group3)
                        .present(sSelf)
                }
            }
        )
        dataSources.append(
            DataSource(sectionTitle: "Standard", rowDatas: standardRows)
        )
        
        let animationRows: [RowData] = [
            ("SlideUp", .SlideUp),
            ("SlideDown", .SlideDown),
            ("SlideLeft", .SlideLeft),
            ("SlideRight", .SlideRight),
            ("Pop", .Pop)].map { (title: String, style: FloatingActionSheetController.AnimationStyle) -> RowData in
                RowData(title: title) { [weak self] in
                    if let sSelf = self {
                        FloatingActionSheetController(actionGroups: sSelf.exampleActionGroups(), animationStyle: style)
                            .present(sSelf)
                    }
                }
        }
        dataSources.append(
            DataSource(sectionTitle: "Animation", rowDatas: animationRows)
        )
        
        let customTintRow = RowData(title: "Tint color") { [weak self] in
            if let sSelf = self {
                let actionSheet = FloatingActionSheetController(actionGroups: sSelf.exampleActionGroups())
                actionSheet.itemTintColor = UIColor(red:0.93, green:0.95, blue:0.96, alpha:1)
                actionSheet.textColor = UIColor(red:0.48, green:0.52, blue:0.58, alpha:1)
                actionSheet.present(sSelf)
            }
        }
        let customTextColorRow = RowData(title: "Text color") { [weak self] in
            if let sSelf = self {
                let actionSheet = FloatingActionSheetController(actionGroups: sSelf.exampleActionGroups())
                actionSheet.textColor = UIColor(red: 0.9, green: 0.55, blue: 0.08, alpha: 1)
                actionSheet.present(sSelf)
            }
        }
        let customFontRow = RowData(title: "Text font") { [weak self] in
            if let sSelf = self {
                let actionSheet = FloatingActionSheetController(actionGroups: sSelf.exampleActionGroups())
                actionSheet.font = .systemFontOfSize(18)
                actionSheet.present(sSelf)
            }
        }
        let dimmingColorRow = RowData(title: "Dimming color") { [weak self] in
            if let sSelf = self {
                let actionSheet = FloatingActionSheetController(actionGroups: sSelf.exampleActionGroups())
                actionSheet.dimmingColor = UIColor.whiteColor().colorWithAlphaComponent(0.7)
                actionSheet.present(sSelf)
            }
        }
        let individualCustomRow = RowData(title: "Individual custom") { [weak self] in
            if let sSelf = self {
                let actions = (1...2).map {
                    FloatingAction(title: "Action\($0)") {
                        sSelf.display($0)
                    }
                }
                let cancelAction = FloatingAction(title: "Cancel") {
                    sSelf.display($0)
                }
                cancelAction.customTintColor = UIColor(red:0.93, green:0.95, blue:0.96, alpha:1)
                cancelAction.customTextColor = UIColor(red:0.87, green:0.42, blue:0.35, alpha:1)
                FloatingActionSheetController(actionGroup: FloatingActionGroup(actions: actions))
                    .addAction(cancelAction, newGroup: true)
                    .present(sSelf)
            }
        }
        dataSources.append(
            DataSource(sectionTitle: "Custom Appearance", rowDatas: [
                customTintRow, customTextColorRow, customFontRow, dimmingColorRow, individualCustomRow
                ])
        )
    }
    
    private func display(action: FloatingAction) {
        if let title = action.title {
            displayLabel.text = "\(title) Selected."
        }
    }
    
    private func exampleActionGroups() -> [FloatingActionGroup] {
        let action1 = FloatingAction(title: "Action1") { [weak self] in
            self?.display($0)
        }
        let action2 = FloatingAction(title: "Action2") { [weak self] in
            self?.display($0)
        }
        let action3 = FloatingAction(title: "Action3") { [weak self] in
            self?.display($0)
        }
        let actionGroup1 = FloatingActionGroup(action: action1)
        let actionGroup2 = FloatingActionGroup(action: action2, action3)
        return [actionGroup1, actionGroup2]
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        dataSources[indexPath.section].rowDatas[indexPath.row].handler?()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSources.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSources[section].rowDatas.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableViewCell", forIndexPath: indexPath) as! TableViewCell
        cell.title = dataSources[indexPath.section].rowDatas[indexPath.row].title
        return cell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier("HeaderView") as! HeaderView
        view.title = dataSources[section].sectionTitle
        return view
    }
}