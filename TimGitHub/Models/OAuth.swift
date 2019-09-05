//
//  OAuth.swift
//  TimGitHub
//
//  Created by Timothy on 5/9/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import Foundation

struct OAuth: Codable {
    
    var accessToken: String?
    var tokenType: String?
    var scope: String?
    
    enum CodingKeys: String, CodingKey {
        
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
    
    }
    
}
