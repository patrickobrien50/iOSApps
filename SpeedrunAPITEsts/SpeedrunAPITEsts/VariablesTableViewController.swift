//
//  VariablesTableViewController.swift
//  SpeedrunAPITEsts
//
//  Created by Patrick O'Brien on 8/30/17.
//  Copyright © 2017 Patrick O'Brien. All rights reserved.
//

import UIKit

class VariablesTableViewController: UITableViewController {
    var game: Game?
    var category: Category?
    var categoryIndex: Int?
    var areThereFilters = true
    var currentVariables = [Variable]()
    var currentChoices = [[String]]()
    var currentChoicesKeys = [[String]]()
    var currentChoicesRules = [[String: String]]()
    var leaderboardLink = ""
    
   
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if let category = category {
            getVariables(category: category, completion: { variables in
                self.currentVariables = variables
                for variable in self.currentVariables {
                    var choices = [String]()
                    var keys = [String]()
                    var rules = [String: String]()
                    for (key, choice) in variable.values.values {
                        print(variable.name, variable.id)
                        print("Choice: ", choice.label, "Key for choice: ", key)
                        choices.append(choice.label)
                        keys.append(key)
                        rules[choice.label] = choice.rules
                    }
                    self.currentChoices.append(choices)
                    self.currentChoicesKeys.append(keys)
                    self.currentChoicesRules.append(rules)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        }
        
        guard let game = game else { return }
        guard let category = category else { return }
        leaderboardLink = "http://speedrun.com/api/v1/leaderboards/" + game.id +  "/category/" + category.id + "?var-"
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getVariables(category : Category, completion: @escaping ([Variable]) -> Void) {
        guard let url = URL(string: "http://www.speedrun.com/api/v1/categories/" + category.id + "/variables" ) else { exit(0) }
        
        let dataRequest = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            guard let data = data else { return }
            
            let variablesData = try? JSONDecoder().decode(VariablesResponse.self, from: data)
            if let variables = variablesData?.data {
                completion(variables)
            }
        }
        dataRequest.resume()
    }
    
   
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if currentVariables.count == 0  {
            return 1
        } else {
            return currentVariables.count
        }
        
        
        
        
        
        
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if currentVariables.count != 0 {
            return currentVariables[section].name
        } else {
            return "Unknown"
        }
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if currentVariables.count == 0 {
            return 0
        } else {
              return currentVariables[section].values.values.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        category?.variables[indexPath.section].filters.sort(by: {$0.name < $1.name})
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        print(currentVariables[indexPath.section].values.values)
        print("\(currentChoices[indexPath.section][indexPath.row]):\(currentChoicesKeys[indexPath.section][indexPath.row])")
        cell.textLabel?.text = currentChoices[indexPath.section][indexPath.row]
        if indexPath.row == 0 {
            cell.accessoryType = .checkmark
            if indexPath.section != currentVariables.count - 1 {
                leaderboardLink += currentVariables[indexPath.section].id + "=" + currentChoicesKeys[indexPath.section][indexPath.row] + "&var-"
            } else {
                leaderboardLink += currentVariables[indexPath.section].id + "=" + currentChoicesKeys[indexPath.section][indexPath.row] + "&"
            }
            
            print(leaderboardLink)
        }
//
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.section, indexPath.row)
        let cell = tableView.cellForRow(at: indexPath)
        
        var row = 0
        
        while(row < tableView.numberOfRows(inSection: indexPath.section)) {
            let cell1: UITableViewCell = tableView.cellForRow(at: IndexPath(row: row, section: indexPath.section))!
            if cell1.accessoryType == .checkmark {
//                print(category?.variables[indexPath.section].id, category?.variables[indexPath.section].filters[indexPath.row].value)
                cell1.accessoryType = .none
            }
            row += 1
        }
        cell?.accessoryType = .checkmark
        guard let game = game else { return }
        guard let category = category else { return }
        leaderboardLink = "http://speedrun.com/api/v1/leaderboards/" + game.id +  "/category/" + category.id + "?var-"
        let cells = tableView.visibleCells
        for cell in cells {
            if let indexPath = tableView.indexPath(for: cell) {
                if cell.accessoryType == .checkmark {
                    if indexPath.section != currentVariables.count - 1 {
                        leaderboardLink += currentVariables[indexPath.section].id + "=" + currentChoicesKeys[indexPath.section][indexPath.row] + "&var-"
                    } else {
                        leaderboardLink += currentVariables[indexPath.section].id + "=" + currentChoicesKeys[indexPath.section][indexPath.row] + "&"
                    }
                }
            }
        }
//        print(leaderboardLink)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "GoSegue" {
            let leaderboardsTableViewController = segue.destination as! LeaderboardsTableViewController
            leaderboardsTableViewController.leaderboardLink = "\(leaderboardLink)&embed=players"
            leaderboardsTableViewController.category = category
            var variableRules = ""
            let cells = tableView.visibleCells
            for cell in cells {
                if let indexPath = tableView.indexPath(for: cell) {
                    if cell.accessoryType == .checkmark {
                        for (key, value) in currentChoicesRules[indexPath.section] {
                            variableRules += value
                        }
                        leaderboardsTableViewController.variableRules = variableRules
                        leaderboardsTableViewController.game = game
                        print(variableRules)
                    }
                }
            }
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
