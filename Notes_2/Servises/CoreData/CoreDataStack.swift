//
//  CoreDataStack.swift
//  Notes_2
//
//  Created by Витали Суханов on 14.05.2020.
//  Copyright © 2020 Виталий Суханов. All rights reserved.
//

import UIKit
import CoreData

class CoreDataStack {
    private let name: String
    
    init(name: String) {
        self.name = name
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contextDidSave(notification:)),
                                               name: NSNotification.Name.NSManagedObjectContextDidSave,
                                               object: nil)
    }
    
    lazy var mainContext: NSManagedObjectContext = {
        persistentContainer.viewContext
    }()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: name)
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    @objc
    private func contextDidSave(notification: Notification) {
        let mainContext = persistentContainer.viewContext
        mainContext.perform {
            mainContext.mergeChanges(fromContextDidSave: notification)
            if mainContext.hasChanges {
                do {
                    try mainContext.save()
                } catch {
                    let error = error as NSError
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
        }
    }

    func getNote(withUUID uuid: UUID, completion: @escaping (Note?) -> () ) {
        self.persistentContainer.performBackgroundTask { context in
            do {
                let request = Note.fetchRequest() as NSFetchRequest<Note>
                request.predicate = NSPredicate(format: "uuid = %@", uuid.uuidString)
                let result = try context.fetch(request)
                let objectID = result.first?.objectID
                DispatchQueue.main.async {
                    if let id = objectID {
                        let note = self.persistentContainer.viewContext.object(with: id) as? Note
                        completion(note)
                    } else {
                        assertionFailure()
                        completion(nil)
                    }
                }
            } catch {
                assertionFailure()
                completion(nil)
            }
        }
    }
    
    func createNewObject(completion: @escaping (Note) -> Void) {
        persistentContainer.performBackgroundTask { context in
            let newObject = Note(context: context)
            completion(newObject)
            AppContainer.notification.setupNotificationTo(note: newObject)
            do {
                try context.save()
            } catch {
                assertionFailure()
            }
        }
    }
    
    func performToObject(objectID: NSManagedObjectID, completion: @escaping (Note) -> Void) {
        persistentContainer.performBackgroundTask { [weak self] context in
            guard let self = self, let object = self.mainContext.object(with: objectID) as? Note else {
                assertionFailure()
                return
            }
            completion(object)
            AppContainer.notification.setupNotificationTo(note: object)
            do {
                try context.save()
            } catch {
                assertionFailure()
            }
        }
    }
    
    func delteObject(objectID: NSManagedObjectID) {
        persistentContainer.performBackgroundTask { (context) in
            guard let object = context.object(with: objectID) as? Note else {
                assertionFailure()
                return
            }
            AppContainer.notification.remove(identifier: object.uuid.uuidString)
            context.delete(object)
            do {
                try context.save()
            } catch {
                assertionFailure()
            }
        }
    }
    
    func deleteAllObject() {
        self.persistentContainer.performBackgroundTask { context in
            do {
                let request = Note.fetchRequest() as NSFetchRequest<Note>
                let result = try context.fetch(request)
                for object in result {
                    context.delete(object)
                }
                try context.save()
                AppContainer.notification.removeAll()
            } catch {
                assertionFailure()
            }
        }
    }
    
    func getNotesData(completion: @escaping (Data?) ->()) {
        self.persistentContainer.performBackgroundTask { context in
            var allId = [NSManagedObjectID]()
            do {
                let request = Note.fetchRequest() as NSFetchRequest<Note>
                let result = try context.fetch(request)
                result.forEach { (note) in
                    allId.append(note.objectID)
                }
            } catch {
                assertionFailure()
                completion(nil)
            }
            
            let notesJson = allId.reduce(into: [[String: Any?]]()) { notesJson, id  in
                if let note = context.object(with: id) as? Note {
                    notesJson.append(note.json)
                }
            }
            
            do {
                let data = try JSONSerialization.data(withJSONObject: notesJson, options: [])
                completion(data)
            } catch {
                assertionFailure()
                completion(nil)
            }
        }
    }
}
