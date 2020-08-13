//
//  InfoTableViewCell.swift
//  Gittify
//
//  Created by Ebubechukwu Dimobi on 12.08.2020.
//  Copyright © 2020 blazeapps. All rights reserved.
//

import UIKit

protocol InfoTableViewCellDelegate {
    func showButtonPressed(on showButtonOutlet: UIButton, row: Int)
    func hideButtonPressed(on hideButton: UIButton, row: Int)
}

class InfoTableViewCell: UITableViewCell {
    @IBOutlet weak var repoName: UILabel!
    @IBOutlet weak var repoLang: UILabel!
    @IBOutlet weak var showButtonOutlet: UIButton!
    @IBOutlet weak var updateDate: UILabel!
    @IBOutlet weak var starDate: UILabel!
    @IBOutlet weak var hideButtonOutlet: UIButton!
    
    var showDelegate: InfoTableViewCellDelegate?
    var hideDelegate: InfoTableViewCellDelegate?
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func showButtonClicked(_ sender: UIButton) {

    showDelegate?.showButtonPressed(on: sender, row: sender.tag)
       
    }
    
    @IBAction func hideButtonClicked(_ sender: UIButton) {
        showButtonOutlet.isHidden = false
        hideDelegate?.hideButtonPressed(on: sender, row: sender.tag)
        
    }
    
}
