//
//  GistFile.swift
//  Notes_2
//
//  Created by Витали Суханов on 08.06.2020.
//  Copyright © 2020 Виталий Суханов. All rights reserved.
//

import Foundation

struct GistFile: Codable {
    let filename: String?
    let rawUrl: URL?
    let content: String?
    
    private enum CodingKeys: String, CodingKey {
        case filename
        case rawUrl = "raw_url"
        case content
    }
    
    init(fileName: String, content: String) {
        self.filename = fileName
        self.content = content
        rawUrl = nil
    }
}
