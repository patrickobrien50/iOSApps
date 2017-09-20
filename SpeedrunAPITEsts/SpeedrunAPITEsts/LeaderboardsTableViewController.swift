//
//  LeaderboardsTableViewController.swift
//  SpeedrunAPITEsts
//
//  Created by Patrick O'Brien on 8/30/17.
//  Copyright © 2017 Patrick O'Brien. All rights reserved.
//

import UIKit

class LeaderboardsTableViewController: UITableViewController {
    
    
    //MARK: Variable Declaration
    var category: Category?
    var game: Game? 
    var leaderboardLink: String?
    var descendingsuffixes = ["st", "nd", "rd", "th" ]
    var rules: String?
    var variableRules: String?
    var times = [String]()
    var runners = [String]()
    var videoLinks = [String]()
    var categoryVariables = [Variable]()
    var runs = [RunPosition]()
    var filteredRuns = [RunPosition]()
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        self.title = "Leaderboards"
//        if let link = leaderboardLink {
//            getLeaderboards(link: link)
//            print(link)
//        }
        
        
        
        if let category = category {
            getVariables(category: category, completion: { variables in
                self.categoryVariables = variables
                for variable in variables {
                    for (key) in variable.values.values {
                        print(variable.id, ":" , key)
                    }
                }
                if let link = self.leaderboardLink {
                    self.getLeaderboards(link: link)
                    print(link)
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    //MARK: Prepare for segue setup
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RulesSegue" {
            let rulesViewController = segue.destination as! RulesViewController
            if let categoryRules = category?.rules {
                if let variableRules = variableRules {
                    rulesViewController.rules = "\(categoryRules) \n\n  \(variableRules)"
                } else {
                    rulesViewController.rules = categoryRules
                }
            }
        }
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
    
    
    
    //MARK: getLeaderboardsFunction()
    
    func getLeaderboards(link: String) {
        guard let url = URL(string: "\(link)") else { return }
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            guard let data = data else { return }
            let leaderboardsData = try! JSONDecoder().decode(LeaderboardsResponse.self, from: data)
                let leaderboards = leaderboardsData.data
//                {
                for runPosition in leaderboards.runs {
                    print(runPosition.place)
                    for player in runPosition.run.players {
                        var name: String = "<Unkown>"
                        switch player.rel {
                        case "guest":
                            name = player.name ?? "Unkown Guest"
                        case "user":
                            if let allPlayers = leaderboards.players?.data {
                                let matchingPlayer = allPlayers.first(where: { (testPLayer) -> Bool in
                                    return testPLayer.id == player.id
                                })
                                name = matchingPlayer?.names?.international ?? "Unkown user \(player.id!)"
                            }
                        default:
                            break
                        }
                        print(name)
                        self.runners.append(name)
                        self.times.append(self.stringFromTime(interval: runPosition.run.times.primary_t))
                        if let directVideoLink = runPosition.run.videos?.links?[0].uri {
                            self.videoLinks.append(directVideoLink)
                        } else {
                            self.videoLinks.append(runPosition.run.weblink)
                        }
//                        print(directVideoLink)
//                        self.videoLinks.append(directVideoLink ?? runPosition.run.weblink)
                        if let runStuff = runPosition.run.values {
                            for (runKey, runValue) in runStuff {
                                for variable in self.categoryVariables {
                                    if runKey == variable.id {
                                        for (key, value) in variable.values.values {
                                            if key == runValue {
                                                print(value.label)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.animateTable()
                }
//            }
        }
        task.resume()
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
    
    
    func animateTable() {
        self.tableView.reloadData()
        
        let cells = self.tableView.visibleCells
        
        let tableViewWidth = self.tableView.bounds.size.width
        
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
    
    
    
    
    //MARK: Open in safari function
    func askToTransferToRun(link: String) {
        let alertViewController = UIAlertController(title: "Heading to view this run. ", message: "This will take you to the video for this run. Would you like to proceed?", preferredStyle: .alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) {
            action -> Void in
        }
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler: {
            action -> Void in
            let youtubeString = link.replacingOccurrences(of: "https", with: "youtube")
            let twitchString = link.replacingOccurrences(of: "https", with: "twitch")
            guard let youtubeUrl = URL(string: youtubeString) else { return }
            guard let twitchUrl = URL(string: twitchString) else { return }
            guard let safariUrl = URL(string: link) else { return }
            if UIApplication.shared.canOpenURL(youtubeUrl) {
                UIApplication.shared.open(youtubeUrl)
            } else if UIApplication.shared.canOpenURL(twitchUrl) {
                UIApplication.shared.open(twitchUrl)
            } else {
                UIApplication.shared.open(safariUrl)
            }
            })
        
        alertViewController.addAction(cancelAction)
        alertViewController.addAction(confirmAction)
        self.present(alertViewController, animated: true, completion: nil)
        
    }
    
    func stringFromTime(interval: TimeInterval) -> String {
        let ms = Int(interval.truncatingRemainder(dividingBy: 1) * 1000)
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        if ms == 0 {
            return formatter.string(from: interval)!
        } else {
            return formatter.string(from: interval)! + ".\(ms)"
        }
    }
    

    //MARK: seconds to time format function
    func secondsToHoursMinutesSeconds (seconds : Int) -> String {
        let time = (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
        var timeString: String
        if time.0 == 0 && time.1 == 0 {
            if time.2 < 10 {
                timeString = "\(time.2)0s"
            } else {
                 timeString = "\(time.2)s"
            }
           
        } else if time.0 == 0 {
            if time.2 < 10 && time.1 < 10 {
                timeString = "0:0\(time.1):\(time.2)0"
            } else if time.2 < 10 {
                timeString = "0:\(time.1):\(time.2)0"
            } else if time.1 < 10 {
                timeString = "0:0\(time.1):\(time.2)"
            } else {
                timeString = "0:\(time.1):\(time.2)"
            }
           
        } else {
            if time.2 < 10 && time.1 < 10 {
                timeString = "\(time.0):0\(time.1):0\(time.2)"
            } else if time.2 < 10 {
                timeString = "\(time.0):\(time.1):0\(time.2)"
            } else if time.1 < 10 {
                timeString = "\(time.0):0\(time.1):\(time.2)"
            } else {
                timeString = "\(time.0):\(time.1):\(time.2)"
            }
        }
        
        return timeString
    }
    
    

    
}
    
    
    
    
    
    
    
    


//MARK: Tableview delegate methods and setup
extension LeaderboardsTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    
    
    
    
    
    
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return runners.count
    }
    
    
    
    
    
    
    
    
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomLeaderboardTableViewCell
        cell.runnerNameLabel.text = runners[indexPath.row]
        cell.runTimeLabel.text = times[indexPath.row]
        if indexPath.row == 0 {
            downloadImage(game?.assets.trophy1st.uri ?? "Nothing", inView: cell.trophyImageView)
            cell.runPlaceLabel.text = "1st"
        } else if indexPath.row == 1 {
            downloadImage(game?.assets.trophy2nd.uri ?? "Nothing", inView: cell.trophyImageView)
            cell.runPlaceLabel.text = "2nd"
        } else if indexPath.row == 2 {
            cell.runPlaceLabel.text = "3rd"
            downloadImage(game?.assets.trophy3rd.uri ?? "Nothing", inView: cell.trophyImageView)
            
        } else {
            cell.trophyImageView.alpha = 0
            cell.runPlaceLabel.alpha = 1
            if indexPath.row >= 9 && indexPath.row <= 19 {
                cell.runPlaceLabel.text = "\(indexPath.row + 1)th"
            } else if indexPath.row + 1 % 10 == 1 {
                cell.runPlaceLabel.text = "\(indexPath.row + 1)st"
            } else if indexPath.row + 1 % 10 == 2 {
                cell.runPlaceLabel.text = "\(indexPath.row + 1)nd"
            } else if indexPath.row + 1 % 10 == 3 {
                cell.runPlaceLabel.text = "\(indexPath.row + 1)rd"
            } else {
                cell.runPlaceLabel.text = "\(indexPath.row + 1)th"
            }
        }
        
        
        
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? CustomLeaderboardTableViewCell {
            if indexPath.row == 0 {
                downloadImage(game?.assets.trophy1st.uri ?? "Nothing", inView: cell.trophyImageView)
                cell.runPlaceLabel.text = "1st"
                cell.trophyImageView.alpha = 1
            } else if indexPath.row == 1 {
                downloadImage(game?.assets.trophy2nd.uri ?? "Nothing", inView: cell.trophyImageView)
                if times[indexPath.row] == times[indexPath.row - 1] {
                    cell.runPlaceLabel.text = "1st"
                } else {
                    cell.runPlaceLabel.text = "2nd"
                }
                cell.trophyImageView.alpha = 1

            } else if indexPath.row == 2 {
                cell.trophyImageView.alpha = 1
                if times[indexPath.row] == times[indexPath.row - 1] {
                    cell.runPlaceLabel.text = "2nd"
                } else {
                    cell.runPlaceLabel.text = "3rd"
                }
                downloadImage(game?.assets.trophy3rd.uri ?? "Nothing", inView: cell.trophyImageView)
                
            } else {
                cell.trophyImageView.alpha = 0
                cell.runPlaceLabel.alpha = 1
                print(indexPath.row)
                if times[indexPath.row] == times[indexPath.row - 1] {
                    if indexPath.row >= 9 && indexPath.row <= 19 {
                        cell.runPlaceLabel.text = "\(indexPath.row)th"
                    } else if indexPath.row + 1 % 10 == 1 {
                        cell.runPlaceLabel.text = "\(indexPath.row)st"
                    } else if indexPath.row + 1 % 10 == 2 {
                        cell.runPlaceLabel.text = "\(indexPath.row)nd"
                    } else if indexPath.row + 1 % 10 == 3 {
                        cell.runPlaceLabel.text = "\(indexPath.row)rd"
                    } else {
                        cell.runPlaceLabel.text = "\(indexPath.row)th"
                    }
                } else {
                    if indexPath.row + 1 >= 9 && indexPath.row <= 19 {
                        cell.runPlaceLabel.text = "\(indexPath.row)th"
                    } else if indexPath.row % 10 == 1 {
                        cell.runPlaceLabel.text = "\(indexPath.row)st"
                    } else if indexPath.row % 10 == 2 {
                        cell.runPlaceLabel.text = "\(indexPath.row)nd"
                    } else if indexPath.row + 1 % 10 == 3 {
                        cell.runPlaceLabel.text = "\(indexPath.row)rd"
                    } else {
                        cell.runPlaceLabel.text = "\(indexPath.row)th"
                    }
                }
//                if indexPath.row >= 9 && indexPath.row <= 19 {
//                    cell.runPlaceLabel.text = "\(indexPath.row + 1)th"
//                } else if indexPath.row + 1 % 10 == 1 {
//                    cell.runPlaceLabel.text = "\(indexPath.row + 1)st"
//                } else if indexPath.row + 1 % 10 == 2 {
//                    cell.runPlaceLabel.text = "\(indexPath.row + 1)nd"
//                } else if indexPath.row + 1 % 10 == 3 {
//                    cell.runPlaceLabel.text = "\(indexPath.row + 1)rd"
//                } else {
//                    cell.runPlaceLabel.text = "\(indexPath.row + 1)th"
//                }
            }
        }
    }
    
    
    
    
    
    
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(videoLinks[indexPath.row])
        askToTransferToRun(link: videoLinks[indexPath.row])
    }
    
    
    
    
    
}
