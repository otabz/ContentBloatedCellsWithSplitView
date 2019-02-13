//
//  AddChildVC.swift
//  vappination
//
//  Created by Waseel ASP Ltd. on 9/11/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreData
import Localize_Swift

class AddChildVC: UIViewController, UITextFieldDelegate, UIPickerViewDelegate {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var photo: UIButton!
    @IBOutlet weak var dobView: UIView!
    @IBOutlet weak var gender: UIButton!
    @IBOutlet weak var error: UIImageView!
    @IBOutlet weak var dob: UIDatePicker!
    @IBOutlet weak var selectedDate: UILabel!
    @IBOutlet weak var snap: UIButton!
    @IBOutlet weak var tipText: UILabel!
    @IBOutlet weak var dobText: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    
    let photoChangedImage = UIImage(named: "vaccine_marked")
    let photoClearedImage = UIImage(named: "camera")
    var photoData: Data?
    
    lazy var Context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    //var Context: NSManagedObjectContext!
    
    var SequenceID: Int {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Sequence")
        
        var id: Int = 0
        do {
            let result = try self.Context.fetch(fetchRequest)
            if result.count > 0 {
                let seq = result[0] as! Sequence
                id = seq.id as! Int
                id = id + 1
                seq.id = id as NSNumber?
            } else {
                // save a new form
                let entity = NSEntityDescription.entity(forEntityName: "Sequence", in: self.Context)
                // Initialize Form
                let seq = Sequence(entity: entity!, insertInto: self.Context)
                seq.id = id as NSNumber?
            }
            try self.Context.save()
            return id
        } catch {
            print(error as NSError)
        }
        return -1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = CGSize(width: 320, height: 480)
        localize()
        
        // Do any additional setup after loading the view.
        name.delegate = self
        hideKeyboardWhenTappedAround()
        dob.addTarget(self, action: #selector(AddChildVC.valueChanged), for: UIControlEvents.valueChanged)
        applyPlainShadow(photo)
        applyPlainShadow(dobView)
        applyPlainShadow(gender)
        
        guard let settings = UIApplication.shared.currentUserNotificationSettings else { return }
        if settings.types == UIUserNotificationType() {
            let notificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        valueChanged()
        name.becomeFirstResponder()
    }
    /*
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddChildVC.localize), name: LCLLanguageChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    */
    func valueChanged() {
        let formatter = NumberFormatter()
        formatter.locale = UIView.userInterfaceLayoutDirection(for: view.semanticContentAttribute) == UIUserInterfaceLayoutDirection.rightToLeft ? Locale(identifier: "ar_SA") : Locale(identifier: "en_US")
        
        let islamic = Calendar(identifier: Calendar.Identifier.islamicUmmAlQura)
        let components = (islamic as NSCalendar?)?.components(NSCalendar.Unit(rawValue: UInt.max), from: dob.date)
        
        let hijri:String = UIView.userInterfaceLayoutDirection(for: view.semanticContentAttribute) == UIUserInterfaceLayoutDirection.rightToLeft ? "\(formatter.string(from: components!.year)!)  \(DateUtil.hijriMonthName(formatter.string(from: components!.month)!))  \(formatter.string(from: components!.day)!)" : "\(DateUtil.hijriMonthName(formatter.string(from: components!.month)!))  \(formatter.string(from: components!.day)!)  \(formatter.string(from: components!.year)!)"

        self.selectedDate.text = hijri

    }
    
    func applyPlainShadow(_ view: UIView) {
        let layer = view.layer
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 5, height: 5)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 5
    }

    @IBAction func close(_ sender: UIButton) {
        //UIView.removeFromSuperview(self)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: UIButton) {
        if !validate() {
            return
        }
        
        guard let settings = UIApplication.shared.currentUserNotificationSettings else { return }
        if settings.types == UIUserNotificationType() {
            // Localization
            let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
            let alert = UIAlertController(title: "\"\(appName)\" \("Not Allowed To Send You Notifications".localized())", message: "You will not receive any alert for due vaccinations. These can be configured in Settings.".localized(), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .default, handler: { (action: UIAlertAction!) in
            }))
            alert.addAction(UIAlertAction(title: "Continue".localized(), style: .cancel, handler: { (action: UIAlertAction!) in
                self.save()
            }))
            present(alert, animated: true, completion: nil)
        }
        else {
            self.save()
        }
    }
    
    fileprivate func save() {
        // initialize child
        let context = self.Context
        let child = Child(context: context)
        child.id = self.SequenceID as NSNumber?
        child.name = self.name.text
        child.dob = self.dob.date
        child.gender = toBase(self.gender.titleLabel!.text!)
        child.pic = photoData
        child.updated_at = Date()
        child.vaccinations = makeVaccinationSchedule(child, context: context)
        // persist child
        do {
            try self.Context.save()
            self.performSegue(withIdentifier: "back", sender: self)
            NotificationsScheduler.schedule(child.vaccinations!, childName: child.name!, childId: Int(child.id!))
        } catch {
            print(error)
        }
    }
    
    fileprivate func toBase(_ gender: String) -> String {
        if gender == "Boy" || gender == "ذكر" {
            return "Boy"
        } else if gender == "Girl" || gender == "أنثى" {
            return "Girl"
        }
        return ""
    }
    
    func makeVaccinationSchedule(_ child: Child, context: NSManagedObjectContext) -> NSSet {
        var vaccinations = Set<Vaccination>()
        //Vaccinations.show()
        for each in Vaccinations.stages() {
            let vaccination = Vaccination(context: context)
            vaccination.stage_id = each.id
            vaccination.status = VaccinationStatus.Due.rawValue
            vaccination.child = child
            vaccination.due_on = estimateWhenVaccinationDue(child.dob! as Date, at: each.at)
            vaccination.vaccines = makeVaccinesSchedule(vaccination, context: context)
            vaccinations.insert(vaccination)
        }
        return vaccinations as NSSet
    }
    
