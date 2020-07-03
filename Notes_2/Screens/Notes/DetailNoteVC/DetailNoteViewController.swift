//
//  DetailNoteViewController.swift
//  Notes_2
//
//  Created by Витали Суханов on 15.05.2020.
//  Copyright © 2020 Виталий Суханов. All rights reserved.
//

import UIKit

class DetailNoteViewController: UIViewController, ScrollViewKeyboardObserving {
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.separatorStyle = .none
        table.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(DetailNoteViewController.self))
        table.keyboardDismissMode = .interactive
        table.automaticallyAdjustsScrollIndicatorInsets = false
        return table
    }()
    
    var keyboardObservingScrollView: UIScrollView {
        return tableView
    }
    
    private lazy var noteView: NoteView = {
        let note = NoteView()
        note.detailText = ""
        note.titleText = ""
        note.viewDidChange = {
            UIView.setAnimationsEnabled(false)
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
        return note
    }()
    
    private lazy var segmentController: UISegmentedControl = {
        let segmentController = UISegmentedControl()
        segmentController.insertSegment(withTitle: "low", at: 0, animated: false)
        segmentController.insertSegment(withTitle: "normal", at: 1, animated: false)
        segmentController.insertSegment(withTitle: "hight", at: 2, animated: false)
        segmentController.selectedSegmentIndex = 1
        return segmentController
    }()
    
    private lazy var colorChooser: ColorChooser = {
        let colorChooser = ColorChooser()
        colorChooser.showColorPickerViewController = { didSelect, color in
            let colorPickerVC = ColorPickerViewController(didSelect: didSelect, color: color)
            self.navigationController?.present(colorPickerVC, animated: true)
        }
        colorChooser.onSetColor = { color in
            self.noteView.color = color
        }
        return colorChooser
    }()
    
    private lazy var dateTimePicker: DateTimePicker = {
        let picker = DateTimePicker()
        picker.valueChangedAction = { value in
            guard value == true else { return }
            AppContainer.notification.checkAuthorization { (success) in
                picker.isOn = success
            }
        }
        return picker
    }()
    
    private var viewStorage = [UIView]()
    private let note: Note?
    
    init(note: Note?) {
        self.note = note
        super.init(nibName: nil, bundle: nil)
        self.tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        viewStorage.append(noteView)
        viewStorage.append(segmentController)
        viewStorage.append(colorChooser)
        viewStorage.append(dateTimePicker)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveAction))
        setupTableView()
        addKeyboardObservers(to: .default)
        hideKeyboardWhenTappedAround()
        loadNote()
    }
    
    private func loadNote() {
        guard let note = note else {
            noteView.color = colorChooser.currentColor
            return
        }
        guard let backgroundColor = note.backgroundColor as? UIColor else {
            assertionFailure()
            return
        }
        
        noteView.detailText = note.detailText
        noteView.titleText = note.title
        noteView.color = backgroundColor
        segmentController.selectedSegmentIndex = Int(note.importance)
        colorChooser.currentColor = backgroundColor
        dateTimePicker.isOn = note.notificationDate != nil
        dateTimePicker.date = note.notificationDate ?? Date()
    }
    
    deinit {
        removeKeyboardObservers(from: .default)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.setAnchor(view: view)
    }
    
    @objc
    private func saveAction() {
        saveNote()
        navigationController?.popViewController(animated: true)
    }

    private func saveNote() {
        guard let title = noteView.titleText, let color = self.colorChooser.currentColor else {
                assertionFailure()
                return
        }
        let description = noteView.detailText
        let importance = Int16(self.segmentController.selectedSegmentIndex)
        let date = dateTimePicker.isOn ? dateTimePicker.date : nil
        let uuid = note?.uuid ?? UUID()

        let setNote: (Note) -> Void = { note in
            note.createDate = Date()
            note.title = title
            note.detailText = description
            note.importance = importance
            note.backgroundColor = color
            note.notificationDate = date
        }
        
        if let objectID = note?.objectID {
            AppContainer.coreData.performToObject(objectID: objectID) { note in
                setNote(note)
            }
        } else {
            AppContainer.coreData.createNewObject { note in
                note.uuid = uuid
                setNote(note)
            }
        }
    }
}

// MARK: UITableViewDataSource
extension DetailNoteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewStorage.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        assert(viewStorage.count >= indexPath.row)
        cell.selectionStyle = .none
        let newView = viewStorage[indexPath.row]
        cell.addSubview(newView)
        newView.setAnchor(view: cell, top: 8, bottom: 8, leading: 16, trailing: 16)
        return cell
    }
}
