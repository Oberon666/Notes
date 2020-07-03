//
//  AppContainer.swift
//  Notes_2
//
//  Created by Витали Суханов on 14.05.2020.
//  Copyright © 2020 Виталий Суханов. All rights reserved.
//

import UIKit

class AppContainer {
    static let coreData: CoreDataStack = {
        CoreDataStack(name: "Notes_2")
    }()
    static let notification: UserNotificationService = {
        UserNotificationService()
    }()
    static let github: GitHubService = {
        GitHubService()
    }()
}
