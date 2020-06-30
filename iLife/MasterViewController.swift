//
//  MasterViewController.swift
//  iLife
//
//  Created by Mirosław Witkowski.
//  Copyright © 2020 Mirosław Witkowski. All rights reserved.
//

import UIKit
import os.log

class MasterViewController: UITableViewController {

    //MARK: Variables
    
    var listOfHistories = [History]()
    
    
    //MARK: Actions
    
    @IBAction func newHistory(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Nowa Historia", message: "Podaj nazwę tej Historii.", preferredStyle: .alert)
        
        let saveBtn = UIAlertAction(title: "Zachowaj", style: .default, handler: {(save: UIAlertAction!) in self.insertNewObject(historyName: "\(alert.textFields![0].text!)" )
        })
        
        alert.addTextField {
            (textField) in
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main, using:{_ in updateSaveButtonState() } )
            textField.placeholder = "Nazwa"
            textField.minimumFontSize = 17
        }
        
        alert.addAction(saveBtn)
        
        let cancelBtn = UIAlertAction(title: "Anuluj", style: .cancel, handler: nil )
        cancelBtn.setValue(UIColor.systemRed, forKey: "titleTextColor")
        alert.addAction(cancelBtn)
        
        func updateSaveButtonState() {
            // Disable the Save button if the text field is empty.
            let text = alert.textFields![0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            saveBtn.isEnabled = !text.isEmpty
        }
        
        
        self.present(alert, animated: true, completion: nil)
        updateSaveButtonState()
        
    }
    
    //MARK: Override functions

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedHistories = loadHistories() {
            listOfHistories += savedHistories
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    //MARK: Insert new object
    
    func insertNewObject(historyName: String) {
        addNewHistoryToList(historyName: historyName)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showPages" {
            
            guard let pagesTableViewController = segue.destination as? PagesTableViewController
                else {
                    fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedPageCell = sender as? HistoryTableViewCell
                else {
                    fatalError("Unexpected sender: \(sender ?? "no sender")")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedPageCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedHistory = listOfHistories[indexPath.row]
            pagesTableViewController.history = selectedHistory
            
        }
        
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfHistories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "HistoryTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? HistoryTableViewCell else {
            fatalError("The dequeued cell is not an instance of HistoryTableViewCell.")
        }
        
        let History = listOfHistories[indexPath.row]
        cell.historyNameLabel!.text = History.name
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            showAlertDeleteHistory(indexPath: indexPath)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    //MARK: Private functions
    
    private func removeHistoryAndPages(indexPath: IndexPath) {
        
        removeHistoryAndPages(id: indexPath.row)
        
        tableView.deleteRows(at: [indexPath], with: .fade)
        
    }
    
    private func showAlertDeleteHistory(indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Czy na pewno chcesz usunąć tą Historię?", message: "Wszystkie strony w tej historii również zostaną usunięte.", preferredStyle: .alert)
        
        let deleteBtn = UIAlertAction(title: "Usuń", style: .destructive, handler: {(save: UIAlertAction!) in self.removeHistoryAndPages(indexPath: indexPath) })
        deleteBtn.setValue(UIColor.systemRed, forKey: "titleTextColor")
        alert.addAction(deleteBtn)
        
        let cancelBtn = UIAlertAction(title: "Anuluj", style: .cancel, handler: nil )
        cancelBtn.setValue(UIColor.systemRed, forKey: "titleTextColor")
        alert.addAction(cancelBtn)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    private func addNewHistoryToList(historyName: String) {
        let listOfIds: Array<Int> = listOfHistories.map({
            (history: History) -> Int in history.id ?? 0
        })
        
        let maxID: Int = listOfIds.max() ?? 0
        
        listOfHistories.insert(History(name: historyName, id: (maxID+1))!, at: 0)
        saveHistories()
    }
    
    private func removeHistoryAndPages(id: Int) {
        
        removeAllPagesFromHistory(id: listOfHistories[id].id ?? -1)
        listOfHistories.remove(at: id)
        saveHistories()
        
    }
    
    private func removeAllPagesFromHistory(id: Int) {
        var list = [Page]()
        
        if let savedPages = loadPages() {
            list += savedPages
        }
        
        let newList = list.filter {
            $0.historyId != id
        }
        
        savePages(list: newList)
        
    }
    
    private func saveHistories() {
        do {
            let isSuccessfulSave = try NSKeyedArchiver.archivedData(withRootObject: listOfHistories, requiringSecureCoding: false)
            try isSuccessfulSave.write(to: History.ArchiveURL)
            os_log("Histories successfully saved.", log: OSLog.default, type: .debug)
        } catch {
            os_log("Failed to save histories...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadHistories() -> [History]? {
        var list: [History]? = nil
        do {
            if let loadedStrings = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(try Data(contentsOf: History.ArchiveURL)) as? [History] {
                list = loadedStrings
            }
        } catch {
            os_log("No read data...", log: OSLog.default, type: .error)
        }
        return list
    }
    
    private func savePages(list: Array<Page>) {
        var allPages = [Page]()
        allPages.append(contentsOf: list)
        do {
            let isSuccessfulSave = try NSKeyedArchiver.archivedData(withRootObject:  allPages, requiringSecureCoding: false)
            try isSuccessfulSave.write(to: Page.ArchiveURL)
            os_log("Pages successfully saved.", log: OSLog.default, type: .debug)
        } catch {
            os_log("Failed to save pages...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadPages() -> [Page]? {
        var list: [Page]? = nil
        do {
            if let loadedStrings = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(try Data(contentsOf: Page.ArchiveURL)) as? [Page] {
                os_log("Adding pages...", log: OSLog.default, type: .debug)
                list = loadedStrings
            }
        } catch {
            os_log("No read data...", log: OSLog.default, type: .error)
        }
        //print("\(list)")
        return list
    }

}

