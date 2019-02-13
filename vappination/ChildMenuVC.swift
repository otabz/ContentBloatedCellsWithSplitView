//
//  ChildMenuVC.swift
//  vappination
//
//  Created by Waseel ASP Ltd. on 8/28/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import Localize_Swift

protocol ReminderRescheduleDelegate: class {
    func reschedule(_ id: Int)
}

class ChildMenuVC: UIViewController {
    
    @IBOutlet weak var switchLanguageView: UIView!
    @IBOutlet weak var remindersView: UIView!
    @IBOutlet weak var closeView: UIView!
    @IBOutlet weak var addView: UIView!
    @IBOutlet weak var lblSwitchLanguage: UILabel!
    @IBOutlet weak var lblReminders: UILabel!
    @IBOutlet weak var lblClose: UILabel!
    @IBOutlet weak var lblAddChild: UILabel!
    
    override func viewDidLoad() {
        switchLanguageView.layer.cornerRadius = switchLanguageView.frame.height/2
        remindersView.layer.cornerRadius = remindersView.frame.height/2
        addView.layer.cornerRadius = addView.frame.height/2
        closeView.layer.cornerRadius = closeView.frame.height/2
        localize()
    }

    @IBAction func close(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeLanguage(_ sender: UIButton) {
        var selectedLanguage = "en"
        if Localize.currentLanguage() == "en" || Localize.currentLanguage() == "ar" {
            if Localize.currentLanguage() == "en" {
                //Localize.setCurrentLanguage("ar")
                //UIView.appearance().semanticContentAttribute = .ForceRightToLeft
                selectedLanguage = "ar"
            } else if Localize.currentLanguage() == "ar" {
                //Localize.setCurrentLanguage("en")
                //UIView.appearance().semanticContentAttribute = .ForceLeftToRight
                selectedLanguage = "en"
            }
        } else {
            //Localize.setCurrentLanguage("en")
            selectedLanguage = "en"
        }
        
        //let selectedLanguage = availableLanguages().contains(language) ? language : defaultLanguage()
        if (selectedLanguage != Localize.currentLanguage()){
            UserDefaults.standard.set(selectedLanguage, forKey: "SwitchLanguageKey")
            UserDefaults.standard.synchronize()
            //NSNotificationCenter.defaultCenter().postNotificationName(LCLLanguageChangeNotification, object: nil)
        }
        
        //self.dismissViewControllerAnimated(false, completion: {
            self.performSegue(withIdentifier: "restartTip", sender: self)
        
        //})
        
        /*
        
        let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let root = storyBoard.instantiateViewControllerWithIdentifier("root")
        appDelegate.window?.rootViewController = root
        appDelegate.window?.makeKeyAndVisible()
        
        */
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "restartTip" {
            let vc = segue.destination as! RestartTipVC
            vc.lang = UserDefaults.standard.string(forKey: "SwitchLanguageKey")
        }
    }
    
    func localize() {
        lblSwitchLanguage.text = "Switch language".localized()
        lblAddChild.text = "Add child".localized()
        lblReminders.text = "Reminders".localized()
        lblClose.text = "Close".localized()
    }
    
    @IBAction func addChild(_ sender: UIButton) {
        self.performSegue(withIdentifier: "addChild", sender: self)
    }
    
    @IBAction func unwindToMenu(_ segue: UIStoryboardSegue) {
        self.dismiss(animated: false, completion: nil)
    }
}
