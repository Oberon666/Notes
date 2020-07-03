//
//  ColorChoser.swift
//  Notes_2
//
//  Created by Витали Суханов on 18.05.2020.
//  Copyright © 2020 Виталий Суханов. All rights reserved.
//

import UIKit

class ColorChooser: UIView {
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var colorSquares: [SelectableColorButton]!
    @IBOutlet weak private var imageColorPicker: UIImageView!
    
    private let colours: [UIColor] = [#colorLiteral(red: 1, green: 0.9239934339, blue: 0.2311545392, alpha: 1), #colorLiteral(red: 0.6649489889, green: 0.938453756, blue: 0.3334475025, alpha: 1), #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1), .clear]
    
    var showColorPickerViewController: ( (@escaping (UIColor) -> (), UIColor? ) -> ())?
    var onSetColor: ((UIColor) -> ())?
    
    @IBAction private func tapToColorButton(_ sender: SelectableColorButton) {
        guard let i = colorSquares.firstIndex(of: sender) else {
            assertionFailure()
            return
        }

        if i == colorSquares.count - 1 {
            showColorPickerVC()
            return
        }
        currentColor = colours[i]
    }
    
    private func setupTagged() {
        var tagged = true
        for i in 0..<colours.count - 1 {
            let isTagged = colours[i] == currentColor
            colorSquares[i].tagged = isTagged
            tagged = tagged && !isTagged
        }
        colorSquares.last?.tagged = tagged
    }
    
    private func showColorPickerVC() {
        let didSelect: (UIColor) -> () = { color in
            self.currentColor = color
        }
        showColorPickerViewController?(didSelect, currentColor)
    }
    
    var currentColor: UIColor?{
        didSet {
            if let value = currentColor {
                onSetColor?(value)
                setupTagged()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        setupNib()
        setupView()
        setupColorButtons()
        
        currentColor = colours[0]
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateColors()
    }
    
    private func updateColors() {
        imageColorPicker.layer.borderColor = ColorsProvider.gray.cgColor
        for i in 0..<colours.count {
            colorSquares[i].layer.borderColor = ColorsProvider.gray.cgColor
        }
    }
    
    private func setupColorButtons() {
        updateColors()
        for (i, color) in colours.enumerated() {
            colorSquares[i].clipsToBounds = true
            colorSquares[i].backgroundColor = color
            colorSquares[i].layer.cornerRadius = 25
            colorSquares[i].layer.borderWidth = 0.5
        }
        imageColorPicker.layer.cornerRadius = 25
        imageColorPicker.layer.borderWidth = 0.5
    }
    
    private func setupNib() {
        let name = String(describing: type(of: self))
        let nib = UINib(nibName: name, bundle: .main)
        nib.instantiate(withOwner: self, options: nil)
    }
    
    private func setupView() {
        addSubview(contentView)
        contentView.setAnchor(view: self)
    }
}
