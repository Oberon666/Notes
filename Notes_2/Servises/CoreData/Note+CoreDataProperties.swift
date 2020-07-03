//
//  Note+CoreDataProperties.swift
//  Notes_2
//
//  Created by Витали Суханов on 21.05.2020.
//  Copyright © 2020 Виталий Суханов. All rights reserved.
//
//

import Foundation
import CoreData

extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var uuid: UUID
    @NSManaged public var title: String
    @NSManaged public var detailText: String
    @NSManaged public var backgroundColor: NSObject
    @NSManaged public var importance: Int16
    @NSManaged public var notificationDate: Date?
    @NSManaged public var createDate: Date
    @NSManaged public var favorite: Bool

}
