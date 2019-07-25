//
//  NoteListTableViewController.swift
//  YouNote
//
//  Created by Amerigo Mancino on 18/07/2019.
//  Copyright © 2019 Amerigo Mancino. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit

class NoteListTableViewController: UITableViewController, CanReceive {
    
    // core data context
    let contex = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // list of notes
    var noteList = [Note]()
    
    // store the indexPath of the item clicked so that the text sent back can be saved at the right index
    var temporaryIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        tableView.rowHeight = 80
    }

    // MARK: - Table view data source

    // number of items in the table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Count, \(noteList.count)")
        return noteList.count
    }

    // how the cell looks like
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteItem", for: indexPath) as! SwipeTableViewCell
        cell.textLabel?.text = noteList[indexPath.row].name
        cell.delegate = self
        return cell
    }
    
    // MARK: - Core Data operations
    
    // save items in Core Data
    func saveItems() {
        do {
            try self.contex.save()
        } catch {
            print("Error in saving items, \(error)")
        }
        tableView.reloadData()
    }
 
    // load items from Core Data
    func loadItems(with request: NSFetchRequest<Note> = Note.fetchRequest(), predicate: NSPredicate? = nil) {
        if predicate != nil {
            // in case I have a predicate for the search functionality...
            request.predicate = predicate
        }
        
        do {
            noteList = try self.contex.fetch(request)
        } catch {
            print("Error in loading items, \(error)")
        }
        tableView.reloadData()
    }
    
    // remove an item of indexRow
    func deleteItem(withIndexPath indexPath: IndexPath) {
        // remove the item from the database
        self.contex.delete(noteList[indexPath.row])
        // remove the item from the noteList
        noteList.remove(at: indexPath.row)
        // we can't call saveItems() because reloadData() is auto-implemented in SwipeTableView
        do {
            try self.contex.save()
        } catch {
            print("Error in saving items, \(error)")
        }
    }
    
    // MARK: - Add button
    
    // triggers when add button is pressed
    @IBAction func onAdd(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new YouNote item", message: "", preferredStyle: .alert)
        var textField = UITextField()
        
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            let newItem = Note(context: self.contex)
            newItem.name = textField.text!
            self.noteList.append(newItem)
            self.saveItems()
        }
        
        alert.addTextField { (alertTextField) in
            textField = alertTextField
            alertTextField.placeholder = "Create new item"
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Tapping method
    
    // triggers when tapping on an element of the list
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // go to the next screen
        performSegue(withIdentifier: "goToNote", sender: self)
    }
    
    // prepare to go to next screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! NoteViewController
        // set ourself as the delegate of the NoteViewController
        destinationVC.delegate = self
        
        if let indexPath = tableView.indexPathForSelectedRow {
            temporaryIndexPath = indexPath
            destinationVC.noteText = noteList[indexPath.row].note
        }
    }
    
    // MARK: - Protocol methods
    
    // triggers when done button is pressed in NoteViewController
    func dataReceived(data: String) {
        noteList[temporaryIndexPath!.row].note = data
        saveItems()
    }
    

}

// MARK: - Search bar operations

extension NoteListTableViewController : UISearchBarDelegate {
    
    // triggers when the search button is pressed
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        let predicate: NSPredicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        loadItems(with: request, predicate: predicate)
    }
    
    // triggers every time the text changes in the search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // if there are no characters (= the user pressed the x button)
        if searchText.isEmpty {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}

// MARK: - Swipe cell delegate methods

extension NoteListTableViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            self.deleteItem(withIndexPath: indexPath)
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "deleteIcon")
        
        return [deleteAction]
    }
 
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
}
