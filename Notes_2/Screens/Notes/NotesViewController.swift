//
//  NotesViewController.swift
//  Notes_2
//
//  Created by Витали Суханов on 14.05.2020.
//  Copyright © 2020 Виталий Суханов. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController, ToggleMenu {
    private lazy var tableView: NotesTableView = {
        let table = NotesTableView()
        table.delegate = self
        return table
    }()
    
    private func setupNotification() {
        AppContainer.notification.notificationAction = { [weak self] id in
            guard let uuid = UUID(uuidString: id), let self = self else {
                assertionFailure()
                return
            }
            self.dismiss(animated: false, completion: nil)
            self.navigationController?.popToRootViewController(animated: false)
            AppContainer.coreData.getNote(withUUID: uuid) { note in
                self.showDetailNote(note, animated: false)
            }
            self.navigationController?.tabBarController?.selectedIndex = 0
        }
    }
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        return searchController
    }()

    private var currentPredicate: NSPredicate?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupNotification()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        setupSearchController()
        configureNavigationBar()
        setupSwipeGuest()
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Notes"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNoteAction))
        navigationItem.rightBarButtonItem?.tintColor = ColorsProvider.black
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_menu"), style: .plain, target: self, action: #selector(handleToggleMenu))
        navigationItem.leftBarButtonItem?.tintColor = ColorsProvider.black
    }
    
    @objc
    private func addNoteAction() {
        showDetailNote(nil)
    }
    
    private func setupTable() {
        view.addSubview(tableView)
        tableView.setAnchor(view: view)
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    private func showDetailNote(_ note: Note?, animated: Bool = true) {
        let detailNoteVC = DetailNoteViewController(note: note)
        navigationController?.pushViewController(detailNoteVC, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hidesBottomBarWhenPushed = true
        guard let dataSource = tableView.dataSource as? TableViewDataSource<Note> else {
            assertionFailure()
            return
        }
        dataSource.setPredicate(currentPredicate)
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        hidesBottomBarWhenPushed = false
    }
    
    // MARK: Menu
    weak var delegate: ToggleMenuDelegate?
    
    private func setupSwipeGuest() {
        let openGuest = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleOpenMenu))
        openGuest.edges = .left
        view.addGestureRecognizer(openGuest)
        
        let closeGuest = UISwipeGestureRecognizer(target: self, action: #selector(handleCloseMenu))
        closeGuest.direction = .left
        view.addGestureRecognizer(closeGuest)
    }
    
    @objc
      private func handleCloseMenu(_ sender: UISwipeGestureRecognizer) {
          if sender.state == .ended && !tableView.isUserInteractionEnabled{
            handleToggleMenu()
          }
      }
    
    @objc
    private func handleOpenMenu(_ sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .changed {
            sender.state = .ended
            handleToggleMenu()
        }
    }
    @objc
    private func handleToggleMenu() {
        tableView.isUserInteractionEnabled = !tableView.isUserInteractionEnabled
        searchController.searchBar.isUserInteractionEnabled = !searchController.searchBar.isUserInteractionEnabled
        delegate?.handleToggleMenu()
    }
}

// MARK: UITableViewDelegate
extension NotesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = (tableView as? NotesTableView)?.getObject(indexPath: indexPath)
        showDetailNote(note)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let tableView = tableView as? NotesTableView else {
            assertionFailure()
            return nil
        }
        return tableView.getViewForHeaderInSection(section)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let favoriteAction = UIContextualAction(style: .normal, title: "Favorite") {_, _, completionHandler in
            guard let objectID = (tableView as? NotesTableView)?.getObject(indexPath: indexPath)?.objectID else {
                assertionFailure()
                return
            }
            AppContainer.coreData.performToObject(objectID: objectID) { note in
                note.favorite = !note.favorite
                DispatchQueue.main.async {
                    completionHandler(true)
                }
            }
        }
        return UISwipeActionsConfiguration(actions: [favoriteAction])
    }
}

// MARK: UISearchResultsUpdating
extension NotesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let dataSource = tableView.dataSource as? TableViewDataSource<Note> else {
            assertionFailure()
            return
        }
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            currentPredicate = NSPredicate(format: "title contains[c] %@ OR detailText contains[c] %@", searchText, searchText)
        } else {
            currentPredicate = nil
        }
        dataSource.setPredicate(currentPredicate)
        tableView.reloadData()
    }
}
