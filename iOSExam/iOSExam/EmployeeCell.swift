//
//  EmployeeCell.swift
//  iOSExam
//
//  Created by E-Science on 8/23/20.
//  Copyright © 2020 E-Science. All rights reserved.
//

import UIKit

class EmployeeCell: UITableViewCell {

    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
