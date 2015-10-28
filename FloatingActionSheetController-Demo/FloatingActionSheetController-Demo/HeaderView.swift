//
//  HeaderView.swift
//  FloatingActionSheetController-Demo
//
//  Created by Ryo Aoyama on 10/28/15.
//  Copyright © 2015 Ryo Aoyama. All rights reserved.
//

import UIKit

final class HeaderView: UITableViewHeaderFooterView {
    
    // MARK: Public
    
    var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private
    
    private weak var titleLabel: UILabel!
    
    private func configure() {
        contentView.backgroundColor = UIColor(red:0.11, green:0.12, blue:0.15, alpha:1)
        
        let titleLabel = UILabel()
        titleLabel.textAlignment = .Center
        titleLabel.textColor = UIColor(white: 1, alpha: 0.8)
        titleLabel.font = UIFont.systemFontOfSize(16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        self.titleLabel = titleLabel
        
        contentView.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|-0-[label]-0-|",
                options: [],
                metrics: nil,
                views: ["label": titleLabel]
                )
                + NSLayoutConstraint.constraintsWithVisualFormat(
                    "H:|-0-[label]-0-|",
                    options: [],
                    metrics: nil,
                    views: ["label": titleLabel]
            )
        )
    }
}