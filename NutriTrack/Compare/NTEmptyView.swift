//
//  NTEmptyView.swift
//  NutriTrack
//
//  Created by Avais on 2016-04-26.
//  Copyright © 2016 Aveth. All rights reserved.
//

import UIKit

class NTEmptyView: UIView {
    
    lazy private var textLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Tap \"Add Item\" to add a food item to compare", comment: "")
        label.font = UIFont.regularFontOfSize(28.0)
        label.textAlignment = .Center
        label.numberOfLines = 0
        label.lineBreakMode = .ByWordWrapping
        return label
    }()

    override internal init(frame: CGRect) {
        super.init(frame: frame)
        self.buildView()
    }
    
    required internal init?(coder aDecoder: NSCoder) {
        fatalError("This class doesn't support NSCoding.")
    }
    
    private func buildView() {
        self.addSubview(self.textLabel)
    }
    
    override internal func updateConstraints() {
        super.updateConstraints()
        self.textLabel.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsets(top: 100.0, left: 40.0, bottom: 100.0, right: 40.0), excludingEdge: .Bottom)
    }

}