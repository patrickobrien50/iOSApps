//
//  InstructionViewController.swift
//  Recipe to Remember
//
//  Created by Patrick O'Brien on 6/26/17.
//  Copyright © 2017 Patrick O'Brien. All rights reserved.
//

import UIKit
import CoreData

class InstructionViewController: UIViewController, UITextViewDelegate {
    
    var recipe: Recipe?
    
    var editingTextBool: Bool?
    
    var text: String?
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext


    override func viewDidLoad() {
        super.viewDidLoad()
        instructionsTextView.delegate = self
        instructionsTextView.isUserInteractionEnabled = editingTextBool ?? true
        instructionsTextView.text = recipe?.instructions ?? ""
        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var instructionsTextView: UITextView!
    
    
    func textViewDidChange(_ textView: UITextView){
        recipe?.instructions = instructionsTextView.text
        print(recipe?.name ?? "Found nil")
        print(recipe?.instructions)
    }
    
    override func viewWillDisappear(_ animated: Bool) {

    }

   
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
