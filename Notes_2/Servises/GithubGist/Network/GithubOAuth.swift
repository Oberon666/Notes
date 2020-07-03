//
//  GithubOAuth.swift
//  Notes_2
//
//  Created by Витали Суханов on 08.06.2020.
//  Copyright © 2020 Виталий Суханов. All rights reserved.
//

import Foundation
import AuthenticationServices

class GithubOAuth {
    weak var requestManager: RequestManager!
    
    init(_ requestManager: RequestManager) {
        self.requestManager = requestManager
        requestManager.token = getToken()
    }
    
    private let tokenKey: String = "authToken"
    
    private func setToken(token: String?) {
        UserDefaults.standard.set(token, forKey: tokenKey)
        requestManager.token = token
    }
    
    private func getToken() -> String? {
        return UserDefaults.standard.string(forKey: tokenKey)
    }
    
    func resetToken() {
        setToken(token: nil)
    }
    
    var isEnabled: Bool {
        return getToken() != nil
    }
    
    func getAuthTokenWithWebLogin(context: ASWebAuthenticationPresentationContextProviding, completion: @escaping (Error?) -> ()) {
        let completionHandler = { [weak self] (callBack: URL?, error: Error?) in
            guard error == nil, let successURL = callBack, let self = self else {
                completion(error)
                return
            }
            
            let authCode = NSURLComponents(string: (successURL.absoluteString))?.queryItems?.filter({$0.name == "code"}).first
            let state = NSURLComponents(string: (successURL.absoluteString))?.queryItems?.filter({$0.name == "state"}).first
            
            if self.requestManager.state == state?.value, let code = authCode?.value {
                self.getAuthToken(code: code, completion: completion)
            } else {
                completion(GithubOAuthError.stateError)
            }
        }
        
        let webAuthSession = ASWebAuthenticationSession.init(url: requestManager.authUrl, callbackURLScheme: "myNotes://auth", completionHandler: completionHandler)
        webAuthSession.presentationContextProvider = context
        webAuthSession.start()
    }
    
    private func getAuthToken(code: String, completion: @escaping (Error?) -> ()) {
        requestManager.getAuthRequest(code: code) { [weak self] (data) in
            guard let data = data,
                let self = self,
                let postString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String?,
                let url = URLComponents(string: "?\(postString)") else
            {
                completion(GithubOAuthError.getTokenError)
                assertionFailure()
                return
            }
            
            let authTokenResponse = url.queryItems?.first(where: { $0.name == "access_token" })?.value
            self.setToken(token: authTokenResponse)
            completion(nil)
        }
    }
    
    enum GithubOAuthError: Error {
        case stateError
        case getTokenError
    }
}

// MARK: ASWebAuthenticationPresentationContextProviding
extension MenuViewController: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window ?? ASPresentationAnchor()
    }
}
