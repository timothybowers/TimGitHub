//
//  RepoListViewModel.swift
//  TimGitHub
//
//  Created by Timothy on 5/9/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import Foundation

protocol RepoListViewModelProtocol {
    
    // MARK: - Data
    
    var repoList: Array<String> { get }
    
    // MARK: - Public Methods
    
    func fetchUser(onComplete: @escaping (String) -> Void, onError: @escaping (NetworkError) -> Void)
    func fetchRepoList(onComplete: @escaping () -> Void, onError: @escaping (NetworkError) -> Void)
    
}

class RepoListViewModel: RepoListViewModelProtocol {
    
    // MARK: - Data
    
    private(set) var repoList = Array<String>()
    
    // MARK: - Private properties
    
    private var authHeader: String?
    
    // MARK: - Dependencies
    
    private let networkSession: NetworkSessionProtocol?
    
    // MARK: - Inittialisers
    
    init() {
        self.networkSession = NetworkSession()
    }
    
    // MARK: - Public Methods
    
    func fetchUser(onComplete: @escaping (String) -> Void, onError: @escaping (NetworkError) -> Void) {
        guard let _ = OAuthService.token else {
            onError(NetworkError.nilAuthHeader)
            return
        }
        let urlPath = "https://api.github.com/user"
        guard let url = URL(string: urlPath) else {
            return
        }
        
        networkSession?.newNetworkTask(with: url, method: "GET", authHeader: true, jsonParameters: nil) { (data, response, error, request) in
            
            if let error = error {
                onError(NetworkError.sessionTaskError(error: error))
                return
            }
            
            if let data = data {
                
                do {
                    let decoder = JSONDecoder()
                    let decoded = try decoder.decode(User.self, from: data)
                    
                    if let name = decoded.name {
                        
                        onComplete(name)
                        
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
    
    func fetchRepoList(onComplete: @escaping () -> Void, onError: @escaping (NetworkError) -> Void) {
        guard let _ = OAuthService.token else {
            onError(NetworkError.nilAuthHeader)
            return
        }
        let urlPath = "https://api.github.com/user/repos"
        guard let url = URL(string: urlPath) else {
            return
        }
        
        networkSession?.newNetworkTask(with: url, method: "GET", authHeader: true, jsonParameters: nil) { [weak self] (data, response, error, request) in
            
            if let error = error {
                onError(NetworkError.sessionTaskError(error: error))
                return
            }
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let decodedArray = try decoder.decode(Array<Repo>.self, from: data)
                    self?.repoList = decodedArray.map { $0.fullName }.compactMap { $0 }
                    
                    onComplete()
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
