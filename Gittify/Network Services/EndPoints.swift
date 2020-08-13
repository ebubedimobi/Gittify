//
//  EndPoints.swift
//  Gittify
//
//  Created by Ebubechukwu Dimobi on 12.08.2020.
//  Copyright © 2020 blazeapps. All rights reserved.
//

import Foundation

struct EndPoints {
    
    struct ForSearchUsers {
        static let topUrl = "https://api.github.com/search/users?q="
        static let midUrl = "&page="
        static let endUrl = "&per_page=\(Constants.resultsPerPage)"
        
    }
    
    struct ForRepos {
       static let midURL = "?page="
        static let endURL = "&per_page=\(Constants.resultsPerPage)"
    }
    
}
