//
//  Note+CoreDataClass.swift
//  Notes_2
//
//  Created by Витали Суханов on 21.05.2020.
//  Copyright © 2020 Виталий Суханов. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

@objc(Note)
public class Note: NSManagedObject {
    var json: [String: Any] {
        var result = [String: Any]()
        result["uuid"] = uuid.uuidString
        result["title"] = title
        result["detailText"] = detailText
        result["favorite"] = favorite
        result["importance"] = importance
        if let colors = (backgroundColor as? UIColor)?.cgColor.components {
            result["backgroundColor"] = colors.count == 4 ? colors : [colors[0], colors[0], colors[0], colors[1]]
        } else {
            assertionFailure()
        }
        result["createDate"] = createDate.timeIntervalSince1970
        result["notificationDate"] = notificationDate?.timeIntervalSince1970
        return result
    }
    
    func setData(json: [String: Any]) {
        if let str = json["uuid"] as? String, let newUuid = UUID(uuidString: str) {
        uuid = newUuid
        }
        title = (json["title"] as? String) ?? ""
  
        detailText = (json["detailText"] as? String) ?? ""
        favorite = (json["favorite"] as? Bool) ?? false
        importance = (json["importance"] as? Int16) ?? 0
        if let components = json["backgroundColor"] as? [CGFloat] {
            backgroundColor = UIColor(red: components[0], green: components[1], blue: components[2], alpha: components[3])
        }
        if let timeInterval = json["createDate"] as? Double {
            createDate = Date(timeIntervalSince1970: timeInterval)
        }
        if let timeInterval = json["notificationDate"] as? Double {
            notificationDate = Date(timeIntervalSince1970: timeInterval)
        }
    }
}
