//
//  DateUtil.swift
//  vappination
//
//  Created by Waseel ASP Ltd. on 7/24/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import Foundation

class DateUtil {
    
    static func age(_ dob: Date) -> Age {
        var Years = 0
        var Months = 0
        var Days = 0
        
        let calendar = Calendar.current
        
        let Cday = (calendar as NSCalendar).components([.day , .month , .year], from: Date())
        
        let Bday = (calendar as NSCalendar).components([.day , .month , .year], from: dob)
        
        if ((Cday.year! - Bday.year!) > 0 ||
            (((Cday.year! - Bday.year!) == 0) && ((Bday.month! < Cday.month!) ||
                ((Bday.month! == Cday.month!) && (Bday.day! <= Cday.day!)))))
        {
            //int DaysInBdayMonth = DateTime.DaysInMonth(Bday.Year, Bday.Month);
            //int DaysRemain = Cday.Day + (DaysInBdayMonth - Bday.Day);
            
            let DaysInBdayMonth = (calendar as NSCalendar).range(of: .day, in: .month, for: dob).length
            let DaysRemain = Cday.day! + (DaysInBdayMonth - Bday.day!)
            
            if (Cday.month! > Bday.month!)
            {
                Years = Cday.year! - Bday.year!;
                Months = Cday.month! - (Bday.month! + 1) + abs(DaysRemain / DaysInBdayMonth);
                Days = (DaysRemain % DaysInBdayMonth + DaysInBdayMonth) % DaysInBdayMonth;
            }
            else if (Cday.month == Bday.month)
            {
                if (Cday.day! >= Bday.day!)
                {
                    Years = Cday.year! - Bday.year!;
                    Months = 0;
                    Days = Cday.day! - Bday.day!;
                }
                else
                {
                    Years = (Cday.year! - 1) - Bday.year!;
                    Months = 11;
                    // Days = DateTime.DaysInMonth(Bday.Year, Bday.Month) - (Bday.Day - Cday.Day);
                    Days = (calendar as NSCalendar).range(of: .month, in: .year, for: dob).length - (Bday.day! - Cday.day!)
                }
            }
            else
            {
                Years = (Cday.year! - 1) - Bday.year!;
                Months = Cday.month! + (11 - Bday.month!) + abs(DaysRemain / DaysInBdayMonth);
                Days = (DaysRemain % DaysInBdayMonth + DaysInBdayMonth) % DaysInBdayMonth;
            }
        }
        /*else
         {
         throw new ArgumentException("Birthday date must be earlier than current date");
         }*/
        return Age(years: Years, months: Months, days: Days)
    }
    
    static func diff(_ dob: Date) -> Age {
        var Years = 0
        var Months = 0
        var Days = 0
        
        let calendar = Calendar.current
        
        let Cday = (calendar as NSCalendar).components([.day , .month , .year], from: dob)
        
        let Bday = (calendar as NSCalendar).components([.day , .month , .year], from: Date())
        
        if ((Cday.year! - Bday.year!) > 0 ||
            (((Cday.year! - Bday.year!) == 0) && ((Bday.month! < Cday.month!) ||
                ((Bday.month! == Cday.month!) && (Bday.day! <= Cday.day!)))))
        {
            //int DaysInBdayMonth = DateTime.DaysInMonth(Bday.Year, Bday.Month);
            //int DaysRemain = Cday.Day + (DaysInBdayMonth - Bday.Day);
            
            let DaysInBdayMonth = (calendar as NSCalendar).range(of: .day, in: .month, for: dob).length
            let DaysRemain = Cday.day! + (DaysInBdayMonth - Bday.day!)
            
            if (Cday.month! > Bday.month!)
            {
                Years = Cday.year! - Bday.year!;
                Months = Cday.month! - (Bday.month! + 1) + abs(DaysRemain / DaysInBdayMonth);
                Days = (DaysRemain % DaysInBdayMonth + DaysInBdayMonth) % DaysInBdayMonth;
            }
            else if (Cday.month == Bday.month)
            {
                if (Cday.day! >= Bday.day!)
                {
                    Years = Cday.year! - Bday.year!;
                    Months = 0;
                    Days = Cday.day! - Bday.day!;
                }
                else
                {
                    Years = (Cday.year! - 1) - Bday.year!;
                    Months = 11;
                    // Days = DateTime.DaysInMonth(Bday.Year, Bday.Month) - (Bday.Day - Cday.Day);
                    Days = (calendar as NSCalendar).range(of: .month, in: .year, for: dob).length - (Bday.day! - Cday.day!)
                }
            }
            else
            {
                Years = (Cday.year! - 1) - Bday.year!;
                Months = Cday.month! + (11 - Bday.month!) + abs(DaysRemain / DaysInBdayMonth);
                Days = (DaysRemain % DaysInBdayMonth + DaysInBdayMonth) % DaysInBdayMonth;
            }
        }
        /*else
         {
         throw new ArgumentException("Birthday date must be earlier than current date");
         }*/
        return Age(years: Years, months: Months, days: Days)
    }
    
    static func hijriMonthName(_ month: String)-> String {
        // Localization
        var name = ""
        switch(month.localized()) {
        case "1".localized():
            name = "Muharram".localized()
            break
        case "2".localized():
            name = "Safar".localized()
            break
        case "3".localized():
            name = "Rabi I".localized()
            break
        case "4".localized():
            name = "Rabi II".localized()
            break
        case "5".localized():
            name = "Jumada I".localized()
            break
        case "6".localized():
            name = "Jumada II".localized()
            break
        case "7".localized():
            name = "Rajab".localized()
            break
        case "8".localized():
            name = "Sha'ban".localized()
            break
        case "9".localized():
            name = "Ramadan".localized()
            break
        case "10".localized():
            name = "Shawwal".localized()
            break
        case "11".localized():
            name = "Dhu al-Qi'dah".localized()
            break
        case "12".localized():
            name = "Dhu al-Hijjah".localized()
            break
        default:
            name = ""
        }
        return name
    }


}
