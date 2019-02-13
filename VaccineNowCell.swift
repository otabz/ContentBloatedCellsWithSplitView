//
//  VaccineNowCell.swift
//  vappination
//
//  Created by Waseel ASP Ltd. on 9/8/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreData
import Localize_Swift

protocol ChildEditDelegate: class {
    func edit(_ childId: Int, sender: UIView)
}

class VaccineNowCell: UITableViewCell {

    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var pic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var stage0: UIImageView!
    @IBOutlet weak var stage1: UIImageView!
    @IBOutlet weak var stage2: UIImageView!
    @IBOutlet weak var stage3: UIImageView!
    @IBOutlet weak var stage4: UIImageView!
    @IBOutlet weak var stage5: UIImageView!
    @IBOutlet weak var stage6: UIImageView!
    @IBOutlet weak var stage7: UIImageView!
    @IBOutlet weak var stage8: UIImageView!
    
    @IBOutlet weak var stage0Label: UILabel!
    @IBOutlet weak var stage1Label: UILabel!
    @IBOutlet weak var stage2Label: UILabel!
    @IBOutlet weak var stage3Label: UILabel!
    @IBOutlet weak var stage4Label: UILabel!
    @IBOutlet weak var stage5Label: UILabel!
    @IBOutlet weak var stage6Label: UILabel!
    @IBOutlet weak var stage7Label: UILabel!
    @IBOutlet weak var stage8Label: UILabel!
    var childId: Int?
    var delegate: ChildEditDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        background.image = background.image?.imageFlippedForRightToLeftLayoutDirection()
    }

    @IBAction func edit(_ sender: UIButton) {
       delegate?.edit(self.childId!, sender: sender)
    }

}
