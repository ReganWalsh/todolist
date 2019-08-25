//
//  CategoryViewController.swift
//  ToDoList
//
//  Created by Regan Walsh on 16/11/2018.
//  Copyright © 2018 Regan Walsh. All rights reserved.
//
//  Use ? if the value can become nil in the future, so that you test for this.
//  Use ! if it really shouldn't become nil in the future, but it needs to be nil initially.

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController { //Adopt The SwipeTableViewController Protocol
    
    let realm = try! Realm() //Get The Default Realm
    var categories: Results<Category>?
    override func viewDidLoad() { //Called When The View Loads On Screen
        super.viewDidLoad()
        loadCategories()
        tableView.separatorStyle = .none //Remove Separators Between Items
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { //Returns The Number Of Cells In A Section
        return categories?.count ?? 1 //Return Total Of Categories, Or Default Of 1
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //Asks Ream For A Cell To Insert in A Particular Locatin Of The Table View
        let cell = super.tableView(tableView, cellForRowAt: indexPath) //Cell At The Particular index
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name //Assign Label To Name Of Created Category
            guard let categoryColour = UIColor(hexString: category.colour) else {fatalError()}
            cell.backgroundColor = categoryColour
            cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
        }
       return cell //Return Cell With Colour Attributes
    }

    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //Tells The Delegate That The Category Is Now Selected
        performSegue(withIdentifier: "goToItems", sender: self) //Go Between Views
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //Segue Between Views About To Be Performed
        let destinationVC = segue.destination as! ToDoListViewController //Destination Is The TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row] //View Is Created Within Corresponding Category
        }
    }

    //MARK: - Data Manipulation Methods
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category) //Add Category To Realm Database
            }
        } catch {
            print("Error saving category \(error)")
        }
        tableView.reloadData() //Reload When Written To Database
    }
    
    func loadCategories() {
        categories  = realm.objects(Category.self) //Return All Category Objects
        tableView.reloadData()
    }
    
    //MARK: - Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categories?[indexPath.row] { //Select Category Index To Be Deleted
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion) //Delete Category From Realm
                }
            } catch {
                print("Error Deleting Category, \(error)")
            }
        }
    }
    
    //MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField() //Create TextField To Add Category
        let alert = UIAlertController(title: "Create New Category", message: "", preferredStyle: .alert) //Title And Type Of Text Box To Add Category
        let action = UIAlertAction(title: "Create", style: .default) { (action) in //What To Do When Add Button Is Pressed
            let newCategory = Category() //Initialise New Category
            newCategory.name = textField.text! //Assign Name
            newCategory.colour = UIColor.randomFlat.hexValue() //Creates A Random Flat Colour For Category
            self.save(category: newCategory) //Saves The Category
        }
        alert.addAction(action) //Adds Action To Button
        alert.addTextField { (field) in //Adds Field To Button
            textField = field
            textField.placeholder = "Please Add A New Category"
        }
        present(alert, animated: true, completion: nil) //Create The Alert
    }
}
