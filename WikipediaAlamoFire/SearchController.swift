//
// SearchController.swift
//  WikipediaAlamoFire
//
//  Created by Connor Lagana on 7/5/19.
//  Copyright © 2019 Connor Lagana. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import DeckTransition




class SearchController: UITableViewController, UISearchBarDelegate {
    let cellId = "cells"
    var nameArray: [String] = []
    var savedArray: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .init(red: 113/255, green: 142/255, blue: 164/255, alpha: 1)
        navigationController?.navigationBar.barTintColor = .init(red: 41/255, green: 80/255, blue: 109/255, alpha: 1)
        
        addSearchBar()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    //Alamofire funcs
    func getWikiData(searchTerm: String) {
        let newSearch = searchTerm.replacingOccurrences(of: " ", with: "%20")
        Alamofire.request("https://en.wikipedia.org/w/api.php?action=opensearch&limit=50&search=\(newSearch)").responseJSON { (response) in
            if response.result.isSuccess {
                let json: JSON = JSON(response.result.value!)
                self.updateSearch(json: json)
            }
        }
        
    }
    
    func updateSearch(json: JSON) {
        guard let firstArray = json[1].arrayObject as? [String] else { return }
        
        nameArray = firstArray
        
        tableView.reloadData()
    }
    
    fileprivate let searchController = UISearchController(searchResultsController: nil)

    func addSearchBar() {
        definesPresentationContext = true
        navigationItem.searchController = self.searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.delegate = self
    }
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let search = searchBar.text else { return }
        
        getWikiData(searchTerm: search)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        cell.backgroundColor = UIColor.init(red: 18/255, green: 54/255, blue: 82/255, alpha: 1)
        
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        cell.textLabel?.text = nameArray[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath)
        guard let name2 = selectedCell?.textLabel?.text else { return }
        
        let modal = IndividualController()
        modal.name = name2
        let transitionDelegate = DeckTransitioningDelegate()
        modal.transitioningDelegate = transitionDelegate
        modal.modalPresentationStyle = .custom
        present(modal, animated: true, completion: nil)
    }

}

