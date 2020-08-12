//
//  searchData.swift
//  Gittify
//
//  Created by Ebubechukwu Dimobi on 12.08.2020.
//  Copyright © 2020 blazeapps. All rights reserved.
//

import Foundation

struct SearchUserData: Codable {
    
    let total_count: Int?
    let items: [Items]
}

struct Items: Codable {
    let login: String?
    let avatar_url: String?
    let url: String?
    let repos_url: String?
    let type: String?
}
