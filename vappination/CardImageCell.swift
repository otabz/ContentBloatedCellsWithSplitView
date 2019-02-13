//
//  CardImageCell.swift
//  vappination
//
//  Created by Waseel ASP Ltd. on 7/28/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import UIKit

class CardImageCell: UITableViewCell {

    @IBOutlet weak var takenImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
