//
//  GitHubService.swift
//  Notes_2
//
//  Created by Витали Суханов on 08.06.2020.
//  Copyright © 2020 Виталий Суханов. All rights reserved.
//

import UIKit
import AuthenticationServices

class GitHubService {
    init() {
        requestManager = RequestManager()
        githubOAuth = GithubOAuth(requestManager)
        gistHelper = GistHelper(requestManager)
    }
    
    private let requestManager: RequestManager
    private let githubOAuth: GithubOAuth
    private let gistHelper: GistHelper
    
    var isEnabled: Bool {
        set(value) {
            if !value { githubOAuth.resetToken() }
        }
        get { githubOAuth.isEnabled }
    }
    
    func getAuthGithub(context: ASWebAuthenticationPresentationContextProviding, completion: @escaping (Error?) -> ()) {
        githubOAuth.getAuthTokenWithWebLogin(context: context, completion: completion)
    }
    
    func uploadNotesToGist(completion: @escaping (Bool) -> ()) {
        gistHelper.uploadNotesToGist(completion: completion)
    }
    
    func downloadNotesFromGist(completion: @escaping (Bool) -> ()) {
        gistHelper.downloadNotesFromGist(completion: completion)
    }
}
