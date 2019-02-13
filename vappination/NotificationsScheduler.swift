//
//  NotificationsScheduler.swift
//  vappination
//
//  Created by Waseel ASP Ltd. on 8/18/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import Foundation
import UIKit
import Localize_Swift

class NotificationsScheduler {
    
    static func schedule(_ vaccinations: NSSet, childName: String, childId: Int) {
        let toBeScheduledVaccinations = (vaccinations.allObjects as? [Vaccination])?.sorted {
            $0.stage_id!.localizedCaseInsensitiveCompare($1.stage_id!) == ComparisonResult.orderedAscending
        }
        
        for vaccination in toBeScheduledVaccinations! {
            // if vaccination.date >= today
            // if vaccination.date - one month >= today
            // if vaccination.date - 7 days >= today
            // if vaccination.date - 1 day >= today
            let dueDate = vaccination.due_on!
            let currentDate = Date()
            if dueDate.sameDate(currentDate) || dueDate.greaterDate(currentDate) {
                let vaccinationStage = Vaccinations.stages()[Int(vaccination.stage_id!)!]
                let stageName = Localize.currentLanguage() == "ar" ? vaccinationStage.descAr : vaccinationStage.descEn
                if addNotificationAMonthAgo(dueDate, currentDate: currentDate, childName: childName, childId: childId, vaccinationStage: stageName) {
                    //continue
                }
                if addNotificationAWeekAgo(dueDate, currentDate: currentDate, childName: childName, childId: childId, vaccinationStage: stageName) {
                    continue
                }
                else if addNotificationADayAgo(dueDate, currentDate: currentDate, childName: childName, childId: childId, vaccinationStage: stageName) {
                    continue
                }
                else if addNotificationNow(dueDate, currentDate: currentDate, childName: childName, childId: childId, vaccinationStage: stageName) {
                    continue
                }
            }
        }
    }
    
    static func unschedule(_ childId: Int) {
        let app: UIApplication = UIApplication.shared
        for notif in app.scheduledLocalNotifications! {
            //let localNotif = notif
            let userInfo = notif.userInfo as! [String:AnyObject]
            let child = userInfo["child"]! as! Int
            if child == childId {
                app.cancelLocalNotification(notif)
            }
        }
    }
    
    static func reschedule(_ vaccinations: NSSet, childName: String, childId: Int) {
        unschedule(childId)
        schedule(vaccinations, childName: childName, childId: childId)
    }
    
    static fileprivate func addNotificationAMonthAgo(_ dueDate: Date, currentDate: Date, childName: String, childId: Int, vaccinationStage: String) -> Bool {
        var aMonthAgoDate = (Calendar.current as NSCalendar).date(byAdding: .month, value: -1,
                                                                          to: dueDate, options:NSCalendar.Options(rawValue: 0))
        if aMonthAgoDate!.sameDate(currentDate) || aMonthAgoDate!.greaterDate(currentDate) {
            aMonthAgoDate = setNotificationTimeWithZone(aMonthAgoDate!)
            // Localization
            addLocalNotification(aMonthAgoDate!, childName: childName, childId: childId, when: "next vaccination is due in 1 month.".localized(), vaccinationStage: "\("Required at".localized()) \(vaccinationStage).")
            return true
        }
        return false
    }
    
    static fileprivate func addNotificationAWeekAgo(_ dueDate: Date, currentDate: Date, childName: String, childId: Int, vaccinationStage: String) -> Bool {
        var aWeekAgoDate = (Calendar.current as NSCalendar).date(byAdding: .day, value: -7,
                                                                          to: dueDate, options:NSCalendar.Options(rawValue: 0))
        if aWeekAgoDate!.sameDate(currentDate) || aWeekAgoDate!.greaterDate(currentDate) {
            aWeekAgoDate = setNotificationTimeWithZone(aWeekAgoDate!)
            // Localization
            addLocalNotification(aWeekAgoDate!, childName: childName, childId: childId, when: "next vaccination is due in 7 days.".localized(), vaccinationStage: "\("Required at".localized()) \(vaccinationStage).")
            return true
        }
        return false
    }
    
    static fileprivate func addNotificationADayAgo(_ dueDate: Date, currentDate: Date, childName: String, childId: Int, vaccinationStage: String) -> Bool {
        var aDayAgoDate = (Calendar.current as NSCalendar).date(byAdding: .day, value: -1,
                                                                         to: dueDate, options:NSCalendar.Options(rawValue: 0))
        if aDayAgoDate!.sameDate(currentDate) || aDayAgoDate!.greaterDate(currentDate) {
            aDayAgoDate = setNotificationTimeWithZone(aDayAgoDate!)
            // Localization
            addLocalNotification(aDayAgoDate!, childName: childName, childId: childId, when: "next vaccination is due in 1 day.".localized(), vaccinationStage: "\("Required at".localized()) \(vaccinationStage).")
            return true
        }
        return false
    }
    
    static fileprivate func addNotificationNow(_ dueDate: Date, currentDate: Date, childName: String, childId: Int, vaccinationStage: String) -> Bool {
        
        if dueDate.sameDate(currentDate) {
            // Localization
            addLocalNotification(Date(timeIntervalSinceNow: 5), childName: childName, childId: childId, when: "next vaccination is due Today.".localized(), vaccinationStage: "\("Required at".localized()) \(vaccinationStage).")
            return true
        }
        return false
    }
    
    static fileprivate func setNotificationTimeWithZone(_ fireDate: Date) -> Date {
        let fixedDate = (Calendar.current as NSCalendar).date(bySettingHour: 07, minute: 00, second: 00, of: fireDate, options: NSCalendar.Options(rawValue: 0))
        return fixedDate!
    }
    
    static fileprivate func addLocalNotification(_ fireDate: Date, childName: String, childId: Int, when: String, vaccinationStage: String) {
        //print("child name: \(childName)")
        //print("vaccination stage: \(vaccinationStage)")
        //print("scheduling at: \(fireDate)")
        
        let notification = UILocalNotification()
        notification.fireDate = fireDate
        notification.alertBody = "\(childName), \(when) \(vaccinationStage)"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["child": childId]
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    
    static func unscheduledAll() {
        UIApplication.shared.cancelAllLocalNotifications()
    }
    
}
extension Date {
    
    /**
     Compares current date with the given one down to the seconds.
     If date==nil, then always return false
     
     :param: date date to compare or nil
     
     :returns: true if the dates has equal years, months, days, hours, minutes and seconds.
     */
    func sameDate(_ date: Date?) -> Bool {
        if let d = date {
            let calendar = Calendar.current
            if ComparisonResult.orderedSame == (calendar as NSCalendar).compare(self, to: d, toUnitGranularity: NSCalendar.Unit.day) {
                return true
            }
            
        }
        return false
    }
    
    func greaterDate(_ date: Date?) -> Bool {
        if let d = date {
            let calendar = Calendar.current
            if ComparisonResult.orderedDescending == (calendar as NSCalendar).compare(self, to: d, toUnitGranularity: NSCalendar.Unit.day) {
                return true
            }
            
        }
        return false
    }
    
    func smallerDate(_ date: Date?) -> Bool {
        if let d = date {
            let calendar = Calendar.current
            if ComparisonResult.orderedAscending == (calendar as NSCalendar).compare(self, to: d, toUnitGranularity: NSCalendar.Unit.day) {
                return true
            }
            
        }
        return false
    }
}
