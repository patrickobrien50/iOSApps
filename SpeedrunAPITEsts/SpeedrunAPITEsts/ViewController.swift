//
//  ViewController.swift
//  SpeedrunAPITEsts
//
//  Created by Patrick O'Brien on 8/2/17.
//  Copyright © 2017 Patrick O'Brien. All rights reserved.
//



import UIKit

class ViewController: UIViewController, UISearchBarDelegate {
    //MARK: Variable and Outlet Declaration
    @IBOutlet weak var gameSearchBar: UISearchBar!
    @IBOutlet weak var gamesTableView: UITableView!
    @IBOutlet weak var searchesTableView: UITableView!
    
    var coverArts = [String]()
    var allGames = [Game]()
    var gameNames = [String]()
    var searchString = ""
    var defaults = UserDefaults.standard
    var recentSearches = [String]()
    var searchingText: String?
    var whitespaceMessage = "Please type using non-whitespace characters!"

    
    
    //MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Search"
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        gameSearchBar.searchBarStyle = .minimal
        gameSearchBar.barTintColor = UIColor.white
        let textField = gameSearchBar.value(forKey: "searchField") as? UITextField
        textField?.backgroundColor = UIColor(red: 241.0/255.0, green: 241.0/255.0, blue: 243.0/255.0, alpha: 1.0)
        gamesTableView.delegate = self
        gamesTableView.dataSource = self
        searchesTableView.delegate = self
        searchesTableView.dataSource = self
        gameSearchBar.delegate = self
        recentSearches = defaults.array(forKey: "savedSearches") as? [String] ?? [String]()
        print(recentSearches)
        gamesTableView.alpha = 0
        searchesTableView.tableFooterView = UIView()
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
//        view.addGestureRecognizer(tap)

    }
    
//    @objc
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    
    
    
    
    func animateTable() {
        gamesTableView.reloadData()
        
        let cells = gamesTableView.visibleCells
        
        let tableViewWidth = gamesTableView.bounds.size.width
        
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: tableViewWidth, y: 0)
        }
        
        var delayCounter = 0
        
        for cell in cells {
            UIView.animate(withDuration: 0.3, delay: Double(delayCounter) * 0.05, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
            delayCounter += 1
        }
    }
    
    
    
    

    
    //MARK: Prepare for Segue setup
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let gameViewController = segue.destination as! GameViewController
        let indexPath: NSIndexPath
        
        if sender is UITableViewCell {
            indexPath = gamesTableView.indexPath(for: sender as! UITableViewCell)! as NSIndexPath
        } else {
            indexPath = sender as! NSIndexPath
        }

        gameViewController.game = allGames[indexPath.row]
        gameViewController.title = allGames[indexPath.row].names.international

    }

}



//MARK: Searchbar delegate methods and setup
extension ViewController {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchingText = searchText
        if searchText == "" {
            self.gamesTableView.alpha = 0
            self.searchesTableView.alpha = 1
        } else {
            
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.gamesTableView.alpha = 0
        self.searchesTableView.alpha = 0
        guard let searchText = searchingText else { return }
        
        for item in recentSearches {
            if item == searchText {
                let index = recentSearches.index(of: item) ?? 0
                recentSearches.remove(at: index)
                break
            }
            
        }
        
        if searchText == "" {
            let alert = UIAlertController(title: "Invalid Search", message: "Please try again.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            searchesTableView.alpha = 1
        } else if searchBar.text?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            print("Nothing Typed in the field, please try again.")
            let alert = UIAlertController(title: "Invalid Search", message: "Please try again.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)

        } else {
            recentSearches.insert(searchText, at: 0)
            searchesTableView.reloadData()
            print(recentSearches)
            
            
            self.searchingText = searchingText!.replacingOccurrences(of: " ", with: "%20")
            print(searchText)
            let jsonUrlString = "http://www.speedrun.com/api/v1/games?name=" + searchingText! + "&embed=categories,platforms,variables"
            
            guard let url = URL(string: jsonUrlString) else { return }
            
            let dataRequest = URLSession.shared.dataTask(with: url) { (data, reponse, error) in
                guard let data = data else { return }
                
                let gamesData = try? JSONDecoder().decode(GamesResponse.self, from: data)
                if let games = gamesData?.data {
                    //                print(games)
                    DispatchQueue.main.async {
                        self.allGames = games
                    }
                    for game in games {
                        //                    print(game.id)
//                        if let categoriesResponse = game.categories {
//                            for category in categoriesResponse.data {
//                                //                            self.getVariables(category: category, game: game)
//                            }
//                        }
                        
                    }
                }
                DispatchQueue.main.async {
                    self.gamesTableView.alpha = 1
                    self.animateTable()
                    self.dismissKeyboard()
                    
                }
                
            }
            dataRequest.resume()
        }

        
        
        
        
        if recentSearches.count > 6 {
            recentSearches.remove(at: recentSearches.count - 1)
            searchesTableView.reloadData()
            defaults.set(recentSearches, forKey: "savedSearches")
        } else {
            defaults.set(recentSearches, forKey: "savedSearches")
        }

        
    }
}






//MARK: Tableview delegate methods and setup
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.gamesTableView {
             return allGames.count
        } else {
            return recentSearches.count
        }
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.gamesTableView {
            let gamesCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? CustomGamesTableViewCell
            gamesCell?.gameNameLabel.text = allGames[indexPath.row].names.international
            downloadImage(allGames[indexPath.row].assets.coverMedium.uri, inView: (gamesCell?.gameCoverImageView)!)
            return gamesCell! 
        } else {
            let searchCell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
            if recentSearches.count == 0 {
                searchCell.textLabel?.text = "No Recent Searches"
            } else {
                searchCell.textLabel?.text = recentSearches[indexPath.row]
            }
            return searchCell
        }
    }
    
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        if tableView == searchesTableView {
            view.tintColor = UIColor.white
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.textColor = UIColor.darkText
        }
  
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == self.searchesTableView {
            return "Recent Searches"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.searchesTableView {
            gameSearchBar.text = recentSearches[indexPath.row]
            searchingText = recentSearches[indexPath.row]
            searchBarSearchButtonClicked(gameSearchBar)
        }
    }
}





