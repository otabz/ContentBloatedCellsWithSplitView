//
//  RemindersVC.swift
//  vappination
//
//  Created by Waseel ASP Ltd. on 8/28/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreData
import Localize_Swift

class RemindersVC: UIViewController, ReminderRescheduleDelegate {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var btnClearAll: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reminderSettings: UIButton!
    @IBOutlet weak var lblTip: UILabel!
    @IBOutlet weak var lblFooter: UILabel!
    
    var children = [Children]()
    
    lazy var Context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    override func viewDidLoad() {
        headerView.layer.cornerRadius = headerView.frame.height/2
        btnClearAll.layer.cornerRadius = btnClearAll.frame.height/2
        let notificationType = UIApplication.shared.currentUserNotificationSettings!.types
        if notificationType == UIUserNotificationType() {
            reminderSettings.setTitle("Reminders are Off".localized(), for: UIControlState())
            reminderSettings.setTitleColor(UIColor.red, for: UIControlState())
        }else{
            reminderSettings.setTitle("Reminders are On".localized(), for: UIControlState())
            reminderSettings.setTitleColor(UIColor.green, for: UIControlState())
        }

        UITableViewCell.appearance().backgroundColor = UIColor.clear
        prepare()
        localize()
    }
    
    func prepare() {
        children.removeAll()
        let child = loadChildren()
        for each in child {
            children.append(Children(id: Int(each.id!), name: each.name!, reminders: self.loadReminders(Int(each.id!))))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    @IBAction func close(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func go(_ sender: UIButton) {
        self.dismiss(animated: false, completion: {
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(children[section].reminders.count)
        return (children[section].reminders.count)
    }

    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "row")
        let reminder = children[indexPath.section].reminders[indexPath.row]
        cell?.textLabel?.text = reminder.title
        let title  = reminder.title.components(separatedBy: ", ")
        if title.count > 0 {
            let vaccineName = title[1].components(separatedBy: ". ")
            if vaccineName.count > 0 {
                cell?.textLabel?.text = vaccineName[1]
            }
        }
        cell?.detailTextLabel?.text = reminder.fireDate
        return cell!
    }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        //print(children.count)
        return children.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "header") as! ReminderHeader
        headerCell.delegate = self
        headerCell.childId = children[section].id
        headerCell.name.text = children[section].name
        headerCell.btnReschedule.setTitle("Reschedule".localized(), for: UIControlState())
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 31.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func loadChildren() -> [Child] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Child")
        //fetchRequest.predicate = NSPredicate(format: "child_id == %@", NSNumber(integer: self.childId))
        var result = [Child]()
        do {
            let response = try self.Context.fetch(fetchRequest)
            if response.count > 0 {
                result = response as! [Child]
            }
        } catch let error as NSError {
            // failure
            print(error)
        }
        return result

    }
    
    func loadChild(_ id: Int) -> Child? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Child")
        fetchRequest.predicate = NSPredicate(format: "id == %@", NSNumber(value: id as Int))
        do {
            let response = try self.Context.fetch(fetchRequest)
            if response.count > 0 {
                return response[0] as? Child
            }
        } catch let error as NSError {
            // failure
            print(error)
        }
        return nil
    }
    
    func loadReminders(_ id: Int) -> [Reminder] {
        var reminders = [Reminder]()
        let app: UIApplication = UIApplication.shared
        for notif in app.scheduledLocalNotifications! {
            //let localNotif = notif
            
            if let userInfo = notif.userInfo as? [String:AnyObject] {
            let child = userInfo["child"]! as! Int
            if child == id {
                reminders.append(Reminder(title: notif.alertBody, fireDate: notif.fireDate))
            }
            }
        }
        if reminders.isEmpty {
            //very fragile
            reminders.append(Reminder(title: ", . ", fireDate: nil))
        }
        return reminders
    }
    
    @IBAction func clearAll(_ sender: UIButton) {
        NotificationsScheduler.unscheduledAll()
        prepare()
        tableView.reloadData()
    }
    
    func reschedule(_ id: Int) {
        if let child = loadChild(id) {
            NotificationsScheduler.reschedule(child.vaccinations!, childName: child.name!, childId: id)
        }
        prepare()
        tableView.reloadData()
    }
    
    func localize() {
        lblTip.text  = "If you want to check your settings,\nPlease, click button above.".localized()
        btnClearAll.setTitle("Clear All".localized(), for: UIControlState())
        lblFooter.text = "Scheduled Notifications".localized()
        if Localize.currentLanguage() == "ar" {
            // tip
            self.lblTip.textAlignment = .right
            
        }
    }
    
    class Children {
        let id: Int
        let name: String
        let reminders: [Reminder]
        
        required init(id: Int, name: String, reminders: [Reminder]) {
            self.id = id
            self.name = name
            self.reminders = reminders
        }
    }
    
    class Reminder {
        let title: String
        let fireDate: String
        
        required init(title: String?, fireDate: Date?) {
            if let t = title {
                self.title = t
            } else {
                self.title = ""
            }
            if let d = fireDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = DateFormatter.Style.medium
                self.fireDate = dateFormatter.string(from: d)
            } else {
                self.fireDate = ""
            }
        }
    }

}
