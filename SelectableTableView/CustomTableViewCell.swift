//
//  CustomTableViewCell.swift
//  SelectableTableView
//
//  Created by Radu Ursache on 15/02/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var id: Int = -1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupCellUI(selected: self.isSelected)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        self.setupCellUI(selected: selected)
    }
    
    func setupCellUI(selected: Bool) {
        var imageName = ""
        
        if selected {
            imageName = "icons8-checked_filled"
        } else {
            imageName = "icons8-checked"
        }
        
        iconImageView.image = UIImage(named: imageName)
    }
    
    static func getIdentifier() -> String {
        return "customCell"
    }

}
