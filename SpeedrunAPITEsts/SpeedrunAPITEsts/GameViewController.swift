//
//  GameViewController.swift
//  SpeedrunAPITEsts
//
//  Created by Patrick O'Brien on 8/7/17.
//  Copyright © 2017 Patrick O'Brien. All rights reserved.
//

import UIKit


class GameViewController: UIViewController {
    //MARK: Variable and Outlet Declarations
    @IBOutlet weak var leaderboardsTableView: UITableView!
    @IBOutlet weak var platformsLabel: UILabel!
    @IBOutlet weak var gameImageView: UIImageView!
    @IBOutlet weak var releaseDateLabel: UILabel!
    
    @IBOutlet var favoritesButton: UIBarButtonItem!
    
    var game: Game?
    var currentCategories = [Category]()
    
   
    var gameImageURL = String()
    var defaults = UserDefaults.standard
//    var runnersAndTimes = [String: String]()
//    var leaderboards = [Runs]()
    
    //MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let gameCategories = game?.categories?.data{
            for item in gameCategories {
                if item.rules != nil {
                    currentCategories.append(item)
                }
            }
        }
        
        platformsLabel.adjustsFontSizeToFitWidth = true
        leaderboardsTableView.dataSource = self
        leaderboardsTableView.delegate = self
        downloadImage(game?.assets.coverMedium.uri ?? "Nothing", inView: gameImageView) 
        releaseDateLabel.text = game?.releaseDate ?? "Unknown"
        print(game?.assets.coverSmall.uri ?? "Somethign")
        
        
        if let platforms = game?.platforms?.data {
            var platformString = ""
            for platform in platforms {
                if platform.name == platforms[0].name {
                     platformString += platform.name
                } else {
                    platformString += ", \(platform.name)"
                }
               
            }
            platformsLabel.text = platformString
        }
        
        if let categories = game?.categories?.data {
            for category in categories {
                var category = category
                getVariables(category: category, completion: { variables in
                    category.variables = variables
                    
                })
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    

    
    
    
    //MARK: getVariablesFunction()
    
    func getVariables(category : Category, completion: @escaping (VariablesResponse) -> Void) {
        guard let url = URL(string: "http://www.speedrun.com/api/v1/categories/" + category.id + "/variables" ) else { exit(0) }
        
        let dataRequest = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            guard let data = data else { return }
            
            let variablesData = try? JSONDecoder().decode(VariablesResponse.self, from: data)
            if let data = variablesData {
                completion(data)
            }
        }
        dataRequest.resume()
    }
    

    //MARK: downloadImageFunction()
    func downloadImage(_ uri : String, inView: UIImageView){
        
        let url = URL(string: uri)
        
        let task = URLSession.shared.dataTask(with: url!) {responseData,response,error in
            if error == nil{
                if let data = responseData {
                    
                    DispatchQueue.main.async {
                        inView.image = UIImage(data: data)
                    }
                    
                } else {
                    print("no data")
                }
            }
        }
        
        task.resume()
        
    }

    //MARK: secondsCoversionFunction()
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> String {
        let time = (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
        var timeString: String?
        if time.0 == 0 && time.1 == 0 {
            timeString = "\(time.2)s"
        } else if time.0 == 0 {
            timeString = "\(time.1)m\(time.2)s"
        } else {
            timeString = "\(time.0)h\(time.1)m\(time.2)s"
        }
        return timeString!
    }
    
    //MARK: Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath: NSIndexPath
        
        if sender is UITableViewCell {
            indexPath = leaderboardsTableView.indexPath(for: sender as! UITableViewCell)! as NSIndexPath
        } else {
            indexPath = sender as! NSIndexPath
        }
            let category = currentCategories[indexPath.row]
        
            if let game = game {
                if segue.identifier == "VariablesSegue" {
                    let variablesTableViewController = segue.destination as! VariablesTableViewController
                    variablesTableViewController.game = game
                    variablesTableViewController.category = category
                    variablesTableViewController.title = category.name

                    } else if segue.identifier == "LeaderboardsSegue" {
                        let leaderboardsTableViewController = segue.destination as! LeaderboardsTableViewController
                        leaderboardsTableViewController.leaderboardLink = "http://speedrun.com/api/v1/leaderboards/" + game.id + "/category/" + category.id + "?embed=players"
                        leaderboardsTableViewController.category = category
                    if let rules = category.rules {
                        leaderboardsTableViewController.rules = rules
                    }
                    leaderboardsTableViewController.game = game
                }
            }
    }
    
    
    func gameAlreadyExists(game: Data, jsonArray: [Data]) -> Bool {
        var exists = false
        for data in jsonArray {
            if game == data {
                exists = true
                return exists
            }
        }
        return exists
    }
    
    //MARK: Favorites Feature
    @IBAction func favoritesButtonPressed(_ sender: Any) {
        let gameData = try? JSONEncoder().encode(game)
        if let data = gameData {
            var favoriteGamesJsonData = (defaults.array(forKey: "FavJSONData") as? [Data]) ?? [Data]()
            if favoriteGamesJsonData.count == 0 {
                favoriteGamesJsonData.append(data)
                defaults.set(favoriteGamesJsonData, forKey: "FavJSONData")
            } else {
                let gameExists = gameAlreadyExists(game: data, jsonArray: favoriteGamesJsonData)
                
                if gameExists == true {
                    print("Game already saved")
                } else if gameExists == false {
                    favoriteGamesJsonData.insert(data, at: 0)
                    defaults.set(favoriteGamesJsonData, forKey: "FavJSONData")
                }
//                for jsonData in favoriteGamesJsonData {
//                    if jsonData == data {
//                        print("Already Saved")
//                    } else {
//                    }
//                }
            }
        }
    }
}






extension GameViewController: UITableViewDataSource, UITableViewDelegate {
    //MARK: Table View Setup
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = leaderboardsTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = currentCategories[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let game = game else { return }
        guard let variablesData = game.variables else { return }
        if variablesData.data.count == 0 {
            performSegue(withIdentifier: "LeaderboardsSegue", sender: indexPath)
        } else {
            performSegue(withIdentifier: "VariablesSegue", sender: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Categories"
    }
    
}
