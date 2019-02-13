//
//  VaccineHeaderCell.swift
//  vappination
//
//  Created by Waseel ASP Ltd. on 9/16/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import UIKit

class VaccineHeaderCell: UITableViewCell {
    @IBOutlet weak var symbol: UIImageView!
    @IBOutlet weak var stage: UILabel!
    @IBOutlet weak var bg: UIImageView!
    @IBOutlet weak var day: UIButton!
    @IBOutlet weak var month_year: UIButton!
    @IBOutlet weak var details: UIButton!
    var stage_id : String!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if UIView.userInterfaceLayoutDirection(for: self.semanticContentAttribute) == UIUserInterfaceLayoutDirection.rightToLeft {
            month_year.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
            //proof.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        }
    }
/*
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
*/
}
