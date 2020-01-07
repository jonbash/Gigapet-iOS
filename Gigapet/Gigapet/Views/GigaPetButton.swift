//
//  GigaPetButton.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-07.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import UIKit

@IBDesignable
class GigaPetButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    private func setUp() {
        layer.backgroundColor = UIColor(named: .mainPurple)?.cgColor
        layer.cornerRadius = 5
        layer.borderWidth = 1
        layer.borderColor = UIColor.clear.cgColor
        setTitleColor(tintColor, for: .normal)
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
}
