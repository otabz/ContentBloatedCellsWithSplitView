//
//  ViewController.swift
//  vappination
//
//  Created by Waseel ASP Ltd. on 9/8/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreData
import Localize_Swift

protocol ChildChangedDelegate: class {
    func childSelectionChanged()-> Bool
    func refresh()
    func clear()
}
// 0.6 height for bell
class ViewController: UIViewController, UISplitViewControllerDelegate, UIPopoverPresentationControllerDelegate, NSFetchedResultsControllerDelegate, ChildEditDelegate {
    
    var selection: Child!
    @IBOutlet weak var tableView: UITableView!
    var delegate: ChildChangedDelegate?
    var popOverBoundView: UIView?
    var popOverChildId: Int?
    let defaultBabyImage = UIImage(named: "baby_saadi")
    @IBOutlet weak var anchor: UIButton!
    var showMenu = true
    
    lazy var Context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    lazy var fetchResultsController : NSFetchedResultsController = { () -> <<error type>> in 
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Child")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dob", ascending: true)]
        //let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.Context, sectionNameKeyPath: nil, cacheName: nil)
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        localize()
        self.splitViewController?.delegate = self
        self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible
        self.fetchResultsController.delegate = self
        do {
            try fetchResultsController.performFetch()
            //print(fetchResultsController.sections?[0].numberOfObjects)
        } catch let error {
            print(error)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if fetchResultsController.fetchedObjects == nil || fetchResultsController.fetchedObjects!.isEmpty {
            if showMenu {
                self.performSegue(withIdentifier: "childMenu", sender: self)
                showMenu = false
            }
        }
    }
    /*
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.localize), name: LCLLanguageChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.fetchResultsController.sections?[section].numberOfObjects)!
    }
    
      func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! VaccineNowCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
     func tableView(_ tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath) {
        let vc = cell as! VaccineNowCell
        vc.pic.layer.cornerRadius = vc.pic.layer.frame.size.height / 2
        vc.pic.clipsToBounds = true
        vc.pic.layer.borderColor = UIColor.lightGray.cgColor
        if Localize.currentLanguage() == "ar" {
        vc.background.semanticContentAttribute = .forceRightToLeft
        }
        
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: IndexPath) -> Bool {
        if let d = self.delegate, d.childSelectionChanged() {
          return false
        }
        return true
    }
    
      func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
            self.selection = self.fetchResultsController.object(at: indexPath) as! Child
            self.performSegue(withIdentifier: "card", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "card" {
            //let index = tableView.indexPathForSelectedRow! as NSIndexPath
            let nav = segue.destination as! UINavigationController
            let vc = nav.viewControllers[0] as! VaccineCardVC
            vc.child = self.selection
            self.delegate = vc
            //tableView.deleteRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.Fade)
        } else if segue.identifier == "addCard" {
            let vc = segue.destination
            if let pop = vc.popoverPresentationController {
                pop.delegate = self
            }
        } else if segue.identifier == "editChild" {
            let vc = segue.destination as! EditChildVC
            vc.childId = self.popOverChildId
            /*if let pop = vc.popoverPresentationController {
                pop.delegate = self
                pop.sourceView = self.popOverBoundView
                pop.sourceRect = self.popOverBoundView!.bounds
            }*/
        } else if segue.identifier == "addChild" {
            let vc = segue.destination as! AddChildVC
            vc.Context = self.Context
            /*if let pop = vc.popoverPresentationController {
                pop.delegate = self
                pop.sourceView = anchor
                pop.sourceRect = anchor!.bounds
            }*/
        }
    }
    
    /*func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }*/
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
    func configureCell(_ cell: VaccineNowCell, atIndexPath indexPath: IndexPath) {
        let child = fetchResultsController.object(at: indexPath) as! Child
        if child.name != nil {
            
            // vaccination progress
            let vaccinations = (child.vaccinations?.allObjects as? [Vaccination])?.sorted {
                $0.stage_id!.localizedCaseInsensitiveCompare($1.stage_id!) == ComparisonResult.orderedAscending
            }

            var isNextDue = false
            for each in vaccinations! {
                var status = each.status == VaccinationStatus.Complete.rawValue ? UIImage(named: "vaccine_done") : UIImage(named: "vaccine_not_done")
                var increaseRequired = false
                if !isNextDue && each.status == VaccinationStatus.Due.rawValue {
                    isNextDue = (each.due_on!.sameDate(Date()) || each.due_on!.greaterDate(Date())) ? true : false
                    status = isNextDue ? UIImage(named: "vaccine_next_small") : status
                    increaseRequired = true
                    
                }
                if each.stage_id == "0" {
                    cell.stage0.image = status
                    adjust(cell, shouldIncreased: increaseRequired, label: cell.stage0Label)
                } else if each.stage_id == "1" {
                    adjust(cell, shouldIncreased: increaseRequired, label: cell.stage1Label)
                    cell.stage1.image = status
                } else if each.stage_id == "2" {
                    cell.stage2.image = status
                    adjust(cell, shouldIncreased: increaseRequired, label: cell.stage2Label)
                } else if each.stage_id == "3" {
                    cell.stage3.image = status
                    adjust(cell, shouldIncreased: increaseRequired, label: cell.stage3Label)
                } else if each.stage_id == "4" {
                    cell.stage4.image = status
                    adjust(cell, shouldIncreased: increaseRequired, label: cell.stage4Label)
                } else if each.stage_id == "5" {
                    cell.stage5.image = status
                    adjust(cell, shouldIncreased: increaseRequired, label: cell.stage5Label)
                } else if each.stage_id == "6" {
                    cell.stage6.image = status
                    adjust(cell, shouldIncreased: increaseRequired, label: cell.stage6Label)
                } else if each.stage_id == "7" {
                    cell.stage7.image = status
                    adjust(cell, shouldIncreased: increaseRequired, label: cell.stage7Label)
                } else if each.stage_id == "8" {
                    cell.stage8.image = status
                    adjust(cell, shouldIncreased: increaseRequired, label: cell.stage8Label)
                }
            }

            
            if child.gender == "Boy" {
                cell.background.image = UIImage(named: "baby_boy_bg")
            } else if child.gender == "Girl" {
                cell.background.image = UIImage(named: "baby_girl_bg")
            }
            cell.name.text = child.name
            
            let formatter = NumberFormatter()
            formatter.locale = UIView.userInterfaceLayoutDirection(for: view.semanticContentAttribute) == UIUserInterfaceLayoutDirection.rightToLeft ? Locale(identifier: "ar_SA") : Locale(identifier: "en_US")
            
            let childAge = DateUtil.age(child.dob!)
            let ms = (childAge.years*12 + childAge.months)>1 ? "months".localized() : "month".localized()
            let ds = childAge.days>1 ? "days".localized() : "day".localized()
            
            let months = (childAge.years*12 + childAge.months) > 0 ? "\(formatter.string(from: (childAge.years*12 + childAge.months))!) \(ms) " : ""
            let days = childAge.days > 0 ? "\(formatter.string(from: (childAge.days))!) \(ds)" : ""
            
            cell.age.text = ("\(months)  \(days)").trimmingCharacters(in: CharacterSet.whitespaces).isEmpty ? "0 day".localized() : "\(months)\(days)"
            
            
            if child.pic != nil {
                setImage(cell.pic, data: child.pic!)
            } else {
                setImage(cell.pic, data: self.defaultBabyImage!.highQualityJPEGNSData as Data)
            }
            
            cell.childId = Int(child.id!)
            cell.delegate = self
            
            //if Localize.currentLanguage()=="ar" {
                cell.stage0Label.text = "0".localized()
                cell.stage1Label.text = "2".localized()
                cell.stage2Label.text = "4".localized()
                cell.stage3Label.text = "6".localized()
                cell.stage4Label.text = "9".localized()
                cell.stage5Label.text = "12".localized()
                cell.stage6Label.text = "18".localized()
                cell.stage7Label.text = "24".localized()
                cell.stage8Label.text = "4-6".localized()
            //}
            
        }
    }
    
    func setImage(_ view: UIImageView, data: Data) {
        guard let imageData = UIImage(data: data) else {
            // handle failed conversion
            //print("jpg error")
            return
        }
        view.image = imageData
    }
    
    func adjust(_ cell: VaccineNowCell, shouldIncreased: Bool, label: UILabel) {
        
        label.textColor = shouldIncreased ? UIColor.red : UIColor.black
        label.font = shouldIncreased ? label.font.withSize(16) : label.font.withSize(15)
        //normalConstraint?.priority = shouldIncreased ? 250 : 750
        //increasedConstraint?.priority = shouldIncreased ? 750 : 250
        UIView.animate(withDuration: 0.5, animations: {
            cell.layoutIfNeeded()
        })
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch(type) {
        case .insert :
            //print("insert")
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            break;
        case .delete:
            //print("delete")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            if let d = self.delegate {
                d.clear()
            }
            break;
        case .update:
            //print("update")
            if let indexPath = indexPath {
                let cell = tableView.cellForRow(at: indexPath) as! VaccineNowCell
                configureCell(cell, atIndexPath: indexPath)
            }
            if let d = self.delegate {
                d.refresh()
            }
            break;
        case .move:
                //print("move")
                if let indexPath = indexPath {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
                
                if let newIndexPath = newIndexPath {
                    tableView.insertRows(at: [newIndexPath], with: .fade)
                    tableView.scrollToRow(at: newIndexPath, at: .middle, animated: true)
                }
                
            break;
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    @IBAction func unwindToChilds(_ segue: UIStoryboardSegue) {
    }
    
    func edit(_ childId: Int, sender: UIView) {
        
        if let d = self.delegate, d.childSelectionChanged() {
            return
        }
        // 1
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        // 2
        let deleteAction = UIAlertAction(title: "Delete".localized(), style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            let alert = UIAlertController(title: "Are you sure, you want to delete?".localized(), message: "You won't be able to recover this data later.".localized(), preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            alert.addAction(UIAlertAction(title: "Delete".localized(), style: .default, handler: { (action: UIAlertAction!) in
                self.deleteChild(childId)
                NotificationsScheduler.unschedule(childId)
            }))
            self.present(alert, animated: true, completion: nil)
            
        })
        let saveAction = UIAlertAction(title: "Edit".localized(), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "editChild", sender: self)
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        
        // 4
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        
        // 5
        
        if let popoverController = optionMenu.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        self.popOverBoundView = sender
        self.popOverChildId = childId
        self.present(optionMenu, animated: true, completion: nil)
    }
    
     func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        //1
        guard let sectionCount = fetchResultsController.sections?.count else {
            return 0
        }
        return sectionCount
    }
    
    func deleteChild(_ childId: Int) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Child")
        fetchRequest.predicate = NSPredicate(format: "id == %@", NSNumber(value: childId as Int))
        do {
            let response = try self.Context.fetch(fetchRequest)
            if response.count > 0 {
                Context.delete(response[0] as! Child)
                try Context.save()
            }
        } catch let error as NSError {
            // failure
            print(error)
        }
    }
    
    func localize() {
        
    }
    
   }
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}


