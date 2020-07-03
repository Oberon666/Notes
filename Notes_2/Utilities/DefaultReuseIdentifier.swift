//
//  DefaultReuseIdentifier.swift
//  Notes_2
//
//  Created by Витали Суханов on 22.05.2020.
//  Copyright © 2020 Виталий Суханов. All rights reserved.
//

import UIKit

protocol ReusableView: class {
    static var defaultReuseIdentifier: String { get }
}

extension ReusableView where Self: UIView {
    static var defaultReuseIdentifier: String {
        return NSStringFromClass(self)
    }
}
