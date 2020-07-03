//
//  GistHelper.swift
//  Notes_2
//
//  Created by Витали Суханов on 08.06.2020.
//  Copyright © 2020 Виталий Суханов. All rights reserved.
//

import Foundation

class GistHelper {
    let notesDBMark = "ios_notes_db"
    weak var requestManager: RequestManager!
    
    init(_ requestManager: RequestManager) {
        self.requestManager = requestManager
    }
    
    func uploadNotesToGist(completion: @escaping (Bool) -> ()) {
        AppContainer.coreData.getNotesData { [weak self] (data) in
            guard let data = data, let self = self else {
                completion(false)
                assertionFailure()
                return
            }
            self.saveToGist(data: data, completion: completion)
        }
    }
    
    private var cacheGistId: String?
    
    private func saveToGist(data dataToSave: Data, completion: @escaping (Bool) -> ()) {
        let saveForExistGist = { [weak self] (id: String?) in
            guard let self = self else {
                return
            }
            let gist = Gist(description: self.notesDBMark, id: id, fileName: self.notesDBMark, content: String(decoding: dataToSave, as: UTF8.self))
            self.requestManager.updateGist(gist: gist) { (success) in
                if success {
                    self.cacheGistId = nil
                }
                completion(success)
            }
        }
        
        if let gistId = cacheGistId {
            saveForExistGist(gistId)
            return
        }
        
        getGist { [weak self] (gist) in
            guard let self = self else {
                return
            }
            if let gist = gist {
                saveForExistGist(gist.id)
            } else {
                let gist = Gist(description: self.notesDBMark, fileName: self.notesDBMark, content: String(decoding: dataToSave, as: UTF8.self))
                self.requestManager.createGist(gist: gist) { (gistId) in
                    self.cacheGistId = gistId
                    completion(gistId != nil)
                }
            }
        }
    }
    
    func downloadNotesFromGist(completion: @escaping (Bool) -> ()) {
        getGist { [weak self] (gist) in
            guard let self = self else {
                return
            }
            guard let gist = gist, let fileUrl = gist.files?.first?.value.rawUrl else {
                completion(false)
                assertionFailure()
                return
            }
            
            self.requestManager.getFile(url: fileUrl) { (data) in
                guard let data = data else {
                    completion(false)
                    assertionFailure()
                    return
                }
                completion(self.convertDataToNotes(data: data))
            }
        }
    }
    
    private func getGist(completion: @escaping (Gist?) -> ()) {
        requestManager.getListGists { [weak self] (data, _) in
            guard let data = data, let self = self else {
                completion(nil)
                assertionFailure()
                return
            }
            
            do {
                let gists = try JSONDecoder().decode([Gist].self, from: data)
                for gist in gists where gist.description == self.notesDBMark {
                    completion(gist)
                    return
                }
            } catch {
                assertionFailure()
            }
            completion(nil)
            assertionFailure()
        }
    }
    
    private func convertDataToNotes(data: Data) -> Bool {
        do {
            let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
            guard let json = jsonData as? [[String: Any]] else {
                assertionFailure()
                return false
            }
            
            for noteJson in json {
                AppContainer.coreData.createNewObject { (note) in
                    note.setData(json: noteJson)
                }
            }
        } catch {
            assertionFailure()
            return false
        }
        return true
    }
}