    func makeVaccinesSchedule(_ stage: Vaccination, context: NSManagedObjectContext) -> NSSet {
        var vaccines = Set<Vaccine>()
        for each in Vaccinations.stages()[Int(stage.stage_id!)!].vaccines {
            let vaccine = Vaccine(context: context)
            vaccine.vaccine_id = each.id
            vaccine.status = VaccinationStatus.Due.rawValue
            vaccine.stage = stage
            vaccines.insert(vaccine)
        }
        return vaccines as NSSet
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addPhoto" {
            let vc = segue.destination as! AddPhotoVC
            vc.sourceControllerName = "add"
            vc.selectedImage = self.photoData
        }
    }
    
    func estimateWhenVaccinationDue(_ dob: Date, at: At) -> Date {
        switch(at) {
        case .At_00Birth :
           return (Calendar.current as NSCalendar).date(
                byAdding: .day,
                value: 0,
                to: dob,
                options: NSCalendar.Options(rawValue: 0))!
            
        case .At_02Months :
            return (Calendar.current as NSCalendar).date(
                byAdding: .month,
                value: 2,
                to: dob,
                options: NSCalendar.Options(rawValue: 0))!
            
        case .At_04Months :
            return (Calendar.current as NSCalendar).date(
                byAdding: .month,
                value: 4,
                to: dob,
                options: NSCalendar.Options(rawValue: 0))!
            
        case .At_06Months :
            return (Calendar.current as NSCalendar).date(
                byAdding: .month,
                value: 6,
                to: dob,
                options: NSCalendar.Options(rawValue: 0))!
            
        case .At_09Months :
            return (Calendar.current as NSCalendar).date(
                byAdding: .month,
                value: 9,
                to: dob,
                options: NSCalendar.Options(rawValue: 0))!
        case .At_12Months :
            return (Calendar.current as NSCalendar).date(
                byAdding: .month,
                value: 12,
                to: dob,
                options: NSCalendar.Options(rawValue: 0))!
            
        case .At_18Months :
            return (Calendar.current as NSCalendar).date(
                byAdding: .month,
                value: 18,
                to: dob,
                options: NSCalendar.Options(rawValue: 0))!
            
        case .At_24Months :
            return (Calendar.current as NSCalendar).date(
                byAdding: .month,
                value: 24,
                to: dob,
                options: NSCalendar.Options(rawValue: 0))!
            
        case .At_46Years :
            return (Calendar.current as NSCalendar).date(
                byAdding: .year,
                value: 4,
                to: dob,
                options: NSCalendar.Options(rawValue: 0))!
        }
    }
    
    
    @IBAction func selectGender(_ sender: UIButton) {
        // Localization
        if sender.titleLabel!.text == "Boy".localized()/*NSLocalizedString("Boy", comment: "Boy")*/ {
            sender.setTitle(/*NSLocalizedString("Girl", comment: "Girl")*/ "Girl".localized(), for: UIControlState())
        } else if sender.titleLabel!.text == "Girl".localized()/*NSLocalizedString("Girl", comment: "Girl")*/ {
            sender.setTitle(/*NSLocalizedString("Boy", comment: "Boy")*/ "Boy".localized(), for: UIControlState())
        }
    }
    @IBAction func addPhoto(_ sender: UIButton) {
       self.performSegue(withIdentifier: "addPhoto", sender: self)
    }
    
    func validate() -> Bool {
        if self.name.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            error.isHidden = false
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        error.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToAddChild(_ segue: UIStoryboardSegue) {
        if let phototVC = segue.source as? AddPhotoVC {
            photoData = phototVC.photo.image?.highQualityJPEGNSData
            if photoData != nil {
                snap.setImage(photoChangedImage, for: UIControlState())
            } else {
                snap.setImage(photoClearedImage, for: UIControlState())
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return false to ignore.
    {
        name.resignFirstResponder()
        return true
    }
    
    func localize() {
        // text fields
        gender.setTitle("Boy".localized(), for: UIControlState())
        name.placeholder = "Type child's name written on ID card".localized()
        snap.setTitle("Take a snap".localized(), for: UIControlState())
        dobText.text = "Date of birth".localized()
        tipText.text = "Why name written on ID card?\nBecause, later your insurance will be matched with this name.".localized()
        saveBtn.setTitle("Save".localized(), for: UIControlState())
        
        // views
        if Localize.currentLanguage() == "ar" {
            // snap
            self.snap.contentHorizontalAlignment = .right
            // gender
            self.gender.contentHorizontalAlignment = .right
            // dob
            dob.locale = Locale.init(identifier: "ar_SA")
            // tip
            self.tipText.textAlignment = .right
            
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

enum VaccinationStatus: String {
    case Due
    case Complete
    case Incomplete
}

extension UIImage
{
    var highestQualityJPEGNSData: Data { return UIImageJPEGRepresentation(self, 1.0)! }
    var highQualityJPEGNSData: Data    { return UIImageJPEGRepresentation(self, 0.75)!}
    var mediumQualityJPEGNSData: Data  { return UIImageJPEGRepresentation(self, 0.5)! }
    var lowQualityJPEGNSData: Data     { return UIImageJPEGRepresentation(self, 0.25)!}
    var lowestQualityJPEGNSData: Data  { return UIImageJPEGRepresentation(self, 0.0)! }
}



