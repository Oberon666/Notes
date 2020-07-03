//
//  UIAlertController_extension.swift
//  Notes_2
//
//  Created by Витали Суханов on 27.05.2020.
//  Copyright © 2020 Виталий Суханов. All rights reserved.
//

import UIKit

extension UIAlertController {
    static func showTextAlert(title: String, description: String) {
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        
        let scene = UIApplication.shared.connectedScenes.first
        let window = (scene?.delegate as? SceneDelegate)?.window
        var currentVC = window?.rootViewController
        while let presentedVC = currentVC?.presentedViewController {
            currentVC = presentedVC
        }
        currentVC?.present(alert, animated: true, completion: nil)
    }
    
    static func showTextToast(title: String, description: String) {
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        
        let scene = UIApplication.shared.connectedScenes.first
        let window = (scene?.delegate as? SceneDelegate)?.window
        var currentVC = window?.rootViewController
        while let presentedVC = currentVC?.presentedViewController {
            currentVC = presentedVC
        }
        let duration: Double = 2
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
            alert.dismiss(animated: true)
        }
        currentVC?.present(alert, animated: true, completion: nil)
    }
}
