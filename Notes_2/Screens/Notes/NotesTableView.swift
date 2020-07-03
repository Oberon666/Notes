//
//  NotesTableView.swift
//  Notes_2
//
//  Created by Витали Суханов on 20.05.2020.
//  Copyright © 2020 Виталий Суханов. All rights reserved.
//

import UIKit
import CoreData

class NotesTableView: UITableView, FRCTableViewDelegate {
    private lazy var fetchedDataSource: TableViewDataSource<Note> = {
        let request = Note.fetchRequest() as NSFetchRequest<Note>
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Note.importance), ascending: false),
                                   NSSortDescriptor(key: #keyPath(Note.createDate), ascending: false)]
        let dataSource = TableViewDataSource<Note>(fetchRequest: request,
                                                   context: AppContainer.coreData.mainContext,
                                                   sectionNameKeyPath: #keyPath(Note.importance))
        dataSource.delegate = self
        dataSource.tableView = self
        return dataSource
    }()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        dataSource = fetchedDataSource
        separatorStyle = .none
        register(NoteCell.self)
        keyboardDismissMode = .interactive
        fetchedDataSource.performFetch()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func handleRefreshControl(_ sender: Any) {
        DispatchQueue.main.async {
            self.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }

    func tableView(_ tableView: UITableView, cellForItemAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NoteCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        let object = fetchedDataSource.object(at: indexPath)
        cell.setCell(note: object)
        return cell
    }
    
    func getObject(indexPath: IndexPath) -> Note? {
        fetchedDataSource.object(at: indexPath)
    }
    
    func getViewForHeaderInSection(_ section: Int) -> UIView? {
        guard let title = dataSource?.tableView?(self, titleForHeaderInSection: section) else {
            assertionFailure()
            return nil
        }
        let label = HeaderLabel()
        label.text = getCustomTitleForSection(title)
        let containerView = UIView()
        containerView.addSubview(label)
        label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true

        return containerView
    }
    
    private func getCustomTitleForSection(_ section: String) -> String? {
        switch section {
        case "0": return "low"
        case "1": return "normal"
        case "2": return "high"
        default:
            assertionFailure()
        }
        return nil
    }
}

// MARK: HeaderLabel
private class HeaderLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0.5)
        textColor = ColorsProvider.grayInverted
        textAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        font = UIFont.boldSystemFont(ofSize: 14)
        let originContentSize = super.intrinsicContentSize
        let height = originContentSize.height + 4
        layer.cornerRadius = height/3
        layer.masksToBounds = true
        return CGSize(width: originContentSize.width + 8, height: height)
    }
}
