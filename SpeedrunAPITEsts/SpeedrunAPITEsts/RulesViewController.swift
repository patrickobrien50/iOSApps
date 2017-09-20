//
//  RulesViewController.swift
//  SpeedrunAPITEsts
//
//  Created by Patrick O'Brien on 9/12/17.
//  Copyright © 2017 Patrick O'Brien. All rights reserved.
//

import UIKit

class RulesViewController: UIViewController {
    
    var rules: String?
    

    @IBOutlet weak var rulesTextView: UITextView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rulesTextView.isEditable = false
        rulesTextView.isScrollEnabled = true
        if let rules = rules {
            rulesTextView.text = rules
        } else {
            rulesTextView.text = "Could not find rules"
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true , completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
