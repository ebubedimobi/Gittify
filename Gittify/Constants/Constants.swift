//
//  Constants.swift
//  Gittify
//
//  Created by Ebubechukwu Dimobi on 12.08.2020.
//  Copyright © 2020 blazeapps. All rights reserved.
//

import UIKit


struct Constants {
    static let resultsPerPage = 20
    
    struct Segue {
        static let searchToInfo = "goToInfoFromSearch"
        static let searchToWeb = "goToWebViewFromSearch"
        static let infoToWeb = "goToWebViewFromInfo"
        
    }
    
    struct CellIdentifiers {
        static let forSearchVC = "SearchCell"
        static let forInfoVC = "InfoCell"
    }
    
    struct cellsizes {
        static let forSelected: CGFloat = 165
        static let forUnselected: CGFloat = 96
    }
    
}
