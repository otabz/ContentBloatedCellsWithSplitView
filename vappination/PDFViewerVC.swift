//
//  PDFViewerVC.swift
//  vappination
//
//  Created by Waseel ASP Ltd. on 8/27/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import UIKit

class PDFViewerVC: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    var path: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let file = URLRequest(url: URL(string: path)!)
        self.webView.loadRequest(file)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func share(_ sender: UIButton) {
        let PDFUrl = URL(fileURLWithPath: path)
        let PDF = try? Data(contentsOf: PDFUrl)
        let activityViewController = UIActivityViewController(activityItems: [PDF!], applicationActivities: nil)
        
        if let pop = activityViewController.popoverPresentationController {
            pop.sourceView = sender
            pop.sourceRect = sender.bounds
        }
        present(activityViewController, animated: false, completion: nil)
    }
    
    @IBAction func close(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}
