//
//  ViewController.swift
//  NotificationServiceExtensionDemo
//
//  Created by Jayesh Thanki on 26/12/18.
//  Copyright © 2018 Logistic Infotech Pvt. Ltd. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var arrImages:[Data] = []
    
    @IBOutlet weak var imgNotification: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let defaults = UserDefaults(suiteName: "group.logistic.test")
        if (defaults?.object(forKey: "images") != nil) {
            let data = defaults?.value(forKey: "images") as! Data
            imgNotification.image = UIImage(data: data)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

