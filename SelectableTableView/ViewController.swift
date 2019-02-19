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
    var addNewItemTextField: UITextField?
    
    let savedItemsKey = "Items"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupSearchController()
        self.setupBindings()
        self.setupUI()
        
        self.loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 11.0, *) {
            self.navigationItem.hidesSearchBarWhenScrolling = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if #available(iOS 11.0, *) {
            self.navigationItem.hidesSearchBarWhenScrolling = true
        }
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
    
    func setupUI() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonAction))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonAction))
    }
    
    func loadItems() {
        self.dataSource.removeAll()
        
        if let localDataArray = UserDefaults.standard.data(forKey: self.savedItemsKey) {
            print("File exists, trying to load it")
            
            do {
                if let localArray: [ItemModel] = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(localDataArray as Data) as? [ItemModel] {
                    print("\(localArray.count) items loaded")
                    
                    self.dataSource = localArray
                } else {
                    print("Failed to unarchive data")
                    
                    self.loadRandomData()
                }
            } catch {
                print("Couldn't read file")
                
                self.loadRandomData()
            }
        } else {
            print("File does NOT exists, will save the default one")
            
            self.loadRandomData()
            
            self.saveCurrentTableData()
        }
        
        self.reloadTableViewData()
    }
    
    func loadRandomData() {
        self.dataSource.removeAll()
        
        for index in 1...20 {
            self.dataSource.append(ItemModel(name: "Item \(index)", id: index, selected: (index % 2 == 0) ? true : false))
        }
    }
    
    func saveCurrentTableData() {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: self.dataSource, requiringSecureCoding: false)
            
            UserDefaults.standard.set(data, forKey: self.savedItemsKey)
        } catch {
            print("Couldn't write file")
        }
    }
    
    @IBAction func sortTableItems(_ sender: Any) {
        if self.sortedAsc {
            self.dataSource = self.dataSource.sorted(by: { $0.id > $1.id })
        } else {
            self.dataSource = self.dataSource.sorted(by: { $0.id < $1.id })
        }
        
        self.sortedAsc = !self.sortedAsc
        
        self.reloadTableViewData()
    }
    
    func changeAllItemsStatus(selected: Bool) {
        for index in 0...self.dataSource.count-1 {
            self.dataSource[index].selected = selected
        }
        
        self.reloadTableViewData()
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
    
    @objc func editButtonAction() {
        self.tableView.setEditing(!self.tableView.isEditing, animated: true)
    }
    
    @objc func addButtonAction() {
        let alert = UIAlertController(title: "Add new item", message: nil, preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: configurationTextField)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler:{ (UIAlertAction) in
            guard let newItemName = self.addNewItemTextField?.text else {
                return
            }
            
            if newItemName.count == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.addButtonAction()
                }
                
                return
            }
            
            let newId = (self.dataSource.sorted(by: { $0.id < $1.id }).first?.id ?? 0) + 1
            
            self.dataSource.append(ItemModel(name: newItemName, id: newId, selected: false))
            
            self.saveCurrentTableData()
            
            self.reloadTableViewData()
//            self.tableView.scrollToRow(at: IndexPath(row: max(0, self.dataSource.count - 1), section: 0), at: .bottom, animated: true)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func configurationTextField(textField: UITextField!) {
        if (textField) != nil {
            self.addNewItemTextField = textField!
            self.addNewItemTextField?.placeholder = "Item name";
        }
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "Item") {
        self.searchDataSource = self.dataSource.filter({( item : ItemModel) -> Bool in
            return item.name.lowercased().contains(searchText.lowercased())
        })
        
        self.reloadTableViewData()
    }
    
    func reloadTableViewData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFiltering() {
            return self.searchDataSource.count
        }
        
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellItem = self.isFiltering() ? self.searchDataSource[indexPath.row] : self.dataSource[indexPath.row]
        
        if let cell = cell as? CustomTableViewCell {
            DispatchQueue.main.async {
                cell.setupCellUI(selected: cellItem.selected)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.getIdentifier()) as! CustomTableViewCell
        
        let cellItem = self.isFiltering() ? self.searchDataSource[indexPath.row] : self.dataSource[indexPath.row]
        
        cell.id = cellItem.id
        cell.titleLabel.text = cellItem.name
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isFiltering() {
            let currentState = self.searchDataSource[indexPath.row].selected
            
            self.searchDataSource[indexPath.row].selected = !currentState
            
            for item in self.dataSource {
                if item.name == self.searchDataSource[indexPath.row].name {
                    item.selected = !currentState
                }
            }
            
            self.closeSearch()
        }
        
        let currentState = self.dataSource[indexPath.row].selected
        
        self.dataSource[indexPath.row].selected = !currentState
        
        if let cell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell {
            cell.setupCellUI(selected: !currentState)
        }
        
        self.saveCurrentTableData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.dataSource.remove(at: indexPath.row)
            
            self.saveCurrentTableData()
            
            self.reloadTableViewData()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.dataSource[sourceIndexPath.row]
        self.dataSource.remove(at: sourceIndexPath.row)
        self.dataSource.insert(movedObject, at: destinationIndexPath.row)
        
        self.saveCurrentTableData()
        
//        tableView.setEditing(false, animated: true)
    }
    
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.filterContentForSearchText(searchController.searchBar.text!)
    }
}
