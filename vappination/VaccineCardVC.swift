//
//  VaccineCardVC.swift
//  vappination
//
//  Created by Waseel ASP Ltd. on 9/9/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreData
import Localize_Swift

class VaccineCardVC: UIViewController, UIPopoverPresentationControllerDelegate,  ChildChangedDelegate {

    @IBOutlet weak var nextDueDuration: UILabel!
    @IBOutlet weak var nextDueView: UIView!
    @IBOutlet weak var remainingView: UIView!
    @IBOutlet weak var dashboardView: UIView!
    @IBOutlet weak var totalRemaining: UILabel!
    @IBOutlet weak var dashboardBg: UIImageView!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var lblRemaining: UILabel!
    var child: Child?
    var vaccinations: [Vaccination]?
    var vaccines: [AnyObject]?
    let due = UIImage(named: "due_date")
    let incomplete = UIImage(named: "incomplete_date")
    let complete = UIImage(named: "complete_date")
    let next = UIImage(named: "vaccine_next_small")
    var sectionClicked : Int?
    //let performedAccessoryView = UIImageView(image: UIImage(named: "vaccine_marked"))
    //let dueAccessoryView = UIImageView(image: UIImage(named: "vaccine_due"))
    var selectedSection: Int?
    var selectedRows = [Int]()
    var modalDisplayed = false
    var nextDueVaccination : Vaccination?
    //var moreSelectionAllowed = true
    @IBOutlet weak var performView: UIView!
    @IBOutlet weak var closeView: UIView!
    
