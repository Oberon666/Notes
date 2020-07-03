//
//  MenuController.swift
//  Notes_2
//
//  Created by Витали Суханов on 05.06.2020.
//  Copyright © 2020 Виталий Суханов. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    // MARK: Theme
    private lazy var segmentController: UISegmentedControl = {
        let segmentController = UISegmentedControl()
        segmentController.insertSegment(withTitle: "Auto", at: 0, animated: false)
        segmentController.insertSegment(withTitle: "Light", at: 1, animated: false)
        segmentController.insertSegment(withTitle: "Dark", at: 2, animated: false)
        let defaultValue = UserDefaults.standard.integer(forKey: "settings_theme")
        segmentController.selectedSegmentIndex = defaultValue
        changeTheme(segmentController)
        segmentController.addTarget(self, action: #selector(changeTheme), for: .valueChanged)
        return segmentController
    }()
    
    @objc
    private func changeTheme(_ sender: UISegmentedControl) {
        let scene = UIApplication.shared.connectedScenes.first
        let window = (scene?.delegate as? SceneDelegate)?.window
        let modeIndex = sender.selectedSegmentIndex
        switch modeIndex {
        case 0: window?.overrideUserInterfaceStyle = .unspecified
        case 1: window?.overrideUserInterfaceStyle = .light
        case 2: window?.overrideUserInterfaceStyle = .dark
        default:
            assertionFailure()
        }
        UserDefaults.standard.set(modeIndex, forKey: "settings_theme")
    }
    
    // MARK: GithubGist
    private lazy var gistSwitch: UIView = {
        let useGistContainer = UIView()
        let useGistText = UILabel()
        useGistText.text = "Use GitHub gist:"
        let gistSwitch = UISwitch()
        gistSwitch.addTarget(self, action: #selector(handleGistSwitch), for: .valueChanged)
        gistSwitch.isOn = AppContainer.github.isEnabled
        useGistContainer.addSubview(useGistText)
        useGistContainer.addSubview(gistSwitch)
        
        useGistText.translatesAutoresizingMaskIntoConstraints = false
        useGistText.leadingAnchor.constraint(equalTo: useGistContainer.leadingAnchor).isActive = true
        useGistText.topAnchor.constraint(equalTo: useGistContainer.topAnchor).isActive = true
        useGistText.bottomAnchor.constraint(equalTo: useGistContainer.bottomAnchor).isActive = true
        
        gistSwitch.translatesAutoresizingMaskIntoConstraints = false
        gistSwitch.trailingAnchor.constraint(equalTo: useGistContainer.trailingAnchor).isActive = true
        gistSwitch.topAnchor.constraint(equalTo: useGistContainer.topAnchor).isActive = true
        gistSwitch.bottomAnchor.constraint(equalTo: useGistContainer.bottomAnchor).isActive = true
        gistSwitch.leadingAnchor.constraint(equalTo: useGistText.trailingAnchor).isActive = true
        return useGistContainer
    }()
    
    @objc
    private func handleGistSwitch(_ sender: UISwitch) {
        if sender.isOn {
            AppContainer.github.getAuthGithub(context: self) { (error) in
                DispatchQueue.main.async {
                    sender.isOn = error == nil
                    AppContainer.github.isEnabled = error == nil
                }
            }
        } else {
            AppContainer.github.isEnabled = false
        }
    }
    
    private lazy var backupToGist: UIButton = {
        let button = UIButton()
        button.setTitle("Upload notes to gist", for: .normal)
        button.setTitleColor(ColorsProvider.black, for: .normal)
        button.setTitleColor(.systemBlue, for: .highlighted)
        button.addTarget(self, action: #selector(handleBackupToGist), for: .touchUpInside)
        return button
    }()
    
    @objc
    private func handleBackupToGist(_ sender: UIButton) {
        guard AppContainer.github.isEnabled else {
            UIAlertController.showTextAlert(title: "", description: "Need to enable the use of GitHub Gist")
            return
        }
        
        activity.startAnimating()
        guard AppContainer.github.isEnabled else { return }
        AppContainer.github.uploadNotesToGist { success in
            DispatchQueue.main.async {
                self.activity.stopAnimating()
                UIAlertController.showTextToast(title: "Upload notes to gist", description: success ? "success" : "error")
            }
        }
    }
    
    private lazy var loadGistBackup: UIButton = {
        let button = UIButton()
        button.setTitle("Download notes from gist", for: .normal)
        button.setTitleColor(ColorsProvider.black, for: .normal)
        button.setTitleColor(.systemBlue, for: .highlighted)
        button.addTarget(self, action: #selector(handleLoadBackup), for: .touchUpInside)
        return button
    }()
    
    @objc
    private func handleLoadBackup(_ sender: UIButton) {
        guard AppContainer.github.isEnabled else {
            UIAlertController.showTextAlert(title: "", description: "Need to enable the use of GitHub Gist")
            return
        }
        
        activity.startAnimating()
        AppContainer.coreData.deleteAllObject()
        AppContainer.github.downloadNotesFromGist { success in
            DispatchQueue.main.async {
                self.activity.stopAnimating()
                UIAlertController.showTextToast(title: "Download notes from gist", description: success ? "success" : "error")
            }
        }
    }
    
    // MARK: Debug
    private lazy var clearNoteButton: UIButton = {
        let button = UIButton()
        button.setTitle("Clear all notes", for: .normal)
        button.setTitleColor(ColorsProvider.black, for: .normal)
        button.setTitleColor(.systemBlue, for: .highlighted)
        button.addTarget(self, action: #selector(handleClearNoteAction), for: .touchUpInside)
        return button
    }()
    
    @objc
    private func handleClearNoteAction(_ sender: UIButton) {
        AppContainer.coreData.deleteAllObject()
    }
    
    private lazy var AddExampleNotesButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add example notes", for: .normal)
        button.setTitleColor(ColorsProvider.black, for: .normal)
        button.setTitleColor(.systemBlue, for: .highlighted)
        button.addTarget(self, action: #selector(handleAddExampleNoteAction), for: .touchUpInside)
        return button
    }()
    
    @objc
    private func handleAddExampleNoteAction(_ sender: UIButton) {
        guard let patchToFile = Bundle.main.path(forResource: "ExampleNotes", ofType: "plist"),
            let dataArray = NSArray(contentsOfFile: patchToFile) else { return }
        
        let getColor: ([String: Int]) -> UIColor = { (colorDict) -> UIColor in
            guard let red = colorDict["red"], let green = colorDict["green"], let blue = colorDict["blue"] else {
                assertionFailure()
                return UIColor()
            }
            return UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: 1.0)
        }
        
        for rawObject in dataArray {
            AppContainer.coreData.createNewObject { note in
                guard let object = rawObject as? [String: AnyObject] else {
                    assertionFailure()
                    return
                }
                if let title = object["title"] as? String {
                    note.title = title
                }
                if let description = object["description"] as? String {
                    note.detailText = description
                }
                if let important = object["important"] as? Int {
                    note.importance = Int16(important)
                }
                if let isNotification = object["isNotification"] as? Bool,
                    isNotification,
                    let notification = object["notification"] as? Date
                {
                    note.notificationDate = notification
                }
                if let favorite = object["favorite"] as? Bool {
                    note.favorite = favorite
                }
                if let color = object["color"] as? [String: Int] {
                    note.backgroundColor = getColor(color)
                }
                
                if let createDate = object["createDate"] as? Date {
                    note.createDate = createDate
                }
                note.uuid = UUID()
            }
        }
    }
    
    // MARK: tableView
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(MenuViewController.self))
        tableView.separatorStyle = .none
        tableView.backgroundColor = defaultBackgroundColor
        return tableView
    }()
    
    var viewContainer = [UIView]()
    let defaultBackgroundColor = UIColor.systemGray5
    let headColor = UIColor.systemGray4
    let activity = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableContent()
        setupTableView()
        
        view.addSubview(activity)
        activity.setAnchor(view: view)
        activity.hidesWhenStopped = true
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.setAnchor(view: view)
    }
    
    private func setupTableContent() {
        let titleSettings = UILabel()
        titleSettings.text = "Settings"
        titleSettings.backgroundColor = headColor
        titleSettings.textAlignment = .center
        viewContainer.append(titleSettings)
        
        let themeText = UILabel()
        themeText.text = "Theme:"
        viewContainer.append(themeText)
        viewContainer.append(segmentController)

        viewContainer.append(gistSwitch)
        viewContainer.append(backupToGist)
        viewContainer.append(loadGistBackup)
        
        let titleDebug = UILabel()
        titleDebug.text = "Debug:"
        titleDebug.backgroundColor = headColor
        titleDebug.textAlignment = .center
        viewContainer.append(titleDebug)
        
        viewContainer.append(clearNoteButton)
        viewContainer.append(AddExampleNotesButton)
    }
}

// MARK: UITableViewDataSource
extension MenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewContainer.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        let newView = viewContainer[indexPath.row]
        if let color = newView.backgroundColor{
            cell.backgroundColor = color
        } else {
            cell.backgroundColor = defaultBackgroundColor
        }
        cell.addSubview(newView)
        newView.setAnchor(view: cell, top: 8, bottom: 8, leading: 16, trailing: 16)
        return cell
    }
}
