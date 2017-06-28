//
//  IngredientViewController.swift
//  Recipe to Remember
//
//  Created by Patrick O'Brien on 6/25/17.
//  Copyright © 2017 Patrick O'Brien. All rights reserved.
//

import UIKit
import CoreData

class IngredientViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var componentOneRow = 0
    var componentTwoRow = 0
    var componentThreeRow = 0
    
    
    


    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        delegate?.cancelButtonPressed(by: self)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        let ingredient = Ingredient(entity: NSEntityDescription.entity(forEntityName: "Ingredient", in: managedObjectContext)!, insertInto: managedObjectContext)
        if nameTextField.text == "" {
            let alertController: UIAlertController = UIAlertController(title: "Invalid Entry", message: "You must name the ingredient before adding it to your recipe!", preferredStyle: .alert)
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .cancel) {
                action -> Void in
            }
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            ingredient.name = nameTextField.text
            
            let amount = pickerView(measurementPickerView, titleForRow: componentOneRow, forComponent: 0)
            
            let amountFraction = pickerView(measurementPickerView, titleForRow: componentTwoRow, forComponent: 1)
            
            let measurement = pickerView(measurementPickerView, titleForRow: componentThreeRow, forComponent: 2)
            
            if componentOneRow == 0 && componentTwoRow == 0 {
                let alertController: UIAlertController = UIAlertController(title: "Invalid Entry", message: "You must have a proper quantity before adding an ingredient to your recipe!", preferredStyle: .alert)
                
                let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .cancel) {
                    action -> Void in
                }
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                if componentTwoRow != 0 {
                    ingredient.measurement = "\(amount!)\(amountFraction!) \(measurement!)"
                    delegate?.itemSaved(by: self, with: ingredient)
                } else if componentOneRow == 0 && componentTwoRow != 0 {
                    ingredient.measurement = "\(amountFraction!) \(measurement!)"
                    delegate?.itemSaved(by: self, with: ingredient)
                } else {
                    ingredient.measurement = "\(amount!) \(measurement!)"
                    delegate?.itemSaved(by: self, with: ingredient)
                }
            }
        }
        

 
    }
    weak var delegate: IngredientAndInstructionViewControllerDelegate?
    
    @IBOutlet weak var nameTextField: UITextField!
        
    @IBOutlet weak var measurementPickerView: UIPickerView!
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            componentOneRow = row
        case 1:
            componentTwoRow = row
        case 2:
            componentThreeRow = row
        default: break
            
        }
    }
    

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    

    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 100
        case 1:
            return 4
        case 2:
            return 5
        default:
            return 0
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "\(row)"
        case 1:
            switch row {
            case 0:
                return " "
            case 1:
                return "¼"
            case 2:
                return "½"
            case 3:
                return "¾"
            default:
                return " "
            }
        case 2:
            switch row {
            case 0:
                return "cups"
            case 1:
                return "oz"
            case 2:
                return "ct"
            case 3:
                return "tbsp"
            case 4:
                return "lbs"
            default:
                return ""
            }
        default:
            return ""
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
