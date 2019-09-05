//
//  ViewController.swift
//  TimGitHub
//
//  Created by Timothy on 3/9/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    // MARK: - Properties
    
    private var authController: AuthControllerProtocol?
    private let alert = UIAlertController(title: "Loading", message: nil, preferredStyle: .alert)
    
    // MARK: - IB Actions
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        startLoginFlow()
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.authController = AuthController()
    }
 
    // MARK:- Toast

    func toastStart() {
        self.present(alert, animated: true)
    }
    
    func toastStop() {
        alert.dismiss(animated: true, completion: nil)
    }
    
    // MARK:- Navigation
    
    func showRepoScreen() {
        let repoListViewController = RepoListViewController()
        self.present(repoListViewController, animated: true)
    }

    // MARK:- Login Flow
    func startLoginFlow() {
        
        self.authController?.authenticate(onError: {
            
            // MARK: TODO: - Handle error
            print("authenticate error")
            
        }, onComplete: {
            
            DispatchQueue.main.async {
                
                self.toastStart()
                self.authController?.fetchToken(onComplete: { [weak self] in
                    
                    DispatchQueue.main.async {
                        self?.toastStop()
                        self?.showRepoScreen()
                    }
                    
                    }, onError: { [weak self] (networkError) in
                        
                        DispatchQueue.main.async {
                            self?.toastStop()
                        }
                        
                })
                
            }
            
        })
        
    }
    
}
