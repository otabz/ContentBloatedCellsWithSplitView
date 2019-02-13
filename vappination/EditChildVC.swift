//
//  EditChildVC.swift
//  vappination
//
//  Created by Waseel ASP Ltd. on 8/25/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreData
import Localize_Swift

class EditChildVC: UIViewController, UITextFieldDelegate {
    
    var childId: Int!
    var child: Child?
    var photoData: Data?
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var snap: UIButton!
    @IBOutlet weak var dob: UIDatePicker!
    @IBOutlet weak var gender: UIButton!
    @IBOutlet weak var selectedDate: UILabel!
    @IBOutlet weak var dobView: UIView!
    @IBOutlet weak var dobText: UILabel!
    @IBOutlet weak var tipText: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    
    let photoChangedImage = UIImage(named: "vaccine_marked")
    let photoClearedImage = UIImage(named: "camera")
    
    lazy var Context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = CGSize(width: 320, height: 480)
        localize()
        
        // formatting
        applyPlainShadow(snap)
        applyPlainShadow(dobView)
        applyPlainShadow(gender)
        
        name.delegate = self
        hideKeyboardWhenTappedAround()

        if let fetchedChild = load() {
            self.child = fetchedChild
            // name
            self.name.text = child!.name
            // photo
            if child!.pic != nil {
                photoData = child!.pic as Data?
                snap.setImage(photoChangedImage, for: UIControlState())
            }
            // dob
            dob.setDate(child!.dob! as Date, animated: true)
            convertToHijri()
            dob.isUserInteractionEnabled = false
            
            //gender
            gender.setTitle(child!.gender?.localized(), for: UIControlState())
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        convertToHijri()
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
    
    func load() -> Child? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Child")
        fetchRequest.predicate = NSPredicate(format: "id == %@", NSNumber(value: self.childId as Int))
        var result: Child
        do {
            let response = try self.Context.fetch(fetchRequest)
            if response.count > 0 {
                result = response[0] as! Child
                return result
            }
        } catch let error as NSError {
            // failure
            print(error)
        }
        return nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addPhoto" {
            let vc = segue.destination as! AddPhotoVC
            vc.sourceControllerName = "edit"
            vc.selectedImage = self.photoData
        }
    }
    
    @IBAction func close(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addPhoto(_ sender: UIButton) {
        self.performSegue(withIdentifier: "addPhoto", sender: self)
    }
    
    @IBAction func save(_ sender: UIButton) {
        let needToRescheduleNotifs = child!.name != name.text
        child!.name = name.text
        child!.pic = photoData
        child!.gender = toBase(self.gender.titleLabel!.text!)
        child!.updated_at = Date()
        // update child
        do {
            try self.Context.save()
            if needToRescheduleNotifs {
                NotificationsScheduler.reschedule(child!.vaccinations!, childName: child!.name!, childId: childId)
            }
            self.performSegue(withIdentifier: "back", sender: self)
        } catch {
            print(error)
        }
    }
    
    @IBAction func unwindToEditChild(_ segue: UIStoryboardSegue) {
        if let phototVC = segue.source as? AddPhotoVC {
            photoData = phototVC.photo.image?.highQualityJPEGNSData as Data?
            if photoData != nil {
                snap.setImage(photoChangedImage, for: UIControlState())
            } else {
                snap.setImage(photoClearedImage, for: UIControlState())
            }
        }
    }
    
    func convertToHijri() {
        let formatter = NumberFormatter()
        formatter.locale = UIView.userInterfaceLayoutDirection(for: view.semanticContentAttribute) == UIUserInterfaceLayoutDirection.rightToLeft ? Locale(identifier: "ar_SA") : Locale(identifier: "en_US")
        
        let islamic = Calendar(identifier: Calendar.Identifier.islamicUmmAlQura)
        let components = (islamic as NSCalendar?)?.components(NSCalendar.Unit(rawValue: UInt.max), from: dob.date)
        
        let hijri:String = UIView.userInterfaceLayoutDirection(for: view.semanticContentAttribute) == UIUserInterfaceLayoutDirection.rightToLeft ? "\(formatter.string(from: components!.year)!)  \(DateUtil.hijriMonthName(formatter.string(from: components!.month)!))  \(formatter.string(from: components!.day)!)" : "\(DateUtil.hijriMonthName(formatter.string(from: components!.month)!))  \(formatter.string(from: components!.day)!)  \(formatter.string(from: components!.year)!)"
        
        self.selectedDate.text = hijri
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return false to ignore.
    {
        name.resignFirstResponder()
        return true
    }
    
    @IBAction func selectGender(_ sender: UIButton) {
        // Localization
        if sender.titleLabel!.text == "Boy".localized()/*NSLocalizedString("Boy", comment: "Boy")*/ {
            sender.setTitle(/*NSLocalizedString("Girl", comment: "Girl")*/ "Girl".localized(), for: UIControlState())
        } else if sender.titleLabel!.text == "Girl".localized()/*NSLocalizedString("Girl", comment: "Girl")*/ {
            sender.setTitle(/*NSLocalizedString("Boy", comment: "Boy")*/ "Boy".localized(), for: UIControlState())
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
    
    func applyPlainShadow(_ view: UIView) {
        let layer = view.layer
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 5, height: 5)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 5
    }
    
}
