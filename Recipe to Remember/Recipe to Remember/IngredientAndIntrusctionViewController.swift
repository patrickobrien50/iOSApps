//
//  RecipeViewController.swift
//  Recipe to Remember
//
//  Created by Patrick O'Brien on 6/22/17.
//  Copyright © 2017 Patrick O'Brien. All rights reserved.
//

import UIKit
import CoreData

class IngredientAndInstructionViewController: UIViewController, IngredientAndInstructionViewControllerDelegate {
    
    var ingredients = [Ingredient]()
    
    var recipe: Recipe?{
        didSet {
            self.title = recipe?.name
        }
    }
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBAction func addIngredientButton(_ sender: UIBarButtonItem) {
        
    
    }
    
    @IBOutlet weak var ingredientTableView: UITableView!
    

    func fetchAllItems() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Ingredient")
        request.predicate = NSPredicate(format: "recipe == %@", recipe!)
        do {
            let result = try managedObjectContext.fetch(request)
            ingredients = result as! [Ingredient]
        } catch {
            print("\(error)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ingredientTableView.dataSource = self
        ingredientTableView.delegate = self
        print(recipe?.name ?? "Found nil")
        fetchAllItems()

        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "IngredientSegue" {
            let navigationController = segue.destination as! UINavigationController
            let ingredientController = navigationController.topViewController as! IngredientViewController
            ingredientController.delegate = self
        } else if segue.identifier == "EditInstructionsSegue" {
            let instructionViewController = segue.destination as! InstructionViewController
            instructionViewController.editingTextBool = true
            let recipe = self.recipe
            print("This is the recipe we will be editing: \(String(describing: recipe?.name))")
            instructionViewController.recipe = recipe
        } else if segue.identifier == "StartCookingSegue" {
            let instructionViewController = segue.destination as! InstructionViewController
            instructionViewController.editingTextBool = false
            let recipe = self.recipe
            instructionViewController.recipe = recipe
        }
    }
    
    func itemSaved(by controller: IngredientViewController, with ingredient: Ingredient) {
        let newIngredient = NSEntityDescription.insertNewObject(forEntityName: "Ingredient", into: self.managedObjectContext) as! Ingredient
        newIngredient.name = ingredient.name
        newIngredient.measurement = ingredient.measurement
        newIngredient.recipe = recipe
        ingredients.append(newIngredient)
        print(newIngredient)
        do {
            try self.managedObjectContext.save()
        } catch {
            print("This is the error: \(error)")
        }
        dismiss(animated: true, completion: nil)
        ingredientTableView.reloadData()

    }
    
    func cancelButtonPressed(by controller: IngredientViewController) {
        self.dismiss(animated: true, completion: nil)
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

extension IngredientAndInstructionViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientCell", for: indexPath)
        cell.textLabel?.text = ingredients[indexPath.row].name
        cell.detailTextLabel?.text = ingredients[indexPath.row].measurement
        return cell
    }

}
