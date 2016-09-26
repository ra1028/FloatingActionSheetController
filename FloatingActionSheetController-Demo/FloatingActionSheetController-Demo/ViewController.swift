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
    
    fileprivate class PaddingLabel: UILabel {
        fileprivate override func drawText(in rect: CGRect) {
            let insets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
            super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
        }
    }
    
    fileprivate struct RowData {
        var title: String?
        var handler: (() -> Void)?
    }
    fileprivate struct DataSource {
        var sectionTitle: String?
        var rowDatas = [RowData]()
    }
    
    fileprivate var dataSources = [DataSource]()
    fileprivate weak var displayLabel: UILabel!
    
    fileprivate func configure() {
        title = "Examples"
        view.backgroundColor = UIColor(red:0.14, green:0.16, blue:0.2, alpha:1)
        
        let displayLabel = PaddingLabel(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
        displayLabel.backgroundColor = UIColor(red:0.93, green:0.95, blue:0.96, alpha:1)
        displayLabel.text = "Select example from below."
        displayLabel.textColor = UIColor(red:0.48, green:0.52, blue:0.58, alpha:1)
        displayLabel.font = .boldSystemFont(ofSize: 14)
        
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.tableHeaderView = displayLabel
        tableView.backgroundColor = .clear
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.delaysContentTouches = false
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HeaderView.self, forHeaderFooterViewReuseIdentifier: "HeaderView")
        tableView.register(UINib(nibName: "TableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "TableViewCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        self.displayLabel = displayLabel
        
        view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[tableView]-0-|",
                options: [],
                metrics: nil,
                views: ["tableView": tableView]
                )
                + NSLayoutConstraint.constraints(
                    withVisualFormat: "H:|-0-[tableView]-0-|",
                    options: [],
                    metrics: nil,
                    views: ["tableView": tableView]
            )
        )
    }
    
    fileprivate func configureDataSources() {
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
                        .present(in: sSelf)
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
                        .present(in: sSelf)
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
                        .present(in: sSelf)
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
                        .present(in: sSelf)
                }
            }
        )
        dataSources.append(
            DataSource(sectionTitle: "Standard", rowDatas: standardRows)
        )
        
        typealias Component = (String, FloatingActionSheetController.AnimationStyle)
        let components: [Component] = [
            ("SlideUp", .slideUp),
            ("SlideDown", .slideDown),
            ("SlideLeft", .slideLeft),
            ("SlideRight", .slideRight),
            ("Pop", .pop)
        ]
        
        let animationRows: [RowData] = components.map { title, style in
            RowData(title: title) { [weak self] in
                if let sSelf = self {
                    let vc = FloatingActionSheetController(
                        actionGroups: sSelf.exampleActionGroups(),
                        animationStyle: style
                    )
                    vc.present(in: sSelf)
                }
            }
        }
        
        dataSources.append(
            DataSource(sectionTitle: "Animation", rowDatas: animationRows)
        )
        
        let tintRow = RowData(title: "Tint color") { [weak self] in
            if let sSelf = self {
                let actionSheet = FloatingActionSheetController(actionGroups: sSelf.exampleActionGroups())
                actionSheet.itemTintColor = UIColor(red:0.93, green:0.95, blue:0.96, alpha:1)
                actionSheet.textColor = UIColor(red:0.48, green:0.52, blue:0.58, alpha:1)
                actionSheet.present(in: sSelf)
            }
        }
        let textColorRow = RowData(title: "Text color") { [weak self] in
            if let sSelf = self {
                let actionSheet = FloatingActionSheetController(actionGroups: sSelf.exampleActionGroups())
                actionSheet.textColor = UIColor(red: 0.9, green: 0.55, blue: 0.08, alpha: 1)
                actionSheet.present(in: sSelf)
            }
        }
        let fontRow = RowData(title: "Text font") { [weak self] in
            if let sSelf = self {
                let actionSheet = FloatingActionSheetController(actionGroups: sSelf.exampleActionGroups())
                actionSheet.font = .systemFont(ofSize: 18)
                actionSheet.present(in: sSelf)
            }
        }
        let dimmingColorRow = RowData(title: "Dimming color") { [weak self] in
            if let sSelf = self {
                let actionSheet = FloatingActionSheetController(actionGroups: sSelf.exampleActionGroups())
                actionSheet.dimmingColor = UIColor.white.withAlphaComponent(0.7)
                actionSheet.present(in: sSelf)
            }
        }
        let pushBackScaleRow = RowData(title: "Push back scale") { [weak self] in
            if let sSelf = self {
                let actionSheet = FloatingActionSheetController(actionGroups: sSelf.exampleActionGroups())
                actionSheet.pushBackScale = 0.7
                actionSheet.present(in: sSelf)
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
                cancelAction.tintColor = UIColor(red:0.93, green:0.95, blue:0.96, alpha:1)
                cancelAction.textColor = UIColor(red:0.87, green:0.42, blue:0.35, alpha:1)
                FloatingActionSheetController(actionGroup: .init(actions: actions))
                    .add(action: cancelAction, newGroup: true)
                    .present(in: sSelf)
            }
        }
        dataSources.append(
            DataSource(
                sectionTitle: "Custom Appearance",
                rowDatas: [
                    tintRow,
                    textColorRow,
                    fontRow,
                    dimmingColorRow,
                    pushBackScaleRow,
                    individualCustomRow
                ]
            )
        )
    }
    
    fileprivate func display(_ action: FloatingAction) {
        if let title = action.title {
            displayLabel.text = "\(title) Selected."
        }
    }
    
    fileprivate func exampleActionGroups() -> [FloatingActionGroup] {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dataSources[(indexPath as NSIndexPath).section].rowDatas[(indexPath as NSIndexPath).row].handler?()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSources.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSources[section].rowDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        cell.title = dataSources[(indexPath as NSIndexPath).section].rowDatas[(indexPath as NSIndexPath).row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderView") as! HeaderView
        view.title = dataSources[section].sectionTitle
        return view
    }
}
