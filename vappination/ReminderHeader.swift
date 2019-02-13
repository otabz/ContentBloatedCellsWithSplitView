//
//  ReminderHeader.swift
//  vappination
//
//  Created by Waseel ASP Ltd. on 8/29/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import UIKit



class ReminderHeader: UITableViewCell {
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var btnReschedule: UIButton!
    var childId: Int!
    var delegate: ReminderRescheduleDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        superView.layer.cornerRadius = superView.frame.height/2
        btnReschedule.layer.cornerRadius = btnReschedule.frame.height/2
    }
    @IBAction func reschedule(_ sender: UIButton) {
        delegate?.reschedule(self.childId)
    }

}
