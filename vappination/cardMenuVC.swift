//
//  cardMenuVC.swift
//  vappination
//
//  Created by Waseel ASP Ltd. on 7/27/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import Localize_Swift

class cardMenuVC: UIViewController {

    @IBOutlet weak var attachOptionView: UIView!
    @IBOutlet weak var pdfOptionView: UIView!
    @IBOutlet weak var closeView: UIView!
    @IBOutlet weak var lblAttach: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var lblClose: UILabel!
    
    var childId: Int!
    var gender: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        // Do any additional setup after loading the view.
        attachOptionView.layer.cornerRadius = attachOptionView.frame.height/2
        pdfOptionView.layer.cornerRadius = pdfOptionView.frame.height/2
        closeView.layer.cornerRadius = closeView.frame.height/2
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addImages" {
            let vc = segue.destination as! AttachImagesVC
            vc.childId = self.childId
            vc.gender = self.gender
        } else if segue.identifier == "pdfViewer" {
            let vc = segue.destination as! PDFViewerVC
            vc.path = PDFGenerator().generate(childId)
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(_ sender: UIButton) {
        self.performSegue(withIdentifier: "exit", sender: self)
    }
    
    func localize() {
        lblAttach.text = "Attach manual card's image".localized()
        lblGender.text = "Generate PDF to share".localized()
        lblClose.text = "Close".localized()
        
        if Localize.currentLanguage() == "ar" {
            lblAttach.textAlignment = .left
            lblGender.textAlignment = .left
            lblClose.textAlignment = .left
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
