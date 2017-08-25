//
//  ViewController.swift
//  SpeedrunAPITEsts
//
//  Created by Patrick O'Brien on 8/2/17.
//  Copyright © 2017 Patrick O'Brien. All rights reserved.
//



import UIKit

class ViewController: UIViewController, UISearchBarDelegate{
    
    struct Game: Codable {
        let id: String
        let names: String
        let abbreviation: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case names
            case abbreviation
        }
    }
    @IBOutlet weak var gameSearchBar: UISearchBar!
    
    @IBOutlet weak var gamesTableView: UITableView!
    
    
    var coverArts = [String]()
    var gameNames = [String]()
    var gameIds = [String]()
    var searchString = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        gamesTableView.delegate = self
        gamesTableView.dataSource = self
        gameSearchBar.delegate = self
        getGames()
//        for item in data! {
//            let assets = item["assets"] as? [String: Any]
//            let coverMedium = assets!["cover-medium"] as? [String: Any]
//            self.coverArts.append(coverMedium!["uri"]! as! String)
//            print(coverMedium!["uri"])
//        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func getGames() {
        let jsonUrlString = "http://www.speedrun.com/api/v1/games"
        let jsonUrlStringBulk = "http://www.speedrun.com/api/v1/games?_bulk=yes&max=3000"
        guard let url = URL(string: jsonUrlStringBulk) else { return }
        
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            guard let data = data else { return }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                let data = json!["data"] as? [[String: Any]]
                
                
                for item in data! {
                    let id = item["id"] as! String
                    let names = item["names"] as? [String: Any]
                    let name = names!["international"] as! String
                    self.gameNames.append(name)
                    self.gameIds.append(id)
                }
                
                //                for item in data! {
                //                    let assets = item["assets"] as? [String: Any]
                //                    let names = item["names"] as? [String: Any]
                //                    let coverMedium = assets!["cover-medium"] as? [String: Any]
                //                    let coverString = coverMedium!["uri"]
                //                    let nameString = names!["international"]
                //                    self.coverArts.append(coverString as! String)
                //                    self.gameNames.append(nameString as! String)
                //                }
                
                
                DispatchQueue.main.async {
                    self.gamesTableView.reloadData()
                }
                
                
            } catch {
                print(error)
            }
            }.resume()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let gameViewController = segue.destination as! GameViewController
        let indexPath: NSIndexPath
        
        if sender is UITableViewCell {
            indexPath = gamesTableView.indexPath(for: sender as! UITableViewCell)! as NSIndexPath
        } else {
            indexPath = sender as! NSIndexPath
        }
        let gameId = gameIds[indexPath.row]
        gameViewController.gameId = gameId
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        coverArts = [String]()
        gameIds = [String]()
        gameNames = [String]()
        var searchText = searchText
        searchText = searchText.replacingOccurrences(of: " ", with: "%20")
        print(searchText)
        let jsonUrlString = "http://www.speedrun.com/api/v1/games?name=" + searchText
        
        guard let url = URL(string: jsonUrlString) else { return }
        
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            guard let data = data else { return }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                let data = json!["data"] as? [[String: Any]]
                
                
                for item in data! {
                    let id = item["id"] as! String
                    let names = item["names"] as? [String: Any]
                    let name = names!["international"] as! String
                    self.gameNames.append(name)
                    self.gameIds.append(id)
                }
                
                DispatchQueue.main.async {
                    self.gamesTableView.reloadData()
                }
                
                
            } catch {
                print(error)
            }
            }.resume()
        if searchText == "" {
            coverArts = [String]()
            gameIds = [String]()
            gameNames = [String]()
            getGames()
        } else {
            
        }
        
       
    }
    
    
    
    

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = gameNames[indexPath.row]
        return cell
    }
    
    
}





