//
//  KeyboardObserving.swift
//  Notes_2
//
//  Created by Витали Суханов on 20.05.2020.
//  Copyright © 2020 Виталий Суханов. All rights reserved.
//

import UIKit

protocol KeyboardObserving: class {
    func keyboardWillShow(withSize size: CGSize)
    func keyboardWillHide()
}

extension KeyboardObserving {
    func addKeyboardObservers(to notificationCenter: NotificationCenter) {
        let keyboardWillShowBlock: (Notification) -> () = { [weak self] notification in
            let key = UIResponder.keyboardFrameEndUserInfoKey
            guard let keyboardSizeValue = notification.userInfo?[key] as? NSValue else {
                assertionFailure()
                return
            }
            
            let keyboardSize = keyboardSizeValue.cgRectValue
            self?.keyboardWillShow(withSize: keyboardSize.size)
            assert(self != nil)
        }
        notificationCenter.addObserver(forName: UIResponder.keyboardWillShowNotification,
                                       object: nil,
                                       queue: nil,
                                       using: keyboardWillShowBlock)
        
        let keyboardWillHideBlock: (Notification) -> () = { [weak self] _ in
            self?.keyboardWillHide()
            assert(self != nil)
        }
        notificationCenter.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                       object: nil,
                                       queue: nil,
                                       using: keyboardWillHideBlock)
    }
    
    func removeKeyboardObservers(from notificationCenter: NotificationCenter) {
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
}

protocol ScrollViewKeyboardObserving: KeyboardObserving {
    var keyboardObservingScrollView: UIScrollView { get }
}

extension ScrollViewKeyboardObserving {
    func keyboardWillShow(withSize size: CGSize) {
        keyboardObservingScrollView.contentInset.bottom = size.height
    }
    
    func keyboardWillHide() {
        keyboardObservingScrollView.contentInset.bottom = 0
    }
}
