//
//  CardImagesVC.swift
//  vappination
//
//  Created by Waseel ASP Ltd. on 7/28/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreData

class CardImagesVC: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var shownImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var displayView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var lblZoom: UILabel!
    var selectedCard: Card!
    var gender: String?
    let boyBg = UIImage(named: "baby_boy_bg")
    let girlBg = UIImage(named: "baby_girl_bg")
    
    lazy var Context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        // Do any additional setup after loading the view.
        headerView.layer.cornerRadius = headerView.frame.height/2
        shownImage.image = UIImage(data: selectedCard.image! as Data)
        let tap = UITapGestureRecognizer(target: self, action: #selector(CardImagesVC.dismiss))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        
        scrollView.minimumZoomScale = 2.0
        scrollView.maximumZoomScale = 6.0
        
        // theme
        if gender == "Boy" {
            background.image = boyBg
        } else if gender == "Girl" {
            background.image = girlBg
        }
        background.image = background.image!.imageFlippedForRightToLeftLayoutDirection()
    }
    
    func viewForZoomingInScrollView(_ scrollView: UIScrollView) -> UIView {
        return self.shownImage
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let _ = touch.view as UIView? {
            if touch.view!.isDescendant(of: self.displayView) {
                return false
            }
        }
        return true
    }
    
    @IBAction func clear(_ sender: UIButton) {
        do {
            self.Context.delete(self.selectedCard)
            try self.Context.save()
        } catch {
            print(error)
        }
        self.performSegue(withIdentifier: "back", sender: self)
    }
    
    @IBAction func close(_ sender: UIButton) {
        dismiss()
    }
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func localize() {
        lblZoom.text = "Pinch to Zoom".localized()
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
