//
//  MyFavoritesCollectionViewController.swift
//  SpeedrunAPITEsts
//
//  Created by Patrick O'Brien on 9/2/17.
//  Copyright © 2017 Patrick O'Brien. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class MyFavoritesCollectionViewController: UICollectionViewController {
    
    var defaults = UserDefaults.standard
    
    var favoriteGames = [Game]()
    var imageData = [Data]()
    var loaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped(_:)))
        
        var favoriteGamesJsonData = defaults.array(forKey: "FavJSONData") as? [Data] ?? [Data]()
        if favoriteGamesJsonData.count > 0 {
            for jsonData in favoriteGamesJsonData {
                let game = try! JSONDecoder().decode(Game.self, from: jsonData)
                favoriteGames.append(game)
            }
        }
        for game in favoriteGames {
            downloadImage(game.assets.coverMedium.uri)
        }


        collectionView?.reloadData()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "FavoriteGameSegue" {
            let gameViewController = segue.destination as! GameViewController
            let indexPath: IndexPath
            if sender is UICollectionViewCell {
                indexPath = (self.collectionView?.indexPath(for: sender as! UICollectionViewCell)!)!
            } else {
                indexPath = sender as! IndexPath
            }
            gameViewController.game = favoriteGames[indexPath.row]
            gameViewController.title = favoriteGames[indexPath.row].names.international
            gameViewController.navigationItem.rightBarButtonItem = nil
        }
    }
 

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return imageData.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CustomCollectionViewCell
        cell.gameImageView.image = UIImage(data: imageData[indexPath.row])
        cell.gameNameLabel.text = favoriteGames[indexPath.row].names.international
        cell.deleteGameButton.isEnabled = false
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? CustomCollectionViewCell {
            cell.deleteGameButton.alpha = self.isEditing ? 1 : 0
            cell.deleteGameButton.isEnabled = self.isEditing ? true : false
            cell.deleteGameButton.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? CustomCollectionViewCell {
            cell.deleteGameButton.removeTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)
        }
    }
    
    @objc
    func deleteButtonTapped(_ sender: Any?) {
        if let button = sender as? UIButton {
            
            var view: UIView? = button
            var cell: UICollectionViewCell! = nil
            
            while (view?.superview != nil) {
                view = view?.superview
                if let deletableCell = view as? UICollectionViewCell {
                    cell = deletableCell
                    break
                }
            }
            
            guard cell != nil, let indexPath = collectionView?.indexPath(for: cell) else { return }
            
            collectionView?.performBatchUpdates({
                favoriteGames.remove(at: indexPath.item)
                imageData.remove(at: indexPath.item)
                var favoriteJSONData = defaults.array(forKey: "FavJSONData") as? [Data]
                favoriteJSONData?.remove(at: indexPath.item)
                defaults.set(favoriteJSONData, forKey: "FavJSONData")
                collectionView?.deleteItems(at: [indexPath])
            }, completion: nil)
        }
    }
    
    
    
    
    @objc
    func editButtonTapped(_ sender: Any?) {
        self.setEditing(true, animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped(_:)))
    }
    
    
    
    
    @objc
    func doneButtonTapped(_ sender: Any?) {
        self.setEditing(false, animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped(_:)))
    }
    
    
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        guard let cells = collectionView?.visibleCells as? [CustomCollectionViewCell] else { return }
        UIView.animate(withDuration: 0.3) {
            for cell in cells {
                cell.deleteGameButton.alpha = editing ? 1 : 0
                cell.deleteGameButton.isEnabled = editing ? true : false
            }
        }
    }
    
    
    func downloadImage(_ uri : String){
        
        let url = URL(string: uri)
        
        let task = URLSession.shared.dataTask(with: url!) {responseData,response,error in
            if error == nil{
                if let responseData = responseData {

                    DispatchQueue.main.async {
                        self.imageData.append(responseData)
                        self.collectionView?.reloadData()
                        print("image Loaded")
                    }
                    
                }else {
                    print("no data")
                }
            }
        }
        
        task.resume()
        
    }
    
    

    
    
    
    override func viewWillAppear(_ animated: Bool) {
        favoriteGames = [Game]()
        var favoriteGamesJsonData = defaults.array(forKey: "FavJSONData") as? [Data] ?? [Data]()
        if favoriteGamesJsonData.count > 0 {
            for jsonData in favoriteGamesJsonData {
                let game = try! JSONDecoder().decode(Game.self, from: jsonData)
                favoriteGames.append(game)
            }
        }
        for game in favoriteGames {
            print(game.names.international)
        }
        if loaded == false {
            loaded = true
        } else {
            imageData = [Data]()
            for game in favoriteGames {
                downloadImage(game.assets.coverMedium.uri)
            }
        }
    }
    


}
