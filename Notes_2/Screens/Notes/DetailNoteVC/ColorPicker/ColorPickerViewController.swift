//
//  ColorPickerViewController.swift
//  Notes_2
//
//  Created by Витали Суханов on 19.05.2020.
//  Copyright © 2020 Виталий Суханов. All rights reserved.
//

import UIKit

class ColorPickerViewController: UIViewController {
    @IBOutlet private weak var colorMap: UIImageView!
    @IBOutlet private weak var currentColorViewOwner: UIView!
    @IBOutlet private weak var currentColorView: UIView!
    @IBOutlet private weak var currentColorText: UILabel!
    @IBOutlet private weak var brightnessSlider: UISlider!
    @IBOutlet private weak var gradientTargetView: UIView!
    @IBOutlet private weak var gradientTargetX: NSLayoutConstraint!
    @IBOutlet private weak var gradientTargetY: NSLayoutConstraint!
    
    private var didSelect: (UIColor) -> Void
    
    private var iColor = (hue: CGFloat, saturation: CGFloat, brightness:CGFloat) (0, 0, 0) {
        didSet { updateUI() }
    }
    
    private var currentColor: UIColor {
        return UIColor(hue: iColor.hue, saturation: iColor.saturation, brightness: iColor.brightness, alpha: 1.0)
    }
    
    private var currentGradientColor: UIColor {
        return UIColor(hue: iColor.hue, saturation: iColor.saturation, brightness: 1.0, alpha: 1.0)
    }
    
    private var currentLocation = CGPoint(x: 0, y: 0) {
        didSet {
            gradientTargetX.constant = currentLocation.x
            gradientTargetY.constant = currentLocation.y
        }
    }
    
    init(didSelect: @escaping (UIColor) -> Void, color: UIColor?) {
        self.didSelect = didSelect
        super.init(nibName: nil, bundle: nil)
        if let color = color {
            guard let hue = color.hue else { return }
            guard let saturation = color.saturation else { return }
            guard let brightness = color.brightness else { return }
            iColor = (hue: hue, saturation: saturation, brightness: brightness)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateUI() {
        currentColorView.backgroundColor = currentColor
        currentColorText.text = currentColor.getHexStr()
        gradientTargetView.backgroundColor = currentGradientColor
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewDidLayoutSubviews()
        let completion = { [unowned self] (_: UIViewControllerTransitionCoordinatorContext) -> Void in
            self.updateGradientTargetPosition()
            self.gradientTargetView.isHidden = false
        }
        coordinator.animate(alongsideTransition: { [unowned self] _ in
            self.gradientTargetView.isHidden = true
            }, completion: completion)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradientTargetPosition()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        setupGestureRecognizer()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateColors()
    }
    
    private func updateColors() {
        colorMap.layer.borderColor = ColorsProvider.gray.cgColor
        currentColorViewOwner.layer.borderColor = ColorsProvider.gray.cgColor
        gradientTargetView.layer.borderColor = ColorsProvider.gray.cgColor
    }
    
    private func initView() {
        updateColors()
        
        colorMap.layer.borderWidth = 0.5
        
        currentColorViewOwner.layer.borderWidth = 0.5
        currentColorViewOwner.layer.cornerRadius = 5
        
        gradientTargetView.layer.borderWidth = 0.2
        gradientTargetView.layer.cornerRadius = 18
        
        brightnessSlider.value = Float(iColor.brightness)
    }
    
    private func updateGradientTargetPosition() {
        let newLocation = CGPoint(x: iColor.hue * colorMap.frame.width, y: (1.0 - iColor.saturation)*colorMap.frame.height)
        self.tapToColorMap(location: newLocation)
    }
    
    private func setupGestureRecognizer() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(tapped))
        gesture.minimumPressDuration = 0
        colorMap.addGestureRecognizer(gesture)
        colorMap.isUserInteractionEnabled = true
    }
    
    @objc private func tapped(recognizer: UITapGestureRecognizer) {
        var location = recognizer.location(in: recognizer.view)
        let threshold: CGFloat = 30
        guard location.x > -threshold && location.y > -threshold
            && location.x < self.colorMap.frame.width + threshold
            && location.y < self.colorMap.frame.height + threshold else { return }
        
        if location.x < 0 {
            location.x = 0
        }
        if location.y < 0 {
            location.y = 0
        }
        if location.x > self.colorMap.frame.width {
            location.x = self.colorMap.frame.width
        }
        if location.y > self.colorMap.frame.height {
            location.y = self.colorMap.frame.height
        }
        self.tapToColorMap(location: location)
    }
    
    private func tapToColorMap(location: CGPoint) {
        currentLocation = location
        let hue = location.x/colorMap.frame.width
        assert(hue <= 1.0 && hue >= 0)
        let saturation = 1.0 - location.y/colorMap.frame.height
        assert(saturation <= 1.0 && saturation >= 0)
        let brightness = CGFloat(brightnessSlider.value)
        assert(brightness <= 1.0 && brightness >= 0)
        iColor = (hue: hue, saturation: saturation, brightness: brightness)
    }
    
    @IBAction private func brightnessChanged(_ sender: UISlider) {
        let brightness = CGFloat(brightnessSlider.value)
        iColor.brightness = brightness
    }
    
    @IBAction private func tapDone(_ sender: UIButton) {
        didSelect(currentColor)
        self.dismiss(animated: true, completion: nil)
    }
    
}
