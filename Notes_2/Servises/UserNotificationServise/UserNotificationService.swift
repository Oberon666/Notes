//
//  UserNotificationService.swift
//  Notes_2
//
//  Created by Витали Суханов on 22.05.2020.
//  Copyright © 2020 Виталий Суханов. All rights reserved.
//

import UIKit
import UserNotifications

class UserNotificationService: NSObject {
    override init() {
        notificationCenter = UNUserNotificationCenter.current()
        super.init()
        notificationCenter.delegate = self
    }

    private let notificationCenter: UNUserNotificationCenter
    
    var notificationAction: ((_ identifier: String) -> ())?
    
    private func requestAuthorization(completion: ((Error?) -> ())?) {
        let options = UNAuthorizationOptions.init(arrayLiteral: .alert, .sound)
        notificationCenter.requestAuthorization(options: options) { success, error in
            if let error = error {
                completion?(error)
                return
            }
            
            completion?(success ? nil : NotificationError.accessDenied)
        }
    }
    
    private func setup(title: String, description: String, identifier: String, date: Date, completion: @escaping (Error?) -> ()) {
        requestAuthorization { error in
            if let error = error {
                completion(error)
                return
            }
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = description
            content.sound = .default
            content.userInfo["identifier"] = identifier
            
            let dateComponent = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            self.notificationCenter.add(request) { error in
                completion(error ?? nil)
            }
        }
    }
    
    func remove(identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func removeAll() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }
    
    func setupNotificationTo(note: Note) {
        guard let date = note.notificationDate else { return }
        setup(title: note.title, description: note.detailText, identifier: note.uuid.uuidString, date: date) { error in
            guard error != nil else { return }
            self.removeNotificationTo(note: note)
            self.showPermissionAlert(error: error)
        }
    }
    
    private func removeNotificationTo(note: Note) {
        AppContainer.coreData.performToObject(objectID: note.objectID) { note in
            note.notificationDate = nil
        }
    }
    
    private func showPermissionAlert(error: Error?) {
        DispatchQueue.main.async {
            UIAlertController.showTextAlert(title: "Notification error", description: error?.localizedDescription ?? "undefined error")
        }
    }
    
    func checkAuthorization(completion: @escaping (Bool) -> ()) {
        notificationCenter.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional {
                completion(true)
                return
            }
            self.requestAuthorization { (error) in
                if error != nil {
                    self.showPermissionAlert(error: error)
                }
                completion(error == nil)
            }
        }
    }
    
    enum NotificationError: Error, LocalizedError {
        case accessDenied
        
        var errorDescription: String? {
            switch self {
            case .accessDenied:
                return NSLocalizedString("Please go to settings and enable notifications permission.", comment: "Permission disabled")
            }
        }
    }
}

extension UserNotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let identifier = response.notification.request.content.userInfo["identifier"] as? String {
            notificationAction?(identifier)
        }
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
