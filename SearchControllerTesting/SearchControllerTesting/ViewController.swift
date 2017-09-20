//
//  ViewController.swift
//  SearchControllerTesting
//
//  Created by Patrick O'Brien on 9/12/17.
//  Copyright © 2017 Patrick O'Brien. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate {
    
    
    var theSearchBar: UISearchBar?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        setupNavBar()
        
        
        
    }

    func setupNavBar() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Something goes here"
        
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.searchBar.showsCancelButton = false
        
        self.theSearchBar = searchController.searchBar
    
        searchController.searchBar.delegate = self
        
       
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("Editing Text")
    }

}

