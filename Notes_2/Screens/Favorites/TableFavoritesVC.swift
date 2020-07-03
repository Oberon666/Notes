//
//  TableFavoritesVC.swift
//  Notes_2
//
//  Created by Витали Суханов on 14.05.2020.
//  Copyright © 2020 Виталий Суханов. All rights reserved.
//

import UIKit

class FavoritesVC: UIViewController {
    private lazy var tableView: NotesTableView = {
        let table = NotesTableView()
        table.delegate = self
        return table
    }()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        return searchController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        setupSearchController()
        
        UserNotificationService.shared.notificationAction = { [weak self] id in
            guard let uuid = UUID(uuidString: id) else {
                assertionFailure()
                return
            }
            let note = self?.tableView.getNote(uuid: uuid)
            self?.showDetailNote(note)
        }
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
    
    private func showDetailNote(_ note: Note?) {
        let detailNoteVC = DetailNoteVC(note: note)
        hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailNoteVC, animated: true)
        hidesBottomBarWhenPushed = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let dataSource = tableView.dataSource as? TableViewDataSource<Note> else {
            assertionFailure()
            return
        }
        let predicate = NSPredicate(format: "favorite == YES")
        dataSource.setPredicate(predicate)
        tableView.reloadData()
    }
}

// MARK: UITableViewDelegate
extension FavoritesVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = (tableView as? NotesTableView)?.getObject(indexPath: indexPath)
        showDetailNote(note)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let favoriteAction = UIContextualAction(style: .normal, title: "Favorite") {_, _, completionHandler in
            guard let objectID = (tableView as? NotesTableView)?.getObject(indexPath: indexPath)?.objectID else {
                assertionFailure()
                return
            }
            AppContainer.coreData.persistentContainer.performBackgroundTask { context in
                guard let object = context.object(with: objectID) as? Note else {
                    assertionFailure()
                    return
                }
                object.favorite = !object.favorite
                do {
                    try context.save()
                } catch let error {
                    print("error: \(error)")
                    assertionFailure()
                }
            }
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [favoriteAction])
    }
}

// MARK: UISearchResultsUpdating
extension FavoritesVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let dataSource = tableView.dataSource as? TableViewDataSource<Note> else {
            assertionFailure()
            return
        }
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            let predicate = NSPredicate(format: "title contains[c] %@ OR detailText contains[c] %@", searchText, searchText)
            dataSource.setPredicate(predicate)
        } else {
            dataSource.setPredicate(nil)
        }
        tableView.reloadData()
    }
}