    lazy var Context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        remainingView.layer.cornerRadius = remainingView.frame.height/2
        remainingView.clipsToBounds = true
        nextDueView.layer.cornerRadius = nextDueView.frame.height/2
        nextDueView.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.vaccinations = (child?.vaccinations?.allObjects as? [Vaccination])?.sorted {
            $0.stage_id!.localizedCaseInsensitiveCompare($1.stage_id!) == ComparisonResult.orderedAscending
        }
        prepareDashboard()
    }
    
    func prepareDashboard() {
        navigationItem.rightBarButtonItem?.isEnabled = child == nil ? false : true
        self.title = child?.name
        if let gender = child?.gender {
            dashboardView.isHidden = false
            
            // theme
            if gender == "Boy" {
                dashboardBg.image = UIImage(named: "baby_boy_bg")?.imageFlippedForRightToLeftLayoutDirection()
            } else {
                dashboardBg.image = UIImage(named: "baby_girl_bg")?.imageFlippedForRightToLeftLayoutDirection()
            }
            
            // formatter
            let formatter = NumberFormatter()
            formatter.locale = Localize.currentLanguage() == "ar" ? Locale(localeIdentifier: "ar_SA") : Locale(localeIdentifier: "en_US")
            
            // remaining
            let fetchRequest1 = NSFetchRequest<NSFetchRequestResult>(entityName: "Vaccine")
            let predicate1 = NSPredicate(format: "status == %@ AND stage.child == %@", VaccinationStatus.Due.rawValue, child!)
            fetchRequest1.predicate = predicate1
            
            do {
                let result = try self.Context.fetch(fetchRequest1)
                self.totalRemaining.text = formatter.string(from: NSNumber(result.count))
                self.lblRemaining.text = "remaining vaccine!".localized()
            } catch {
                let fetchError = error as NSError
                print(fetchError)
            }
            
            // next due
            let fetchRequest2 = NSFetchRequest<NSFetchRequestResult>(entityName: "Vaccination")
            let predicate2 = NSPredicate(format: "due_on >= %@ AND status == %@ AND child == %@", (Calendar.current.startOfDay(for: Date()) as CVarArg), VaccinationStatus.Due.rawValue, child!)
            fetchRequest2.predicate = predicate2
            fetchRequest2.sortDescriptors = [NSSortDescriptor(key: "due_on", ascending: true)]
            
            
            do {
                let result = try self.Context.fetch(fetchRequest2)
                if result.count > 0 {
                    nextDueVaccination = result.first as? Vaccination
                    let due_on = (result.first as! Vaccination).due_on!
                    let diff: Age = DateUtil.diff(due_on)
                    let ms = (diff.years*12 + diff.months)>1 ? "months".localized() : "month".localized()
                    let ds = diff.days>1 ? "days".localized() : "day".localized()
                    
                    let months = (diff.years*12 + diff.months) > 0 ? "\(formatter.string(from: (diff.years*12 + diff.months))!) \(ms) " : ""
                    let days = diff.days > 0 ? "\(formatter.string(from: (diff.days))!) \(ds)" : ""
                    self.nextDueDuration.text = ("\(months)  \(days)").trimmingCharacters(in: CharacterSet.whitespaces).isEmpty ? "Next due on Today".localized() : "\("Next due in".localized()) \(months)\(days)"
                    
                }
            } catch {
                let fetchError = error as NSError
                print(fetchError)
            }
            if self.nextDueDuration.text!.isEmpty {
                self.nextDueView.backgroundColor = UIColor.clear
            } else {
                self.nextDueView.backgroundColor = UIColor.white
            }

        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        //return 44.0
        return 74
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*if let sections = fetchedResultsController.sections {
         let sectionInfo = sections[section]
         return sectionInfo.numberOfObjects
         }*/
        
        if let sections = self.vaccinations {
            return (sections[section].vaccines?.count)!
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "row") as! VaccineRowCell
        
        let vaccine = (vaccinations?[indexPath.section].vaccines?.allObjects as? [Vaccine])?.sorted{
            $0.vaccine_id!.localizedCaseInsensitiveCompare($1.vaccine_id!) == ComparisonResult.orderedAscending
        }[indexPath.row]
        
        cell.headerId = vaccinations?[indexPath.section].stage_id
        cell.rowId = vaccine?.vaccine_id
        cell.status = vaccine!.status!
        let status: VaccinationStatus = VaccinationStatus(rawValue: vaccine!.status!)!
        switch(status) {
        case .Due:
            cell.accessoryView = UIImageView(image: UIImage(named: "vaccine_due"))
            break;
        case .Complete:
            cell.accessoryView = UIImageView(image: UIImage(named: "vaccine_marked"))
            break;
        case.Incomplete:
            break;
        }
        cell.textLabel?.text = Localize.currentLanguage() == "ar" ? Vaccinations.stages()[Int(cell.headerId)!].vaccines[Int(cell.rowId)!].nameAr : Vaccinations.stages()[Int(cell.headerId)!].vaccines[Int(cell.rowId)!].nameEn
        
        cell.detailTextLabel?.text = vaccine?.performed_on?.description
        
        if let d = vaccine?.performed_on {
            let formatter = DateFormatter()
            formatter.locale = Localize.currentLanguage() == "ar" ? Locale(localeIdentifier: "ar_SA") : Locale(localeIdentifier: "en_US")
            formatter.dateFormat = "dd MMMM yyyy"
            cell.detailTextLabel?.text = formatter.string(from: d as Date)
        }
        
        if status == VaccinationStatus.Complete {
            //print("header = \(cell.headerId)")
            //print("row = \(cell.rowId)")
            //print(cell.textLabel?.text)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 65.0
    }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        // 1
        // Return the number of sections.
        if let sections = self.vaccinations {
            return sections.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "header") as! VaccineHeaderCell

        let section_ = vaccinations![section]
        headerCell.stage_id = section_.stage_id
        headerCell.stage.text = Vaccinations.stages()[Int(section_.stage_id!)!].descEn.localized()
        headerCell.symbol.image = UIImage(named: Vaccinations.stages()[Int(section_.stage_id!)!].symbol)?.imageFlippedForRightToLeftLayoutDirection()
        
        if section_.child?.gender == "Boy"{
            headerCell.bg.image = UIImage(named: "baby_boy_bg")?.imageFlippedForRightToLeftLayoutDirection()
        } else {
            headerCell.bg.image = UIImage(named: "baby_girl_bg")?.imageFlippedForRightToLeftLayoutDirection()
        }
        
        let status: VaccinationStatus = VaccinationStatus(rawValue: section_.status!)!
        switch(status) {
        case .Due:
            headerCell.day.setBackgroundImage(due, for: UIControlState())
            headerCell.symbol.image = nextDueVaccination?.stage_id == section_.stage_id ? next : headerCell.symbol.image
            headerCell.stage.text = nextDueVaccination?.stage_id == section_.stage_id ? "\(headerCell.stage.text!) - \("Next".localized())" : headerCell.stage.text
            break;
        case .Complete:
            headerCell.day.setBackgroundImage(complete, for: UIControlState())
            break;
        case.Incomplete:
            headerCell.day.setBackgroundImage(incomplete, for: UIControlState())
            break;
        }
        let formatter = DateFormatter()
        formatter.locale = Localize.currentLanguage() == "ar" ? Locale(localeIdentifier: "ar_SA") : Locale(localeIdentifier: "en_US")
        formatter.dateFormat = "dd"
        headerCell.day.setTitle(formatter.string(from: section_.due_on! as Date), for: UIControlState())
        formatter.dateFormat = "MMMM yyyy"
        headerCell.month_year.setTitle(formatter.string(from: section_.due_on! as Date), for: UIControlState())
        if self.view.semanticContentAttribute == .forceRightToLeft {
            headerCell.month_year.contentHorizontalAlignment = .right
        } else {
            headerCell.month_year.contentHorizontalAlignment = .left
        }
        
        headerCell.details.tag = Int(section_.stage_id!)!
        headerCell.details.addTarget(self, action: #selector(VaccineCardVC.showDetails), for: .touchUpInside)

        return headerCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        self.selectedSection = indexPath.section
        if (tableView.cellForRow(at: indexPath) as! VaccineRowCell).status == VaccinationStatus.Complete.rawValue {
            
            //moreSelectionAllowed = false
            performSegue(withIdentifier: "performed", sender: self)
        } else if !tableView.isEditing {
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.isEditing = true
            UIView.animate(withDuration: 0.5, animations: {
            self.performView.isHidden = false
            self.closeView.isHidden = false
            })
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        
        if indexPath.section == self.selectedSection {
            /*if tableView.cellForRowAtIndexPath(indexPath)?.accessoryView == dueAccessoryView {
                return true
            }*/
            //if moreSelectionAllowed {
            //    return true
            //}
            let vaccine = (vaccinations?[indexPath.section].vaccines?.allObjects as? [Vaccine])?.sorted{
                $0.vaccine_id!.localizedCaseInsensitiveCompare($1.vaccine_id!) == ComparisonResult.orderedAscending
                }[indexPath.row]
            if vaccine?.status == VaccinationStatus.Due.rawValue {
            return true
            }
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAtIndexPath indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.init(rawValue: 3)!
    }
    
    @IBAction func closeSelectionMode(_ sender: AnyObject) {
      closeSelectionMode()
    }
    
    func closeSelectionMode() {
        self.selectedSection = nil
        table.isEditing = false
        self.performView.isHidden = true
        self.closeView.isHidden = true
    }
    
    @IBAction func perform(_ sender: UIButton) {
        let visiblePartOfTableView: CGRect = CGRect(x: table.contentOffset.x, y: table.contentOffset.y, width: table.bounds.size.width, height: table.bounds.size.height)
        if (!visiblePartOfTableView.intersects(table.rect(forSection: self.selectedSection!))) {
            table.scrollRectToVisible(table.rect(forSection: self.selectedSection!), animated: false)
        }
        if shouldPerformSegue(withIdentifier: "performed", sender: self) {
           performSegue(withIdentifier: "performed", sender: self)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //print(decelerate)
        /*if self.selectedSection != nil {
            //table.scrollRectToVisible(table.rectForSection(self.selectedSection!), animated: true)
            let visiblePartOfTableView: CGRect = CGRect(x: table.contentOffset.x, y: table.contentOffset.y, width: table.bounds.size.width, height: table.bounds.size.height)
            if (!visiblePartOfTableView.intersects(table.rectForSection(self.selectedSection!))) {
                closeSelectionMode()
            }
        }*/
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "performed" {
            self.modalDisplayed = true
            let vc = segue.destination as! PerformedVC
            var selections  = [String]()
            var section: String!
            for each in table.indexPathsForSelectedRows! {
                let c = table.cellForRow(at: each) as! VaccineRowCell
                selections.append(c.rowId)
                section = c.headerId
            }
            vc.child = self.child
            vc.section = section
            vc.rows = selections
        }
        else if segue.identifier == "details" {
            self.modalDisplayed = true
            let vc = segue.destination as! VaccinationDetailsVC
            vc.stage = self.sectionClicked
            vc.gender = child?.gender
        }
        else if segue.identifier == "options" {
            self.modalDisplayed = true
            let vc = segue.destination as! cardMenuVC
            vc.childId = Int((child?.id)!)
            vc.gender = child?.gender
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "performed" {
            if let rows = table.indexPathsForSelectedRows, !rows.isEmpty {
                return true
            } else {
                return false
            }
        }
        return true
    }
    
    @IBAction func unwindToCard(_ segue: UIStoryboardSegue) {
        self.modalDisplayed = false
        if segue.source.isKind(of: PerformedVC.self) {
            closeSelectionMode()
            table.reloadData()
            prepareDashboard()
        }
    }
    
    func showDetails(_ button: UIButton) {
        sectionClicked = button.tag
        self.performSegue(
            withIdentifier: "details", sender: self)
    }
    
    func childSelectionChanged() -> Bool {
        return self.modalDisplayed
    }
    
    func refresh() {
        table.reloadData()
        prepareDashboard()
    }
    
    func clear() {
        self.child = nil
        prepareDashboard()
        dashboardView.isHidden = true
        self.vaccinations?.removeAll()
        table.reloadData()
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
