//
//  Gist.swift
//  Notes_2
//
//  Created by Витали Суханов on 08.06.2020.
//  Copyright © 2020 Виталий Суханов. All rights reserved.
//

import Foundation

struct Gist: Codable {
    let url: String?
    let id: String?
    let htmlUrl: URL?
    let description: String?
    let isPublic: Bool?
    let files: [String: GistFile]?
    
    private enum CodingKeys: String, CodingKey {
        case url
        case id
        case htmlUrl = "html_url"
        case description
        case isPublic = "public"
        case files
    }
    
    init(description: String, id: String? = nil, fileName: String, content: String) {
        url = nil
        self.id = id
        self.description = description
        self.isPublic = false
        htmlUrl = nil

        files = [description: GistFile(fileName: fileName, content: content)]
    }
}
