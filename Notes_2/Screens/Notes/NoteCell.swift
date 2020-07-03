//
//  NoteCell.swift
//  Notes_2
//
//  Created by Витали Суханов on 15.05.2020.
//  Copyright © 2020 Виталий Суханов. All rights reserved.
//

import UIKit

class NoteCell: UITableViewCell, ReusableView {
    private let titleLabel = UILabel()
    private let separator = UIView()
    private let detailLabel = UILabel()
    private let createDateLabel = UILabel()
    private let favoriteImageView = UIImageView()
    private let noteView = UIView()
    private let bubbleBackground = UIView()
    
    private let indent: CGFloat = 18
    private let indent2: CGFloat = -9
    private let minHeightView: CGFloat = 100
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstrain()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        detailLabel.numberOfLines = 3
        bubbleBackground.layer.cornerRadius = 10
        separator.backgroundColor = ColorsProvider.getGrayColor(onBackground: bubbleBackground.backgroundColor)
        
        noteView.addSubview(titleLabel)
        noteView.addSubview(separator)
        noteView.addSubview(detailLabel)
        noteView.addSubview(createDateLabel)
        noteView.addSubview(favoriteImageView)
        addSubview(bubbleBackground)
        addSubview(noteView)
    }
    
    private func setupConstrain() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        separator.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        createDateLabel.translatesAutoresizingMaskIntoConstraints = false
        noteView.translatesAutoresizingMaskIntoConstraints = false
        bubbleBackground.translatesAutoresizingMaskIntoConstraints = false
        favoriteImageView.translatesAutoresizingMaskIntoConstraints = false
        let constrains = [
            titleLabel.topAnchor.constraint(equalTo: noteView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: noteView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: noteView.trailingAnchor),
            
            separator.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: noteView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: noteView.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            
            detailLabel.topAnchor.constraint(equalTo: separator.bottomAnchor),
            detailLabel.bottomAnchor.constraint(lessThanOrEqualTo: createDateLabel.topAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: noteView.trailingAnchor),
            detailLabel.leadingAnchor.constraint(equalTo: noteView.leadingAnchor),
            
            createDateLabel.bottomAnchor.constraint(equalTo: noteView.bottomAnchor),
            createDateLabel.leadingAnchor.constraint(equalTo: noteView.leadingAnchor),
            
            favoriteImageView.bottomAnchor.constraint(equalTo: noteView.bottomAnchor),
            favoriteImageView.trailingAnchor.constraint(equalTo: noteView.trailingAnchor),
            favoriteImageView.heightAnchor.constraint(equalToConstant: 15),
            favoriteImageView.widthAnchor.constraint(equalToConstant: 15),
            
            noteView.topAnchor.constraint(equalTo: topAnchor, constant: indent/2),
            noteView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -indent/2),
            noteView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: indent),
            noteView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -indent),
            noteView.widthAnchor.constraint(greaterThanOrEqualTo: detailLabel.widthAnchor),
            noteView.widthAnchor.constraint(greaterThanOrEqualTo: titleLabel.widthAnchor),
            noteView.heightAnchor.constraint(greaterThanOrEqualToConstant: minHeightView),
            
            bubbleBackground.topAnchor.constraint(equalTo: noteView.topAnchor, constant: indent2),
            bubbleBackground.bottomAnchor.constraint(equalTo: noteView.bottomAnchor, constant: -indent2/2),
            bubbleBackground.leadingAnchor.constraint(equalTo: noteView.leadingAnchor, constant: indent2),
            bubbleBackground.trailingAnchor.constraint(equalTo: noteView.trailingAnchor, constant: -indent2)
        ]
        NSLayoutConstraint.activate(constrains)
    }
    
    private func getStrDate(date: Date) -> String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInYesterday(date) || Calendar.current.isDateInToday(date) {
            formatter.timeStyle = .none
            formatter.dateStyle = .medium
            formatter.doesRelativeDateFormatting = true
        } else {
            let yearNow = Calendar.current.component(.year, from: Date())
            let year = Calendar.current.component(.year, from: date)
            formatter.dateFormat = yearNow == year ? "HH:mm E, d MMM" : "HH:mm E, d MMM y"
        }
        return formatter.string(from: date)
    }
    
    func setCell(note: Note) {
        self.selectionStyle = .none
        
        if let color = note.backgroundColor as? UIColor {
            bubbleBackground.backgroundColor = color
        } else {
            assertionFailure()
        }
        bubbleBackground.layer.borderWidth = 0.5
        bubbleBackground.layer.borderColor = ColorsProvider.gray.cgColor
        
        if note.title.isEmpty {
            titleLabel.text =  "No title"
            titleLabel.textColor = ColorsProvider.getGrayColor(onBackground: bubbleBackground.backgroundColor)
        } else {
            titleLabel.text = note.title
            titleLabel.textColor = ColorsProvider.getBlackColor(onBackground: bubbleBackground.backgroundColor)
        }
        titleLabel.textAlignment = .center
        titleLabel.font = .boldSystemFont(ofSize: 17)
        
        if note.detailText.isEmpty {
            detailLabel.text = "No description"
            detailLabel.textColor = ColorsProvider.getGrayColor(onBackground: bubbleBackground.backgroundColor)
        } else {
            detailLabel.text = note.detailText
            detailLabel.textColor = ColorsProvider.getBlackColor(onBackground: bubbleBackground.backgroundColor)
        }
        detailLabel.font = .systemFont(ofSize: 17)

        createDateLabel.text = getStrDate(date: note.createDate)
        createDateLabel.font = .systemFont(ofSize: 11)
        createDateLabel.textColor = ColorsProvider.getGrayColor(onBackground: bubbleBackground.backgroundColor)
        
        let favoriteColor = ColorsProvider.getBlackColor(onBackground: bubbleBackground.backgroundColor)
        favoriteImageView.image = UIImage(named: "ic_favorite")?.withTintColor(favoriteColor)
        favoriteImageView.tintColor = ColorsProvider.getBlackColor(onBackground: bubbleBackground.backgroundColor)
        favoriteImageView.tintColorDidChange()
        favoriteImageView.isHidden = !note.favorite
    }
    
}
