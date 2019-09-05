//
//  RepoListViewController.swift
//  TimGitHub
//
//  Created by Timothy on 5/9/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import UIKit

final class RepoListViewController: UIViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    
    // MARK: - Properties
    
    private var viewModel: RepoListViewModelProtocol?
    private let alert = UIAlertController(title: "Loading", message: nil, preferredStyle: .alert)
    
    // MARK: - Initialisers
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = RepoListViewModel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.register(RepoTableViewCell.self, forCellReuseIdentifier: "repocell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        toastStart()
        viewModel?.fetchUser(onComplete: { [weak self] name in

            DispatchQueue.main.async { [weak self] in
                self?.nameLabel.text = name
            }
            
            }, onError: { (networkError) in
                // MARK: - TODO: Handle Error
                print("fetchUser error: \(networkError)")
            }
        )
        
        viewModel?.fetchRepoList(onComplete: { 

            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
                self?.toastStop()
            }
            
        }, onError: { [weak self] (networkError) in
            // MARK: - TODO: Handle Error
            print("fetchUser error: \(networkError)")
            self?.toastStop()
        })
    }
    
    // MARK:- Toast
    
    func toastStart() {
        present(alert, animated: true)
    }
    
    func toastStop() {
        alert.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - UITableViewDelegate

extension RepoListViewController: UITableViewDelegate {
    
}

// MARK: - UITableViewDataSource

extension RepoListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "My Repositories"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "repocell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = self.viewModel?.repoList[indexPath.row]
        return cell
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel?.repoList.count ?? 0
    }
    
}
