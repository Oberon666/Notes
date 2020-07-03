//
//  SelectableColorButton.swift
//  Notes_2
//
//  Created by Витали Суханов on 18.05.2020.
//  Copyright © 2020 Виталий Суханов. All rights reserved.
//

import UIKit

class SelectableColorButton: UIButton {
    var tagged = false {
        didSet { setNeedsDisplay() }
    }
    
    private let scaleRadius: CGFloat = 0.3
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if tagged {
            drawTag()
        }
    }
    
    private func drawTag() {
        let radius: CGFloat = bounds.height*scaleRadius
        let center: CGPoint = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let path = UIBezierPath()
        path.lineWidth = 6
        UIColor.gray.setStroke()
        var angle = CGFloat.pi*7/6
        path.move(to: CGPoint(x: center.x + radius*CGFloat(cos(angle)), y: center.y - radius*CGFloat(sin(angle))))
        path.addLine(to: CGPoint(x: center.x, y: center.y + radius)) // 3/2 * pi
        angle = CGFloat.pi/6
        path.addLine(to: CGPoint(x: center.x + radius*CGFloat(cos(angle)), y: center.y - radius*CGFloat(sin(angle)))
        )
        path.stroke()
    }
}
