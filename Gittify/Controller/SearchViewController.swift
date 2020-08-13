//
//  ViewController.swift
//  Gittify
//
//  Created by Ebubechukwu Dimobi on 12.08.2020.
//  Copyright © 2020 blazeapps. All rights reserved.
//

import UIKit
import RxSwift
import Kingfisher

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    private let disposeBag = DisposeBag()
    private var usersData: [Items]?
    
    //для пагинации 
    private var pageNumber: Int?
    private var searchName: String?
    private var pagelimit: Int?
    private var indexPath: IndexPath?
    private var isPaginating = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.CellIdentifiers.forSearchVC)
        tableView.tableFooterView = UIView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        removeKeyBoard()
        
    }
    
    private func removeKeyBoard(){
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
    }
    private func presentAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    
}

//MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate{
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if var name = searchBar.text{
            
            
            if name.contains(" "){
                
                name = self.removeSpaces(in: name )
            }
            
            self.searchName = name
            DispatchQueue.main.async {
                searchBar.endEditing(true)
            }
            self.pageNumber = 1
            let searchUserService = SearchUserService()
            searchUserService.fetchUsers(with: name, page: self.pageNumber ?? 1).observeOn(MainScheduler.instance).subscribe(onNext: { searchUserData in
                self.pagelimit = searchUserData.total_count
                self.usersData = searchUserData.items
                self.tableView.reloadData()
            }).disposed(by: disposeBag)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            
            DispatchQueue.main.async {
                self.usersData = nil
                self.searchName = nil
                self.pageNumber = nil
                self.pagelimit = nil
                self.tableView.tableFooterView = nil
                self.tableView.reloadData()
                
            }
            
        }
    }
    
    private func removeSpaces(in item: String)->String{
        let array = item.components(separatedBy: " ")
        var result = String()
        for x in 0..<array.count{
            if x != array.count-1{
                result += "\(array[x])%20"
            }else {
                result += "\(array[x])"
            }
        }
        
        return result
    }
}

//MARK: - UITableViewDataSource methods
extension SearchViewController: UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.forSearchVC, for: indexPath) as! SearchTableViewCell
        cell.loginLabel.text = usersData?[indexPath.row].login
        cell.typeLabel.text = usersData?[indexPath.row].type
        if let imageUrl = URL(string: usersData?[indexPath.row].avatar_url ?? ""){
            self.setCellImage(on: cell, with: imageUrl)
        }
        
        return cell
    }
    
    private func setCellImage(on cell: SearchTableViewCell, with imageUrl: URL ){
        let processor = DownsamplingImageProcessor(size: cell.imageCover.bounds.size) |> RoundCornerImageProcessor(cornerRadius: 40)
        cell.imageCover.kf.indicatorType = .activity
        cell.imageCover.kf.setImage(
            with: imageUrl,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.5)),
                .cacheOriginalImage
        ])
        
    }
    
    
}

//MARK: - UITableViewDelegate Methods

extension SearchViewController: UITableViewDelegate, UIScrollViewDelegate{
    
    
    //MARK: - Пагинация
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard self.usersData?.count != nil, self.pagelimit != nil, self.pageNumber != nil else { return }
        
        guard !(self.usersData!.count >= self.pagelimit!) else {return}
        
        let position = scrollView.contentOffset.y
        
        if position > (tableView.contentSize.height - 10 - scrollView.frame.height){
            
            
            if !self.isPaginating {
                self.isPaginating = true
                self.tableView.tableFooterView = createSpinnerFooter()
                
                if self.pageNumber != nil{
                    self.pageNumber! += 1
                }else { return }
                guard let name = self.searchName else { return }
                let searchUserService = SearchUserService()
                searchUserService.fetchUsers(with: name, page: self.pageNumber!).observeOn(MainScheduler.instance).subscribe(onNext: {  searchUserData in
                    self.tableView.tableFooterView = nil
                    self.isPaginating = false
                    self.usersData?.append(contentsOf: searchUserData.items)
                    self.tableView.reloadData()
                }).disposed(by: disposeBag)
                
            }
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
        
    }
    
    //MARK: - Swipe Gestures
    
    //swipe from left
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let ToLink = goToLink(at: indexPath)
        return UISwipeActionsConfiguration(actions:[ToLink])
    }
    
    private func goToLink(at indexPath: IndexPath) -> UIContextualAction{
        
        let action = UIContextualAction(style: .normal, title: "Перейти") { (action, view, completion) in
            self.indexPath = indexPath
            self.performSegue(withIdentifier: Constants.Segue.searchToWeb, sender: self)
            completion(true)
            
        }
        
        action.image = UIImage(named: "safari")
        action.backgroundColor = .blue
        return action
    }
    
    
}

//MARK: - Segues and Navigation

extension SearchViewController{
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.searchToInfo {
            
            if let indexPath = tableView.indexPathForSelectedRow{
                
                let infoVC = segue.destination as! InformationViewController
                infoVC.userData = usersData?[indexPath.row]
                tableView.deselectRow(at: indexPath, animated: true)
            }
            
        }else if segue.identifier == Constants.Segue.searchToWeb{
            let webVC = segue.destination as! WebViewController
            if let indexPath = self.indexPath{
                webVC.urlstring = usersData?[indexPath.row].html_url
                tableView.deselectRow(at: indexPath, animated: true)
                self.indexPath = nil
            }
        }
    }
}


