//
//  GameViewController.swift
//  SpeedrunAPITEsts
//
//  Created by Patrick O'Brien on 8/7/17.
//  Copyright © 2017 Patrick O'Brien. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    
    struct Runs {
        var runnerName: String!
        var runTime: String!
        
    }
    
    struct Categories {
        var name: String!
        var leaderboardLink: String!
        
    }

    @IBOutlet weak var categoriesPickerView: UIPickerView!
    @IBOutlet weak var leaderboardsTableView: UITableView!
    @IBOutlet weak var platformsLabel: UILabel!
    @IBOutlet weak var gameImageView: UIImageView!
    @IBOutlet weak var releaseDateLabel: UILabel!
    
    var gameId = String()
    var categories = [Categories]()
    var runnersAndTimes = [String: String]()
    var leaderboards = [Runs]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        leaderboardsTableView.dataSource = self
        leaderboardsTableView.delegate = self
        categoriesPickerView.dataSource = self
        categoriesPickerView.delegate = self
        print(gameId)

        
         let jsonUrlString = "http://www.speedrun.com/api/v1/games/" + gameId
         var urlString = String()
         guard let url = URL(string: jsonUrlString) else { return }
        
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            guard let data = data else { return }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                let data = json!["data"] as? [String: Any]
                let platforms = data!["platforms"] as! NSArray
                let assets = data!["assets"] as? [String: Any]
                let links = data!["links"] as! NSArray
                let coverMedium = assets!["cover-medium"] as? [String: Any]
                DispatchQueue.main.async {
                    self.getCategories(self.gameId)
                    for item in platforms {
                        var count = 0
                        if platforms.count > 1 {
                            if count == platforms.count {
                                self.getPlatform(item as! String, multiplePlatforms: true, lastPlatform: true)

                            } else {
                                self.getPlatform(item as! String, multiplePlatforms: true, lastPlatform: false)
                                count += 1
                            }
                        } else {
                            self.getPlatform(item as! String, multiplePlatforms: false, lastPlatform: false)
                        }
                        
                    }
                    self.releaseDateLabel.text = data!["release-date"] as! String
                }
                urlString = coverMedium!["uri"] as! String
            
            } catch {
                print(error)
            }
            DispatchQueue.main.async {
                self.downloadImage(urlString, inView: self.gameImageView)
            }
            
        }.resume()
        

        print(categories)
