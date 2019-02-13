//
//  RestartTipVC.swift
//  vappination
//
//  Created by Waseel ASP Ltd. on 12/4/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import Localize_Swift

class RestartTipVC: UIViewController {

    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var lblRestartText: UILabel!
    @IBOutlet weak var lblRestartTip: UILabel!
    var lang: String!
    
    override func viewDidLoad() {
        self.preferredContentSize = CGSize(width: 320, height: 480)
        btnDone.layer.cornerRadius = btnDone.frame.height/2
        localize()
    }
    
    @IBAction func close(_ sender: UIButton) {
        self.performSegue(withIdentifier: "exit", sender: self)
    }
    
    func localize() {
        if lang == "en" {
        btnDone.setTitle("Got it", for: UIControlState())
        lblRestartText.text = "Please, restart the application"
        lblRestartTip.text = "Language will change after clearing the application from background and starting it again."
        } else {
            btnDone.setTitle("فهمتك", for: UIControlState())
            lblRestartText.text = "من فضلك، إعادة تشغيل التطبيق"
            lblRestartTip.text = "سوف تتغير لغة بعد إزالة التطبيق من خلفية والبدء من جديد ."

        }
    }
}
