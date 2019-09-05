//
//  NetworkSession.swift
//  TimGitHub
//
//  Created by Timothy on 3/9/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import Foundation

enum NetworkError {
    case decodingNilField
    case jsonDecoding(error: Error)
    case sessionTaskError(error: Error)
    case serverError(request: URLRequest, response: URLResponse?)
    case nilAuthCode
    case nilAuthHeader
}

protocol NetworkSessionProtocol {

    typealias networkCompletionHandler = (Data?, URLResponse?, Error?, URLRequest) -> Void
    
    func newNetworkTask(with url: URL, method: String, authHeader: Bool, jsonParameters: [String: Any]?, completion: @escaping networkCompletionHandler)

}

class NetworkSession: NetworkSessionProtocol {

    // MARK:- Properties
    
    private var configuration: URLSessionConfiguration {
        get {
            let defaultConfig = URLSessionConfiguration.default
            defaultConfig.waitsForConnectivity = false
            defaultConfig.timeoutIntervalForRequest = TimeInterval(60)
            return defaultConfig
        }
    }
    
    private var session: URLSession {
        get {
            return URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue())
        }
    }
    
    private func requestWithHeaders(url: URL, method: String, authHeader: Bool) -> NSMutableURLRequest {
        
        let request = NSMutableURLRequest(url: url)
        
        request.httpMethod = method
        
        // Tell the server what we will accept in the response
        request.addValue("gzip", forHTTPHeaderField: "Accept-Encoding")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Tell the server what data we are sending
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if authHeader == true {
            if let token = OAuthService.token {
                request.addValue("token \(token)", forHTTPHeaderField: "Authorization")
            }
        }
        
        return request
    }
    
    func newNetworkTask(with url: URL, method: String, authHeader: Bool, jsonParameters: [String: Any]?, completion: @escaping networkCompletionHandler) {
        
        let request = requestWithHeaders(url: url, method: method, authHeader: authHeader)
        
        if let jsonParameters = jsonParameters {
            let data = try? JSONSerialization.data(withJSONObject: jsonParameters, options: [])
            if let data = data {
                request.httpBody = data
            }
        }

        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in

            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                completion(data, response, error, request as URLRequest)
            }
            
        })
        task.resume()
    }
    
}
