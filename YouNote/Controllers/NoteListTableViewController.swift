//
//  NoteListTableViewController.swift
//  YouNote
//
//  Created by Amerigo Mancino on 18/07/2019.
//  Copyright © 2019 Amerigo Mancino. All rights reserved.
//

import UIKit
import CoreData

class NoteListTableViewController: UITableViewController, CanReceive {
    
    // core data context
    let contex = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // list of notes
    var noteList = [Note]()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
    }
    
    var temporaryIndexPath: IndexPath?

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteItem", for: indexPath)
        cell.textLabel?.text = noteList[indexPath.row].name
        return cell
    }
    
    // MARK: - Core Data operations
    
    func saveItems() {
        do {
            try self.contex.save()
        } catch {
            print("Error in saving items, \(error)")
        }
        tableView.reloadData()
    }
 
    func loadItems(with request: NSFetchRequest<Note> = Note.fetchRequest(), predicate: NSPredicate? = nil) {
        if predicate != nil {
            request.predicate = predicate
        }
        
        do {
            noteList = try self.contex.fetch(request)
        } catch {
            print("Error in loading items, \(error)")
        }
        tableView.reloadData()
    }
    
    // MARK: - Add button
    
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // go to the next screen
        performSegue(withIdentifier: "goToNote", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! NoteViewController
        destinationVC.delegate = self
        
        if let indexPath = tableView.indexPathForSelectedRow {
            temporaryIndexPath = indexPath
            destinationVC.noteText = noteList[indexPath.row].note
        }
    }
    
    // MARK: - Protocol methods
    func dataReceived(data: String) {
        noteList[temporaryIndexPath!.row].note = data
        saveItems()
    }
    

}

// MARK: - Search bar operations

extension NoteListTableViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        let predicate: NSPredicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        loadItems(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}
