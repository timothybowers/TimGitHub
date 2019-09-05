//
//  User.swift
//  TimGitHub
//
//  Created by Timothy on 5/9/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import Foundation

struct User: Codable {
    
    var name: String?
    
    enum CodingKeys: String, CodingKey {
        
        case name
        
    }
    
}
