//
//  RepoData.swift
//  Gittify
//
//  Created by Ebubechukwu Dimobi on 13.08.2020.
//  Copyright © 2020 blazeapps. All rights reserved.
//

import Foundation


struct RepoData: Codable {
    
    let name: String?
    let description: String?
    let updated_at: String?
    let stargazers_count: Int?
    let language: String?
    let html_url: String?
    
}