//        print("Before sorting", leaderboards)
//        leaderboards = leaderboards.sorted(by: {(lr: Runs, rr: Runs)  -> Bool in
//            return lr.runTime < rr.runTime
//        })
//        leaderboardsTableView.reloadData()
//        print("After sorting", leaderboards)
        
        
        
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    func getUserName(_ userId: String, _ primaryTime: String){
        var username: String?
        guard let url = URL(string: "http://www.speedrun.com/api/v1/users/" + userId) else { return }
        
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            guard let data = data else { return }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                let data = json!["data"] as? [String: Any]
                let names = data!["names"] as? [String: Any]
                username = names!["international"] as! String
                
                print("Here is the name", username)
                
                DispatchQueue.main.async {
                    self.leaderboards.append(Runs(runnerName: username, runTime: primaryTime))
                    self.leaderboardsTableView.reloadData()
                }
            } catch {
                print(error)
            }
            
        }
        task.resume()
        
        
    }
    
    func getLeaderboards(_ leaderboardUrl: String) {
        self.leaderboards = [Runs]()
        guard let url = URL(string: leaderboardUrl) else { return }
        
        
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            guard let data = data else { return }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                let data = json!["data"] as? [String: Any]
                if data == nil {
                    DispatchQueue.main.async {
                        self.releaseDateLabel.text = "Please visit speedrun.com for runs"
                    }
                    
                } else {
                    let runs = data!["runs"] as! NSArray
                    for item in runs {
                        let item = item as? [String: Any]
                        let run = item!["run"] as? [String: Any]
                        let players = run!["players"] as? [[String : String]]
                        let times = run!["times"] as? [String: Any]
                        var primaryTime = "\(times!["primary_t"])" as! String

                        for player in players! {
                            print(primaryTime)
                            if player["rel"] == "user" {
                                DispatchQueue.main.async {
                                    
                                    self.getUserName(player["id"]!, primaryTime)
                                }
//                                print("This is a user and their id is", player["id"]!)
                              
                            } else {
//                                print("This is a guest and their name is", player["name"]!)
                                DispatchQueue.main.async {
                                    self.leaderboards.append(Runs(runnerName: player["name"], runTime: primaryTime))
                                    self.leaderboardsTableView.reloadData()
                                }
                            }
                        }
    //                    print(players)
    //                    let playerData = players!["data"] as? [String: Any]
    //                    let playerNames = playerData!["names"] as? [String: Any]
    //                    let name = playerNames!["international"] as! String
                       
                    }
                }
            } catch {
                print(error)
            }
        }
        task.resume()
        
        
        DispatchQueue.main.async {
            print("Before sorting", self.leaderboards)
            self.leaderboards = self.leaderboards.sorted(by: {(lr: Runs, rr: Runs)  -> Bool in
                return lr.runTime < rr.runTime
            })
            self.leaderboardsTableView.reloadData()
            print("After sorting", self.leaderboards)
        }
    }
    
    func getCategories (_ gameId: String) {
        let jsonUrlString = "http://www.speedrun.com/api/v1/games/" + gameId + "/categories"
        guard let url = URL(string: jsonUrlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            guard let data = data else { return }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                let data = json!["data"] as? [[String: Any]]
                print(data!)
                let links = data![0]["links"] as! NSArray
               
                DispatchQueue.main.async {
                    self.categories = [Categories]()
                    for item in data! {
                        let links = item["links"] as! NSArray
                        let leaderboardObject = links[links.count - 1] as? [String: Any]
                        let leaderboardLink = leaderboardObject!["uri"] as! String

                        if String(describing: item["rules"]!) == "<null>" {
                            print("Found obsolete category")
                        } else {
                            self.getLeaderboards(leaderboardLink)
                            self.categories.append(Categories(name: item["name"] as! String, leaderboardLink: leaderboardLink as! String))
                        }
                    }
                    print("Here are the categories", self.categories)
                    self.categoriesPickerView.reloadAllComponents()
                    
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func getPlatform(_ platformId: String, multiplePlatforms: Bool, lastPlatform: Bool) {
        let url = URL(string: "http://www.speedrun.com/api/v1/platforms/" + platformId)
        
        let task = URLSession.shared.dataTask(with: url!){
            data, response, error in
            
            guard let data = data else { return }
            
            
            do {
                let json =  try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                let object = json!["data"] as? [String: Any]
                var name = object!["name"] as! String
                if name.contains("PlayStation") {
                    name = name.replacingOccurrences(of: "PlayStation", with: "PS")
                    name = name.replacingOccurrences(of: " ", with: "")
                }
                
                DispatchQueue.main.async {
                    if multiplePlatforms == true {
                        if lastPlatform == false {
                            self.platformsLabel.text = self.platformsLabel.text! + String(describing: name) + ", "
                        } else {
                            self.platformsLabel.text = self.platformsLabel.text! + String(describing: name)
                        }
                    } else {
                        self.platformsLabel.text = self.platformsLabel.text! + String(describing: name)
                    }
                }
            } catch {
                print(error)
            }
        }
        
        task.resume()
    }
    
    func downloadImage(_ uri : String, inView: UIImageView){
        
        let url = URL(string: uri)
        
        let task = URLSession.shared.dataTask(with: url!) {responseData,response,error in
            if error == nil{
                if let data = responseData {
                    
                    DispatchQueue.main.async {
                        inView.image = UIImage(data: data)
                    }
                    
                }else {
                    print("no data")
                }
            }else{
                print(error)
            }
        }
        
        task.resume()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> String {
        var time = (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
        var timeString: String?
        if time.0 == 0 && time.1 == 0 {
            timeString = "\(time.2)s"
        } else if time.0 == 0 {
            timeString = "\(time.1)m\(time.2)s"
        } else {
            timeString = "\(time.0)h\(time.1)m\(time.2)s"
        }
        print(timeString)
        return timeString!
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


extension GameViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        getLeaderboards(categories[row].leaderboardLink)
        leaderboardsTableView.reloadData()
        print(categories[row].leaderboardLink)
    }
}



extension GameViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaderboards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        leaderboards = leaderboards.sorted(by: {(lr: Runs, rr: Runs)  -> Bool in
            return lr.runTime < rr.runTime
        })
        let cell = leaderboardsTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "\(indexPath.row + 1)" + "   " + leaderboards[indexPath.row].runnerName
        let time = secondsToHoursMinutesSeconds(seconds: Int(leaderboards[indexPath.row].runTime)!)
        if time == nil {
            cell.detailTextLabel?.text = "Found Nil"
        } else {
           cell.detailTextLabel?.text = time
        }
        
        return cell
    }
    
}
