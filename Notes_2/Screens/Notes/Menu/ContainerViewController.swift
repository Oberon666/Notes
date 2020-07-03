//
//  ContainerController.swift
//  Notes_2
//
//  Created by Витали Суханов on 05.06.2020.
//  Copyright © 2020 Виталий Суханов. All rights reserved.
//

import UIKit

protocol ToggleMenuDelegate: AnyObject {
    func handleToggleMenu()
}

protocol ToggleMenu: AnyObject {
    var delegate: ToggleMenuDelegate? { get set}
}

class ContainerViewController: UIViewController {
    var menuVC: UIViewController!
    weak var contentVC: UIViewController!
    weak var toggleMenu: ToggleMenu!
    var isMenuExpand = false
    private let menuWidth: CGFloat = 0.8
    
    init(contentVC: UIViewController, toggleMenu: ToggleMenu) {
        self.contentVC = contentVC
        self.toggleMenu = toggleMenu
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHomeController()
        configureMenuController()
    }
    
    override func viewDidLayoutSubviews() {
        menuVC.view.frame.size.width = contentVC.view.frame.width * self.menuWidth
        updateUI(expand: self.isMenuExpand)
    }
    
    private func configureHomeController() {
        toggleMenu.delegate = self
        view.addSubview(contentVC.view)
        contentVC.view.setAnchor(view: view)
        addChild(contentVC)
        contentVC.didMove(toParent: self)
    }
    
    private func configureMenuController() {
        if menuVC == nil {
            menuVC = MenuViewController()
            view.addSubview(menuVC.view)
            menuVC.view.frame.size.width = contentVC.view.frame.width * self.menuWidth
            menuVC.view.frame.origin.x = -contentVC.view.frame.width
            addChild(menuVC)
            menuVC.didMove(toParent: self)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [unowned self] _ in
            self.menuVC.view.frame.size.width = self.contentVC.view.frame.width * self.menuWidth
            self.updateUI(expand: self.isMenuExpand)
            }, completion: nil)
    }
    
    private func updateUI(expand: Bool) {
        if expand {
            self.contentVC.view.frame.origin.x = self.contentVC.view.frame.width * self.menuWidth
            navigationController?.view.frame.origin.x = self.contentVC.view.frame.width * self.menuWidth
            self.menuVC.view.frame.origin.x = 0
        } else {
            self.contentVC.view.frame.origin.x = 0
            self.menuVC.view.frame.origin.x = -self.menuVC.view.frame.width
        }
    }
    
    private func toggleMenu(expand: Bool) {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.updateUI(expand: expand)
        }, completion: nil)
    }
}

// MARK: MenuControllerDelegate
extension ContainerViewController: ToggleMenuDelegate {
    func handleToggleMenu() {
        isMenuExpand = !isMenuExpand
        toggleMenu(expand: isMenuExpand)
    }
}
