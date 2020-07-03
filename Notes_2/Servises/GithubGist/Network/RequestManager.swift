//
//  RequestManager.swift
//  Notes_2
//
//  Created by Витали Суханов on 08.06.2020.
//  Copyright © 2020 Виталий Суханов. All rights reserved.
//

import Foundation

class RequestManager {
    let state = UUID().uuidString
    private let clientId = "f940cc46421c819f75c4"
    private let clientSecret = "8361db974d682a91a5fb1fe0a936f6a0ae5e9309"
    private let scope = "gist%20repo%20read:user"
    private let baseURL: String = "https://github.com/"
    private let baseURLApi: String = "https://api.github.com/"
    
    enum RequestMethod: String {
        case post = "POST"
        case get = "GET"
        case patch = "PATCH"
    }
    
    lazy var authUrl: URL = URL(string: "\(baseURL)login/oauth/authorize?scope=\(scope)&client_id=\(clientId)&state=\(state)")!
    var token: String!
    
    private func baseRequest(method: RequestMethod,
                             url: URL?,
                             body: Data? = nil,
                             useToken: Bool = true,
                             completion: @escaping (Data?, Error?) -> (),
                             responseCode: Int) {
        guard let url = url else {
            completion(nil, RequestError.invalidUrl)
            assertionFailure()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if useToken {
            if let token = token {
                request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
            } else {
                completion(nil, RequestError.invalidToken)
                assertionFailure()
                return
            }
        }
        
        if let body = body {
            request.httpBody = body
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }
        
        let completionHandler = { ( data: Data?, response: URLResponse?, error: Error?) in
            guard let response = response as? HTTPURLResponse, response.statusCode == responseCode else {
                completion(nil, RequestError.incorrectResponse)
                assertionFailure()
                return
            }
            completion(data, error)
        }
        URLSession.shared.dataTask(with: request, completionHandler: completionHandler).resume()
    }
    
    func getAuthRequest(code: String, completion: @escaping (Data?) -> ()) {
        let authParam = "&code=\(code)"
        let strUrl = "\(baseURL)login/oauth/access_token?client_id=\(clientId)&client_secret=\(clientSecret)\(authParam)"
        let url = URL(string: strUrl)
        let completion = { (data: Data?, error: Error?) -> () in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            completion(data)
        }
        baseRequest(method: RequestMethod.post, url: url, useToken: false, completion: completion, responseCode: 200)
    }
    
    func getListGists(completion: @escaping (Data?, Error?) -> ()) {
        let url = URL(string: "\(baseURLApi)gists")
        baseRequest(method: RequestMethod.get, url: url, completion: completion, responseCode: 200)
    }
    
    func createGist(gist: Gist, completion: @escaping (String?) -> ()) {
        guard let body = try? JSONEncoder().encode(gist) else {
            completion(nil)
            return
        }
        
        let completion = { (data: Data?, error: Error?) -> () in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            if let gist = try? JSONDecoder().decode(Gist.self, from: data) {
                completion(gist.id)
                return
            }
            completion(nil)
        }
        let url = URL(string: "\(baseURLApi)gists?access_token=" + (token ?? ""))
        baseRequest(method: RequestMethod.post, url: url, body: body, completion: completion, responseCode: 201)
    }
    
    func updateGist(gist: Gist, completion: @escaping (Bool) -> ()) {
        guard let gistId = gist.id, let body = try? JSONEncoder().encode(gist) else {
            completion(false)
            return
        }
        
        let completion = { (data: Data?, error: Error?) -> () in
            guard data != nil, error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
        let url = URL(string: "\(baseURLApi)gists/\(gistId)")
        baseRequest(method: RequestMethod.patch, url: url, body: body, completion: completion, responseCode: 200)
    }
    
    func getFile(url: URL, completion: @escaping (Data?) -> ()) {
        let completion = { (data: Data?, error: Error?) -> () in
            guard data != nil, error == nil else {
                completion(nil)
                return
            }
            completion(data)
        }
        baseRequest(method: RequestMethod.get, url: url, completion: completion, responseCode: 200)
    }
    
    enum RequestError: Error {
        case invalidToken
        case invalidUrl
        case incorrectResponse
        case error
    }
}
