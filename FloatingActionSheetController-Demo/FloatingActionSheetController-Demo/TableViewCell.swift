//
//  TableViewCell.swift
//  FloatingActionSheetController-Demo
//
//  Created by Ryo Aoyama on 10/28/15.
//  Copyright © 2015 Ryo Aoyama. All rights reserved.
//

import UIKit

final class TableViewCell: UITableViewCell {
    
    // MARK: Public
    
    var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = UIColor(red:0.14, green:0.16, blue:0.2, alpha:1)
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor(red:0.11, green:0.12, blue:0.15, alpha:1)
        self.selectedBackgroundView = selectedBackgroundView
    }
    
    // MARK: Private
    
    @IBOutlet private weak var titleLabel: UILabel!
}