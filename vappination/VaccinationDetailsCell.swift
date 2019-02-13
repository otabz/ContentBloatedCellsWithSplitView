//
//  VaccinationDetailsCell.swift
//  vappination
//
//  Created by Waseel ASP Ltd. on 7/27/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import UIKit

class VaccinationDetailsCell: UITableViewCell {

    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
