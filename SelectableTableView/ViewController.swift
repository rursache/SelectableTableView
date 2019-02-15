//
//  ViewController.swift
//  SelectableTableView
//
//  Created by Radu Ursache on 15/02/2019.
//  Copyright © 2019 Radu Ursache. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    var dataSource = [ItemModel]()
    var searchDataSource = [ItemModel]()
    var sortedAsc = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupSearchController()
        self.setupBindings()
        
        self.setItems()
    }
    
    func setupSearchController() {
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "Search item"
        self.navigationItem.searchController = self.searchController
        self.definesPresentationContext = true
    }

    func setupBindings() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func setItems() {
        self.dataSource.removeAll()
        
        for index in 1...20 {
            self.dataSource.append(ItemModel(name: "Item \(index)", id: index, selected: (index % 2 == 0) ? true : false))
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func sortTableItems(_ sender: Any) {
        if self.sortedAsc {
            self.dataSource = self.dataSource.sorted(by: { $0.id > $1.id })
        } else {
            self.dataSource = self.dataSource.sorted(by: { $0.id < $1.id })
        }
        
        self.sortedAsc = !self.sortedAsc
        
        self.tableView.reloadData()
    }
    
    func changeAllItemsStatus(selected: Bool) {
        for index in 0...self.dataSource.count-1 {
            self.dataSource[index].selected = selected
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func selectNoneAction(_ sender: Any) {
        self.changeAllItemsStatus(selected: false)
    }
    
    @IBAction func selectAllAction(_ sender: Any) {
        self.changeAllItemsStatus(selected: true)
    }
    
    func searchBarIsEmpty() -> Bool {
        return self.searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return self.searchController.isActive && !searchBarIsEmpty()
    }
    
    func closeSearch() {
        self.searchController.isActive = false
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "Item") {
        self.searchDataSource = self.dataSource.filter({( item : ItemModel) -> Bool in
            return item.name.lowercased().contains(searchText.lowercased())
        })
        
        self.tableView.reloadData()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFiltering() {
            return self.searchDataSource.count
        }
        
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.getIdentifier()) as! CustomTableViewCell
        
        let cellItem = self.isFiltering() ? self.searchDataSource[indexPath.row] : self.dataSource[indexPath.row]
        
        cell.id = cellItem.id
        cell.titleLabel.text = cellItem.name
        
        if cellItem.selected {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isFiltering() {
            self.searchDataSource[indexPath.row].selected = true
            
            for item in self.dataSource {
                if item.name == self.searchDataSource[indexPath.row].name {
                    item.selected = true
                }
            }
            
            self.closeSearch()
        }
        
        self.dataSource[indexPath.row].selected = true
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if self.isFiltering() {
            self.searchDataSource[indexPath.row].selected = false
            
            for item in self.dataSource {
                if item.name == self.searchDataSource[indexPath.row].name {
                    item.selected = false
                }
            }
            
            self.closeSearch()
        }
        
        self.dataSource[indexPath.row].selected = false
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.filterContentForSearchText(searchController.searchBar.text!)
    }
}
