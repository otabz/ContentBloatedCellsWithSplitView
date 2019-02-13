//
//  AddPhotoVC.swift
//  vappination
//
//  Created by Waseel ASP Ltd. on 8/22/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import UIKit

class AddPhotoVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var displayView: UIView!
    @IBOutlet weak var lblBabyName: UILabel!
    @IBOutlet weak var btnRemove: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    var sourceControllerName = ""
    let photoChangedImage = UIImage(named: "done")
    var babyName: String?
    var selectedImage: Data?
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        headerView.layer.cornerRadius = headerView.frame.height/2
        
        if let pic = selectedImage {
            photo.image = UIImage(data: pic)
            btnRemove.isHidden = false
        }
        // prepare view
        if let name = babyName {
            lblBabyName.text = name
        }
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        localize()
    }
    
    func viewForZoomingInScrollView(_ scrollView: UIScrollView) -> UIView {
        return self.photo
    }
    
    @IBAction func add(_ sender: UIButton) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func clear(_ sender: UIButton) {
        photo.image = nil
        dismiss()
    }

    @IBAction func close(_ sender: UIButton) {
        dismiss()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        photo.image = resizeImage(info[UIImagePickerControllerOriginalImage] as! UIImage, newWidth: 300)
        btnClose.setImage(self.photoChangedImage, for: UIControlState())
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
    
    func dismiss() {
        if sourceControllerName == "add" {
            self.performSegue(withIdentifier: "exitToAdd", sender: self)
        } else if sourceControllerName == "edit" {
            self.performSegue(withIdentifier: "exitToEdit", sender: self)
        }
    }
    
    func localize() {
        lblBabyName.text = lblBabyName.text?.localized()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
