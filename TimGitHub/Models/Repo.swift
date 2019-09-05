//
//  Repo.swift
//  TimGitHub
//
//  Created by Timothy on 5/9/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import Foundation

struct Repo: Codable {
    
    var fullName: String?
    
    enum CodingKeys: String, CodingKey {
        
        case fullName = "full_name"
        
    }
    
}
