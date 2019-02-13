//
//  PerformedVC.swift
//  vappination
//
//  Created by Waseel ASP Ltd. on 9/24/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreData
import Localize_Swift

class PerformedVC: UIViewController, UIGestureRecognizerDelegate {
    
    let boyBg = UIImage(named: "baby_boy_bg")
    let girlBg = UIImage(named: "baby_girl_bg")
    @IBOutlet weak var pickerview: UIView!
    @IBOutlet weak var date: UIDatePicker!
    @IBOutlet weak var pickerBack: UIImageView!
    @IBOutlet weak var chdate: UILabel!
    @IBOutlet weak var hijriDateView: UIView!
    @IBOutlet weak var clear: UIButton!
    var child: Child!
    var section: String!
    var rows: [String]!
    
    lazy var Context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        // Do any additional setup after loading the view.
        let tap = UITapGestureRecognizer(target: self, action: #selector(PerformedVC.dismiss))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        
        date.addTarget(self, action: #selector(AddChildVC.valueChanged), for: UIControlEvents.valueChanged)
        date.maximumDate = Date()
        date.minimumDate = child.dob as Date?
        if getDueDate().smallerDate(Date()) {
            date.date = getDueDate()
        }
        valueChanged()
        
        // theme
        if child?.gender == "Boy" {
            pickerBack.image = boyBg
        } else if child?.gender == "Girl"{
            pickerBack.image = girlBg
        }
        pickerBack.image = pickerBack.image!.imageFlippedForRightToLeftLayoutDirection()
        hijriDateView.layer.cornerRadius = hijriDateView.frame.height/2
        
        clearable()
        
    }
    
    func clearable() {
        if rows.count == 1 {
            for each in child.vaccinations! {
                if (each as! Vaccination).stage_id == section {
                    // vaccination status
                    let vaccination = each as! Vaccination
                    for v in vaccination.vaccines! {
                        let vaccine = v as! Vaccine
                        if vaccine.vaccine_id == rows[0] && vaccine.status == VaccinationStatus.Complete.rawValue {
                            self.clear.isHidden = false
                            break
                        }
                    }
                    break
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        valueChanged()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        pickerBack.layer.cornerRadius = 4.0
        pickerBack.clipsToBounds = true
    }
    
    func getDueDate() -> Date {
         let vaccination : Vaccination = child.vaccinations?.filtered(using: NSPredicate(format: "stage_id == %@", section)).first as! Vaccination
        return vaccination.due_on! as Date
    }

    func dismiss() {
        self.performSegue(withIdentifier: "exit", sender: self)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let _ = touch.view as UIView? {
            if touch.view!.isDescendant(of: self.pickerview) {
                return false
            }
        }
        return true
    }
    
    func valueChanged() {

        let formatter = NumberFormatter()
        formatter.locale = UIView.userInterfaceLayoutDirection(for: view.semanticContentAttribute) == UIUserInterfaceLayoutDirection.rightToLeft ? Locale(identifier: "ar_SA") : Locale(identifier: "en_US")
        
        let islamic = Calendar(identifier: Calendar.Identifier.islamicUmmAlQura)
        let components = (islamic as NSCalendar?)?.components(NSCalendar.Unit(rawValue: UInt.max), from: date.date)
        
        let hijri:String = UIView.userInterfaceLayoutDirection(for: view.semanticContentAttribute) == UIUserInterfaceLayoutDirection.rightToLeft ? "\(formatter.string(from: components!.year)!) \(DateUtil.hijriMonthName(formatter.string(from: components!.month)!))  \(formatter.string(from: components!.day)!)" : "\(DateUtil.hijriMonthName(formatter.string(from: components!.month)!))  \(formatter.string(from: components!.day)!)  \(formatter.string(from: components!.year)!)"
        
        self.chdate.text = hijri
        
    }

    @IBAction func save(_ sender: UIButton) {
        let vaccination : Vaccination = child.vaccinations?.filtered(using: NSPredicate(format: "stage_id == %@", section)).first as! Vaccination
        // update vaccine performed
        for row in rows {
            let vaccine : Vaccine = vaccination.vaccines?.filtered(using: NSPredicate(format: "vaccine_id == %@", row)).first as! Vaccine
            vaccine.status = VaccinationStatus.Complete.rawValue
            vaccine.performed_on = date.date
        }
        setStatus(vaccination)
        child.updated_at = Date()
        do {
            try Context.save()
        } catch {
            print(error)
        }
        self.performSegue(withIdentifier: "exit", sender: self)
    }
    
    func setStatus(_ vaccination: Vaccination) {
        var allPerformed = true
        var howMany = 0
        for vaccine in vaccination.vaccines! {
            if (vaccine as! Vaccine).status == VaccinationStatus.Due.rawValue {
                allPerformed = false
                howMany = howMany + 1
            }
        }
        if allPerformed {
            vaccination.status = VaccinationStatus.Complete.rawValue
        } else if howMany == vaccination.vaccines?.count {
            vaccination.status = VaccinationStatus.Due.rawValue
        } else {
            vaccination.status = VaccinationStatus.Incomplete.rawValue
        }
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        self.performSegue(withIdentifier: "exit", sender: self)
    }

    @IBAction func clear(_ sender: UIButton) {
        let vaccination : Vaccination = child.vaccinations?.filtered(using: NSPredicate(format: "stage_id == %@", section)).first as! Vaccination
        // update vaccine incomplete
        for row in rows {
            let vaccine : Vaccine = vaccination.vaccines?.filtered(using: NSPredicate(format: "vaccine_id == %@", row)).first as! Vaccine
            vaccine.status = VaccinationStatus.Due.rawValue
            vaccine.performed_on = nil
        }
        setStatus(vaccination)
        child.updated_at = Date()
        do {
            try Context.save()
        } catch {
            print(error)
        }
        self.performSegue(withIdentifier: "exit", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func localize() {
        // views
        if Localize.currentLanguage() == "ar" {
            date.locale = Locale.init(identifier: "ar_SA")
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
    
    func hijriMonthName(_ month: String)-> String {
        var name = ""
        switch(month) {
        case "1":
            name = "Muharram".localized()
        break
        case "2":
            name = "Safar".localized()
        break
            case "3":
                name = "Rabi' I".localized()
                break
            case "4":
                name = "Rabi' II".localized()
                break
            case "5":
                name = "Jumada I".localized()
                break
            case "6":
                name = "Jumada II".localized()
                break
            case "7":
                name = "Rajab".localized()
                break
            case "8":
                name = "Sha'ban".localized()
                break
            case "9":
                name = "Ramadan".localized()
                break
            case "10":
                name = "Shawwal".localized()
                break
            case "11":
                name = "Dhu al-Qi‘dah".localized()
                break
            case "12":
                name = "Dhu al-Hijjah".localized()
            break
        default:
            name = ""
        }
    return name
    }

}
