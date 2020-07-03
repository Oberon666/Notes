//
//  FavoritesViewController.swift
//  Notes_2
//
//  Created by Витали Суханов on 14.05.2020.
//  Copyright © 2020 Виталий Суханов. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController {
    private lazy var tableView: NotesTableView = {
        let table = NotesTableView()
        table.delegate = self
        table.sectionHeaderHeight = 0
        return table
    }()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        return searchController
    }()
    
    private var currentPredicate: NSPredicate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        setupSearchController()
        
        navigationItem.title = "Favorites"
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
        let detailNoteVC = DetailNoteViewController(note: note)
        navigationController?.pushViewController(detailNoteVC, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hidesBottomBarWhenPushed = true
        guard let dataSource = tableView.dataSource as? TableViewDataSource<Note> else {
            assertionFailure()
            return
        }
        currentPredicate = NSPredicate(format: "favorite == YES")
        dataSource.setPredicate(currentPredicate)
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        hidesBottomBarWhenPushed = false
    }
}

// MARK: UITableViewDelegate
extension FavoritesViewController: UITableViewDelegate {
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
extension FavoritesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let dataSource = tableView.dataSource as? TableViewDataSource<Note> else {
            assertionFailure()
            return
        }
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            currentPredicate = NSPredicate(format: "title contains[c] %@ OR detailText contains[c] %@ AND favorite == YES", searchText, searchText)
        } else {
            currentPredicate = NSPredicate(format: "favorite == YES")
        }
        dataSource.setPredicate(currentPredicate)
        tableView.reloadData()
    }
}
