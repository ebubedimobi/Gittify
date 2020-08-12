//
//  ViewController.swift
//  Gittify
//
//  Created by Ebubechukwu Dimobi on 12.08.2020.
//  Copyright © 2020 blazeapps. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var x = 10
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.CellIdentifiers.forSearchVC)
        
    }
    
    
    
}

//MARK: - UITableViewDataSource methods
extension SearchViewController: UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return x
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.forSearchVC, for: indexPath) as! SearchTableViewCell
        cell.loginLabel.text = String(indexPath.row)
        
        return cell
    }
    
    
}

//MARK: - UITableViewDelegate Methods

extension SearchViewController: UITableViewDelegate, UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        
        if position > (tableView.contentSize.height - 10 - scrollView.frame.height){
            
            self.tableView.tableFooterView = createSpinnerFooter()
            x += 10
            self.tableView.reloadData()
            self.tableView.tableFooterView = nil
            
        }
    }
    
    private func createSpinnerFooter() -> UIView {
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        return footerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.Segue.searchToInfo, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}


