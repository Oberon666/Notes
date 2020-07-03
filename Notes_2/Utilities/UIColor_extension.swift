//
//  UIColor_Extension.swift
//  Notes_2
//
//  Created by Витали Суханов on 15.05.2020.
//  Copyright © 2020 Виталий Суханов. All rights reserved.
//

import UIKit

extension UIColor {
    func getHexStr() -> String {
        return String(format: "#%0.6X", self.rgbHex)
    }
    
    private var rgbHex: UInt32 {
        guard var com = self.cgColor.components else { return 0 }
        com = com.count == 4 ? com : [com[0], com[0], com[0], com[1]]
        let r: UInt32 = UInt32(com[0]*255)
        let g: UInt32 = UInt32(com[1]*255)
        let b: UInt32 = UInt32(com[2]*255)
        return (r << 16) + (g << 8) + b
    }
    
    var hue: CGFloat? {
        var h: CGFloat = 0
        guard self.getHue(&h, saturation: nil, brightness: nil, alpha: nil) == true else {
            return nil
        }
        return h
    }
    
    var saturation: CGFloat? {
        var s: CGFloat = 0
        guard self.getHue(nil, saturation: &s, brightness: nil, alpha: nil) == true else {
            return nil
        }
        return s
    }
    
    var brightness: CGFloat? {
        var b: CGFloat = 0
        guard self.getHue(nil, saturation: nil, brightness: &b, alpha: nil) else {
            return nil
        }
        return b
    }
}
