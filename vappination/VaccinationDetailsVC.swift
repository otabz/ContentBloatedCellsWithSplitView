//
//  VaccinationDetailsVC.swift
//  vappination
//
//  Created by Waseel ASP Ltd. on 7/27/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import Localize_Swift

class VaccinationDetailsVC: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var displayView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundImage: UIImageView!
    var gender: String?
    let boyBg = UIImage(named: "baby_boy_bg")
    let girlBg = UIImage(named: "baby_girl_bg")
    var stage: Int?
    var vaccines = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        let tap = UITapGestureRecognizer(target: self, action: #selector(VaccinationDetailsVC.dismiss))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        
        // theme
        if gender == "Boy" {
            backgroundImage.image = boyBg
        } else if gender == "Girl" {
            backgroundImage.image = girlBg
        }
        backgroundImage.image = backgroundImage.image!.imageFlippedForRightToLeftLayoutDirection()
        
        for each in Vaccinations.stages()[stage!].vaccines {
            vaccines.append(each.nameEn)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("count \(Vaccinations.stages()[section].vaccines.count)")
        return Vaccinations.stages()[self.stage!].vaccines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! VaccinationDetailsCell
        cell.desc.text = Vaccinations.details(vaccines[indexPath.row]).localized()
        cell.title.text = vaccines[indexPath.row].localized()
        //print("title \(vaccines[indexPath.row])")
        return cell
    }
    
    func dismiss() {
        self.performSegue(withIdentifier: "exit", sender: self)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let _ = touch.view as UIView? {
            if touch.view!.isDescendant(of: self.displayView) {
                return false
            }
        }
        return true
    }

    @IBAction func close(_ sender: UIButton) {
        self.performSegue(withIdentifier: "exit", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
