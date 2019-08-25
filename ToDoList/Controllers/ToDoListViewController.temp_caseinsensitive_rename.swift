//
//  TodoListViewController.swift
//  ToDoList
//
//  Created by Regan Walsh on 16/11/2018.
//  Copyright © 2018 Regan Walsh. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    
    var toDoItems: Results<Item>?
    let realm = try! Realm() //New Instance Of Realm
    @IBOutlet weak var searchBar: UISearchBar! //New Instance Of The SearchBar
    var selectedCategory : Category? { //Category Currently In
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() { //Called After The View Is Loaded
        super.viewDidLoad()
        tableView.separatorStyle = .none //No Separator Between Each Item
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory?.name //Set Title In Navigation Pane
        guard let colourHex = selectedCategory?.colour else { fatalError() }
        updateNavBar(withHexCode: colourHex) //Set Navigation Bar To Same Colour As Category Is In Previous View
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "1D9BF6") //Light Blue Default Colour
    }
    
    //MARK: - Nav Bar Setup Methods
    func updateNavBar(withHexCode colourHexCode: String){ //Set Up Navigation Bar
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller Does Not Exist.")} //New Instance Of Navigation Bar
        guard let navBarColour = UIColor(hexString: colourHexCode) else { fatalError()}
        navBar.barTintColor = navBarColour
        navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColour, returnFlat: true)]
        searchBar.barTintColor = navBarColour
    }
    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1 //Return Total Of Items, Or Default Of 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //Asks Ream For A Cell To Insert in A Particular Locatin Of The Table View
        let cell = super.tableView(tableView, cellForRowAt: indexPath) //Cell For Item in List
        if let item = todoItems?[indexPath.row] { 
            cell.textLabel?.text = item.title //Label Is Title Of Item Object
            if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) { //Colour Is Darkened By A Percentage
                cell.backgroundColor = colour //Sets The Colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true) //Colour Of Text Is Most Suited To That Of Background Colour
            }
            cell.accessoryType = item.done ? .checkmark : .none //Ternary, If Item Is Done Then Give It A Checkmark
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //When Item Is Selected
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done //Switch The Opposite, When Clicked
                }
            } catch {
                print("Error Saving Done Status, \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true) //Deselect Row Once Completed
    }
    
    //MARK: - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField() //Initialise TextField
        let alert = UIAlertController(title: "Add New ToDoList Item", message: "", preferredStyle: .alert) //Alert Boc
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in //What Will Happen Once The User Clicks The Add Item Button On The UIAlert
            if let currentCategory = self.selectedCategory { //The Currently Selected Category
                do {
                    try self.realm.write {
                        let newItem = Item() //New Instance Of Item Object
                        newItem.title = textField.text! //Sets Title Of Item
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem) //Assign Item To Selected Category
                    }
                } catch {
                    print("Error Saving New Item, \(error)")
                }
            }
            self.tableView.reloadData()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK - Model Manupulation Methods
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true) //Load All Items For A Selected Category
        tableView.reloadData()
        
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] { //Select Item For Deletion
            do {
                try realm.write {
                    realm.delete(item) //Delete The Item
                }
            } catch {
                print("Error deleting Item, \(error)")
            }
        }
    }
}

//MARK: - Search Bar Methods
extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true) //Find Value Or Part Value For Item, Sort Multiple Items By DateCreated
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 { //If There Is Nothing In Search Bar
            loadItems() //Reload All Items
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
