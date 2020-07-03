//
//  ColorsProvider.swift
//  Notes_2
//
//  Created by Витали Суханов on 19.05.2020.
//  Copyright © 2020 Виталий Суханов. All rights reserved.
//

import UIKit

class ColorsProvider {
    private init() {}
    
    static private func getColor(light: UIColor, dark: UIColor) -> UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return dark
                } else {
                    return light
                }
            }
        } else {
            return light
        }
    }
    
    static var black: UIColor { getColor(light: .black, dark: .white) }
    static var gray: UIColor { getColor(light: .lightGray, dark: .gray) }
    static var grayInverted: UIColor { getColor(light: .gray, dark: .lightGray) }
    
    static private func isLightBackground(_ background: UIColor?) -> Bool {
        if let brightness = background?.brightness, brightness < 0.5 {
            return false
        }
        return true
    }
    
    static func getBlackColor(onBackground background: UIColor?) -> UIColor {
        return isLightBackground(background) ? .black : .white
    }
    
    static func getGrayColor(onBackground background: UIColor?) -> UIColor {
        return isLightBackground(background) ? .gray : .lightGray
    }
}
