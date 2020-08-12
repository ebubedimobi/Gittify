//
//  InformationViewController.swift
//  Gittify
//
//  Created by Ebubechukwu Dimobi on 12.08.2020.
//  Copyright © 2020 blazeapps. All rights reserved.
//

import UIKit

class InformationViewController: UIViewController {
    @IBOutlet weak var imageCover: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var dateCreatedLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var selectedCellIndexPath: IndexPath?
    var previousSelectedRow: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "InfoTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.CellIdentifiers.forInfoVC)
        
    }
    
    
    
}

//MARK: - UITableViewDataSource methods
extension InformationViewController: UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.forInfoVC, for: indexPath) as! InfoTableViewCell
        
        cell.showDelegate = self
        cell.hideDelegate = self
        if indexPath == self.selectedCellIndexPath{
            cell.showButtonOutlet.isHidden = true
        }else{
            cell.showButtonOutlet.isHidden = false
        }
        cell.repoName.text = String(indexPath.row)
        cell.showButtonOutlet.tag = indexPath.row
        return cell
    }
    
}

//MARK: - UITableViewDelegate Methods

extension InformationViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return selectedCellIndexPath?.row == indexPath.row ? Constants.cellsizes.forSelected : Constants.cellsizes.forUnselected
    }
    
    
    
}

//MARK: - Custom InfoTableViewCellDelegate Methods
extension InformationViewController: InfoTableViewCellDelegate {
    
    func showButtonPressed(on showButtonOutlet: UIButton, row: Int) {
        self.selectedCellIndexPath = [0,row]
        if self.previousSelectedRow != nil {
            print("here")
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
