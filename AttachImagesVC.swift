//
//  AttachImagesVC.swift
//  vappination
//
//  Created by Waseel ASP Ltd. on 7/28/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreData

class AttachImagesVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var imagePicker: UIImagePickerController!
    @IBOutlet weak var closeView: UIView!
    @IBOutlet weak var closeView2: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var lblAdd: UILabel!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var lblClose: UILabel!
    var gender: String?
    let boyBg = UIImage(named: "baby_boy_bg")
    let girlBg = UIImage(named: "baby_girl_bg")
    //var thubmnails = [UIImage]()
    //var images = [UIImage]()
    var cards : [Card]!
    var childId: Int!
    
    lazy var Context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        // Do any additional setup after loading the view.
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
        closeView.layer.cornerRadius = closeView.frame.height/2
        closeView2.layer.cornerRadius = closeView2.frame.height/2
        
        // theme
        if gender == "Boy" {
            background.image = boyBg
        } else if gender == "Girl" {
            background.image = girlBg
        }
        background.image = background.image!.imageFlippedForRightToLeftLayoutDirection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.cards = load()
        lock()
    }
    
    func lock() {
        
        if self.cards.count >= 5 {
            btnAdd.isEnabled = false
            lblAdd.text = "Can't add more".localized()
        } else {
            btnAdd.isEnabled = true
            lblAdd.text = "Add card's image".localized()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return images.count
        return cards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? CardImageCell
        if let data = self.cards[indexPath.row].image {
            if let image = UIImage(data: data as Data) {
                cell?.takenImage.image = resizeImage(image, newWidth: 200)//thubmnails[indexPath.row]
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
       self.performSegue(withIdentifier: "show", sender: self)
                tableView.deselectRow(at: indexPath, animated: true)
    }

    
    @IBAction func add(_ sender: UIButton) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        if let card = save(info[UIImagePickerControllerOriginalImage] as! UIImage) {
            cards.append(card)
            tableView.reloadData()
            lock()
        }
    }
    
    func load() -> [Card] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Card")
        fetchRequest.predicate = NSPredicate(format: "child_id == %@", NSNumber(value: self.childId as Int))
        var result = [Card]()
        do {
            let response = try self.Context.fetch(fetchRequest)
            if response.count > 0 {
                result = response as! [Card]
            }
        } catch let error as NSError {
            // failure
            print(error)
        }
        return result
    }
    
    
    func save(_ image: UIImage) -> Card? {
        // initialize card
        let context = self.Context
        let card = Card(context: context)
        card.child_id = self.childId as NSNumber?
        card.image = image.highestQualityJPEGNSData
        do {
            try self.Context.save()
            return card
        } catch {
            print(error)
            return nil
        }
    }
    
    func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    @IBAction func close(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show" {
            let vc = segue.destination as! CardImagesVC
            vc.selectedCard = cards[(tableView.indexPathForSelectedRow?.row)!]
            vc.gender = self.gender
        }
    }
    
    @IBAction func unwindToAttachImages(_ segue: UIStoryboardSegue) {
        self.cards = load()
        tableView.reloadData()
        lock()
        
    }
    
    func localize() {
        lblAdd.text = "Add card's image".localized()
        lblClose.text = "Close".localized()
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
