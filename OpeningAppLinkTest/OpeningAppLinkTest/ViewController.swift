//
//  ViewController.swift
//  OpeningAppLinkTest
//
//  Created by Patrick O'Brien on 9/15/17.
//  Copyright © 2017 Patrick O'Brien. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let youtubeLink = URL(string: "https://www.youtube.com/user/CDRomatron".replacingOccurrences(of: "https", with: "youtube"))
    let safariLink = URL(string: "https://www.youtube.com/user/CDRomatron")
    let application = UIApplication.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func openButtonPressed(_ sender: UIButton) {
        guard let youtube = youtubeLink else { return }
        guard let safari = safariLink else { return }
        if application.canOpenURL(youtube) {
            application.open(youtube)
        } else {
            // if Youtube app is not installed, open URL inside Safari
            application.open(safari)
        }
    }
    
}

