//
//  DateTimePicker.swift
//  Notes_2
//
//  Created by Витали Суханов on 18.05.2020.
//  Copyright © 2020 Виталий Суханов. All rights reserved.
//

import UIKit

class DateTimePicker: UIView {
    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var dateSwitcher: UISwitch!
    @IBOutlet private weak var dateText: UITextField!
    
    @IBAction func dateSwitcherChanged(_ sender: UISwitch) {
        valueChangedAction?(sender.isOn)
        dateText.isEnabled = sender.isOn
        if sender.isOn {
            dateText.becomeFirstResponder()
        } else {
            dateText.resignFirstResponder()
        }
    }
    
    private let datePicker = UIDatePicker()
    
    var date: Date {
        set(value) {
            datePicker.date = value
            setCurrentDate()
        }
        get { datePicker.date}
    }
    
    var isOn: Bool {
        set(value) {
            DispatchQueue.main.async {
                self.dateSwitcher.isOn = value
                self.dateText.isEnabled = value
            }
        }
        get { dateSwitcher.isOn }
    }
    
    var valueChangedAction: ((Bool) -> ())?
    
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
        setupDatePicker()
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
    
    private func setupDatePicker() {
        datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self, action: #selector(setCurrentDate), for: .valueChanged)
        dateText.inputView = datePicker
        setCurrentDate()
    }
    
    @objc
    private func setCurrentDate() {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        dateText.text = formatter.string(from: datePicker.date)
    }
}
