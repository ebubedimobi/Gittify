//
//  WebViewController.swift
//  Gittify
//
//  Created by Ebubechukwu Dimobi on 13.08.2020.
//  Copyright © 2020 blazeapps. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    
      var urlstring: String?
     override func viewDidLoad() {
         super.viewDidLoad()
         
         
         if let safeString = urlstring{
             if let url = URL(string: safeString){
                 let request = URLRequest(url: url)
                 webView.load(request)
             }else {
                 print("error creating session")
             }
         }else {
             print("error with safeString")
         }
     }
    


}
