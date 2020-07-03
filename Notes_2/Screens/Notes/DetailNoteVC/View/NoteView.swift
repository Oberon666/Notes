//
//  NoteView.swift
//  Notes_2
//
//  Created by Витали Суханов on 15.05.2020.
//  Copyright © 2020 Виталий Суханов. All rights reserved.
//

import UIKit

class NoteView: UIView {
    @IBOutlet private var contentView: UIView!
    @IBOutlet weak private var titleTextView: UITextField!
    @IBOutlet weak private var separatorView: UIView!
    @IBOutlet weak private var detailTextView: UITextView! {
        didSet{ detailTextView.delegate = self }
    }
    @IBOutlet weak private var backgroundView: UIView! {
        didSet{
            backgroundView.layer.borderWidth = 0.5
            backgroundView.layer.cornerRadius = 10
        }
    }
    
    var viewDidChange: (() -> ())?
    
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
        updateColors()
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateColors()
    }
    
    private func updateColors() {
        let color = ColorsProvider.getGrayColor(onBackground: backgroundView.backgroundColor)
        titleTextView.attributedPlaceholder = NSAttributedString(string: "Title", attributes: [NSAttributedString.Key.foregroundColor: color])
        backgroundView.layer.borderColor = ColorsProvider.gray.cgColor
        titleTextView.textColor = ColorsProvider.getBlackColor(onBackground: backgroundView.backgroundColor)
        detailTextView.textColor = ColorsProvider.getBlackColor(onBackground: backgroundView.backgroundColor)
    }
    
    var color: UIColor? {
        set(value) {
            UIView.animate(withDuration: 0.5) {
                self.backgroundView.backgroundColor = value
            }
            updateColors()
        }
        get { self.backgroundView.backgroundColor }
    }
    
    var titleText: String? {
        set(value) { titleTextView.text = value }
        get { titleTextView.text }
    }
    
    var detailText: String {
        set(value) { detailTextView.text = value }
        get { detailTextView.text }
    }
}

extension NoteView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        DispatchQueue.main.async {
            self.viewDidChange?()
        }
    }
}
