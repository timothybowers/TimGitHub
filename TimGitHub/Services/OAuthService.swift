//
//  OAuthService.swift
//  TimGitHub
//
//  Created by Timothy on 3/9/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import Foundation
import AuthenticationServices

struct OAuthService {
    static var token: String?
}

protocol AuthControllerProtocol {
    func authenticate(onError: @escaping () -> Void, onComplete: @escaping () -> Void)
    func fetchToken(onComplete: @escaping () -> Void, onError: @escaping (NetworkError) ->Void)
}

final class AuthController: AuthControllerProtocol {

    // MARK: - Properties
    
    private var authSession: ASWebAuthenticationSession?
    private var code: String?
    
    // MARK:- Methods
    
    func authenticate(onError: @escaping () -> Void, onComplete: @escaping () -> Void) {
        let urlPath = "https://github.com/login/oauth/authorize?client_id=785f24291501818d5ac1"
        guard let url = URL(string: urlPath) else {
            onError()
            return
        }
        self.authSession = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: "timgithub://",
            completionHandler: {
                url, error in
                
                if error == nil {
                    if let url = url {
                        let codes = url.absoluteString.split(separator: "=")
                        if let code = codes.last {
                            self.code = String(code)
                            
                            onComplete()
                            return
                        }
                    }
                }
                onError()
                
        })
        self.authSession?.start()
    }

    func fetchToken(onComplete: @escaping () -> Void, onError: @escaping (NetworkError) ->Void) {
        guard let code = self.code else {
            onError(NetworkError.nilAuthCode)
            return
        }
        let urlPath = "https://github.com/login/oauth/access_token"
        guard let url = URL(string: urlPath) else {
            return
        }
        
        var parameters: [String: Any] = [:]
        parameters["client_id"] = "785f24291501818d5ac1"
        parameters["client_secret"] = "ab5a7af96a78f9eb5d947d58b895a4994760e01c"
        parameters["code"] = code
        
        let ns = NetworkSession()
        ns.newNetworkTask(with: url, method: "POST", authHeader: false, jsonParameters: parameters) { (data, response, error, request) in
            
            if let error = error {
                onError(NetworkError.sessionTaskError(error: error))
                return
            }
            
            if let data = data {
                
                do {
                    let decoder = JSONDecoder()
                    let decoded = try decoder.decode(OAuth.self, from: data)
                    
                    if let token = decoded.accessToken {
                        
                        OAuthService.token = token
                        
                        onComplete()
                        
                    } else {
                        onError(NetworkError.decodingNilField)
                    }
                }
                catch let jsonDecoderError {
                    onError(NetworkError.jsonDecoding(error: jsonDecoderError))
                }
                
            } else {
                onError(NetworkError.serverError(request: request, response: response))
            }
            
        }
        
    }
    
}
