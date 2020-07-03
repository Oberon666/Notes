//
//  TableViewDataSource.swift
//  Notes_2
//
//  Created by Витали Суханов on 22.05.2020.
//  Copyright © 2020 Виталий Суханов. All rights reserved.
//

import UIKit
import CoreData

protocol FRCTableViewDelegate: class {
    func tableView(_ tableView: UITableView, cellForItemAt indexPath: IndexPath) -> UITableViewCell
}

class TableViewDataSource<FetchRequestResult: NSManagedObject>: NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    private let fetchedRC: NSFetchedResultsController<FetchRequestResult>
    weak var tableView: UITableView?
    weak var delegate: FRCTableViewDelegate?
    
    init(fetchRequest: NSFetchRequest<FetchRequestResult>, context: NSManagedObjectContext, sectionNameKeyPath: String?) {
        fetchedRC = NSFetchedResultsController(fetchRequest: fetchRequest,
                                               managedObjectContext: context,
                                               sectionNameKeyPath: sectionNameKeyPath,
                                               cacheName: nil)
        super.init()
        fetchedRC.delegate = self
    }
    
    func performFetch() {
        do {
            try fetchedRC.performFetch()
        } catch {
            fatalError()
        }
    }
    
    func object(at indexPath: IndexPath) -> FetchRequestResult {
        return fetchedRC.object(at: indexPath)
    }
    
    func setPredicate(_ predicate: NSPredicate?) {
        fetchedRC.fetchRequest.predicate = predicate
        performFetch()
    }
    
    // MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        fetchedRC.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        fetchedRC.sections?[section].name ?? ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchedRC.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let delegate = delegate else { return UITableViewCell() }
        return delegate.tableView(tableView, cellForItemAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let object = fetchedRC.object(at: indexPath)
            let objectId = object.objectID
            AppContainer.coreData.delteObject(objectID: objectId)
        }
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let sectionIndexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert:
            tableView?.insertSections(sectionIndexSet, with: .fade)
        case .delete:
            tableView?.deleteSections(sectionIndexSet, with: .fade)
        case .update:
            tableView?.reloadSections(sectionIndexSet, with: .fade)
        case .move:
            assertionFailure()
        @unknown default:
            fatalError()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            tableView?.deleteRows(at: [indexPath!], with: .fade)
        case .insert:
            tableView?.insertRows(at: [newIndexPath!], with: .fade)
        case .move:
            tableView?.deleteRows(at: [indexPath!], with: .fade)
            tableView?.insertRows(at: [newIndexPath!], with: .fade)
        case .update:
            tableView?.reloadRows(at: [indexPath!], with: .fade)
        @unknown default:
            fatalError()
        }
    }
}
