//
//  InformationViewController.swift
//  Gittify
//
//  Created by Ebubechukwu Dimobi on 12.08.2020.
//  Copyright © 2020 blazeapps. All rights reserved.
//

import UIKit
import RxSwift
import Kingfisher

class InformationViewController: UIViewController {
    @IBOutlet weak var imageCover: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var dateCreatedLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var repoNumberLabel: UILabel!
    let disposeBag = DisposeBag()
    var userData: Items?
    var repos: [RepoData]?
    var extraUserData: ExtraUserData?
    var selectedCellIndexPath: IndexPath?
    var previousSelectedRow: Int?
    
    //для пагинации
    private var isPaginating = false
    private var pageNumber: Int?
    private var pagelimit: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "InfoTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.CellIdentifiers.forInfoVC)
        navigationItem.title = userData?.login
        getData()
        self.setImage()
        
    }
    
    private func getData() {
        let getMoreInfoService = GetMoreInfoService()
        if let URL = userData?.url{
            getMoreInfoService.fetchMoreInfo(with: URL).observeOn(MainScheduler.instance).subscribe(onNext: { extraUserData in
                self.extraUserData = extraUserData
                self.updateOutlets()
            }).disposed(by: disposeBag)
        }
        
        self.pageNumber = 1
        let getReposService = GetRepoService()
        if let repoURL = userData?.repos_url{
            getReposService.fetchRepoData(with: repoURL, page: 1).observeOn(MainScheduler.instance).subscribe(onNext: { repos in
                self.repos = repos
                self.pagelimit = self.extraUserData?.public_repos
                self.tableView.reloadData()
            }).disposed(by: disposeBag)
        }
        
    }
    
    private func updateOutlets(){
        fullNameLabel.text = extraUserData?.name ?? "Имя Не Показано"
        locationLabel.text = extraUserData?.location ?? "Локейшн не Показан"
        repoNumberLabel.text = String(extraUserData?.public_repos ?? 0)
        if let date = extraUserData?.created_at{
            dateCreatedLabel.text = getDate(with: date)
        }
    }
    
    private func getDate(with date: String) -> String?{
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let convDate = dateFormatter.date(from: date){
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            return dateFormatter.string(from: convDate)
        }else{
            return nil
        }
    }
    
    private func setImage(){
        
        if let imageUrl = URL(string: userData?.avatar_url ?? ""){
            
            
            let processor = DownsamplingImageProcessor(size: imageCover.bounds.size) |> RoundCornerImageProcessor(cornerRadius: 40)
            imageCover.kf.indicatorType = .activity
            imageCover.kf.setImage(
                with: imageUrl,
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(0.5)),
                    .cacheOriginalImage
            ]){
                result in
                switch result{
                case .failure(_):
                    self.presentAlert("Server Error", message: "Can not load next Image.Connect to the internet")
                case .success(_):
                    break
                }
            }
        }
    }
    
    private func presentAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    
}

//MARK: - UITableViewDataSource methods
extension InformationViewController: UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.repos?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.forInfoVC, for: indexPath) as! InfoTableViewCell
        
        cell.showDelegate = self
        cell.hideDelegate = self
        cell.showButtonOutlet.tag = indexPath.row
        if indexPath == self.selectedCellIndexPath{
            cell.showButtonOutlet.isHidden = true
        }else{
            cell.showButtonOutlet.isHidden = false
        }
        
        cell.repoName.text = repos?[indexPath.row].name
        cell.repoLang.text = repos?[indexPath.row].language ?? "Не Показан"
        cell.starDate.text = String(repos?[indexPath.row].stargazers_count ?? 0)
        if let date = repos?[indexPath.row].updated_at{
            cell.updateDate.text = getDate(with: date)
        }
        
        return cell
    }
    
}

//MARK: - UITableViewDelegate Methods

extension InformationViewController: UITableViewDelegate, UIScrollViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return selectedCellIndexPath?.row == indexPath.row ? Constants.cellsizes.forSelected : Constants.cellsizes.forUnselected
    }
    
    
    //MARK: - ПАГИНАЦИЯ
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard self.repos != nil, self.pagelimit != nil, self.pageNumber != nil else { return }
        
        let position = scrollView.contentOffset.y
        
        if position > (tableView.contentSize.height - 10 - scrollView.frame.height){
            
            guard  !(self.pageNumber! > self.pagelimit! / Constants.resultsPerPage) else { return }
            
            if !self.isPaginating {
                self.isPaginating = true
                self.tableView.tableFooterView = createSpinnerFooter()
                
                if self.pageNumber != nil{
                    self.pageNumber! += 1
                }else { return }
                guard let url = self.userData?.repos_url else { return }
                let getRepoService = GetRepoService()
                getRepoService.fetchRepoData(with: url, page: self.pageNumber!).observeOn(MainScheduler.instance).subscribe(onNext: {  repos in
                    self.tableView.tableFooterView = nil
                    self.isPaginating = false
                    self.repos?.append(contentsOf: repos)
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
}

//MARK: - Custom InfoTableViewCellDelegate Methods
extension InformationViewController: InfoTableViewCellDelegate {
    
    func showButtonPressed(on showButtonOutlet: UIButton, row: Int) {
        self.selectedCellIndexPath = [0,row]
        if self.previousSelectedRow != nil {
            tableView.reloadRows(at: [[0,self.previousSelectedRow!]], with: .fade)
            self.previousSelectedRow = nil
        }
        tableView.reloadRows(at: [[0,row]], with: .fade)
        self.selectedCellIndexPath = nil
        self.previousSelectedRow = row
    }
    
    func hideButtonPressed(on hideButton: UIButton, row: Int) {
        self.selectedCellIndexPath = [0,row]
        self.selectedCellIndexPath = nil
        self.previousSelectedRow = nil
        tableView.reloadRows(at: [[0,row]], with: .fade)
    }
    
    
}
