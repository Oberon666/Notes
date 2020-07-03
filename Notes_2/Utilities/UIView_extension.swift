//
//  UIView_Extension.swift
//  Notes_2
//
//  Created by Витали Суханов on 18.05.2020.
//  Copyright © 2020 Виталий Суханов. All rights reserved.
//

import UIKit

extension UIView {
    func setAnchor(view: UIView, top: CGFloat = 0, bottom: CGFloat = 0, leading: CGFloat = 0, trailing: CGFloat = 0) {
        self.translatesAutoresizingMaskIntoConstraints = false
        let constrains = [self.topAnchor.constraint(equalTo: view.topAnchor, constant: top),
                          self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottom),
                          self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leading),
                          self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -trailing)
        ]
        NSLayoutConstraint.activate(constrains)
    }
}
