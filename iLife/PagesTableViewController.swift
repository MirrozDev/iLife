//
//  PagesTableViewController.swift
//  iLife
//
//  Created by Mirosław Witkowski.
//  Copyright © 2020 Mirosław Witkowski. All rights reserved.
//

import UIKit
import os.log

class PagesTableViewController: UITableViewController {
    
    //MARK: Variables
    
    var listOfPages = [Page] ()
    var listOfPagesFromHistory = [Page] ()
    var listOfPagesNoFromHistory = [Page] ()
    
    // Is given from prepare
    var history: History?

    //MARK: Override functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedPages = loadPages() {
            os_log("loading pages...", log: OSLog.default, type: .debug)
            listOfPages += savedPages
        } else {
            // Load the sample data.
            //addExaxmpleDate()
        }
        
        
        if let history = history {
            navigationItem.title = history.name
        }
        
        listOfPagesFromHistory = listOfPages.filter {
            $0.historyId == history?.id!
        }
        
        listOfPagesNoFromHistory = listOfPages.filter {
            $0.historyId != history?.id!
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfPagesFromHistory.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "PageTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PageTableViewCell else {
            fatalError("The dequequed cell is not an instance of PageTableViewCell")
        }
        
        let page = listOfPagesFromHistory[indexPath.row]
        
        cell.nameLabel.text = page.title
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        cell.smallLabel.text = "\(dateFormatter.string(from: page.date)), \(page.localizationName)"
        cell.imageImageView.image = page.image

        return cell
    }
    
    //MARK: Default override functions - not used

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showSinglePage" {
            
            let nav = segue.destination as! UINavigationController
            guard let pageDetailViewController = nav.topViewController as? DetailViewController
                else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedPageCell = sender as? PageTableViewCell else {                fatalError("Unexpected sender: \(sender ?? "brak")")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedPageCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedPage = listOfPagesFromHistory[indexPath.row]
            pageDetailViewController.page = selectedPage
            pageDetailViewController.history = history
            
        }
        
        if segue.identifier == "addNewPage" {
            
            let nav = segue.destination as! UINavigationController
            guard let newPageViewController = nav.topViewController as? NewPageViewController
                else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            newPageViewController.isNewPage = true
            newPageViewController.history = history
            
        }
        
    }
    
    //MARK: Actions
    @IBAction func unwindAndRemovePage(sender: UIStoryboardSegue) {
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            listOfPagesFromHistory.remove(at: selectedIndexPath.row)
             savePages()
             tableView.deleteRows(at: [selectedIndexPath], with: .fade)
        }
        
    }
    
    @IBAction func unwindToPagesList(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? NewPageViewController,
            let page = sourceViewController.page {
            if sourceViewController.isNewPage == false {
                if let selectedIndexPath = tableView.indexPathForSelectedRow {
                    // Update an existing page.
                    listOfPagesFromHistory[selectedIndexPath.row] = page
                    tableView.reloadRows(at: [selectedIndexPath], with: .none)
                    
                    tableView.selectRow(at: selectedIndexPath, animated: true, scrollPosition: .top)
                    performSegue(withIdentifier: "showSinglePage", sender: tableView.cellForRow(at: selectedIndexPath) )
                    self.navigationController?.setToolbarHidden(false, animated: false)
                } else {
                    // Add a new page
                    let newIndexPath = IndexPath(row: listOfPagesFromHistory.count, section: 0)
                    
                    listOfPagesFromHistory.append(page)
                    tableView.insertRows(at: [newIndexPath], with: .automatic)
                }
            } else {
                // Add a new page
                let newIndexPath = IndexPath(row: listOfPagesFromHistory.count, section: 0)
                
                listOfPagesFromHistory.append(page)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }

                // Save the pages
                savePages()
            }
    }
    
    //MARK: Private functions
    
    private func savePages() {
        var allPages = [Page]()
        allPages.append(contentsOf: listOfPagesFromHistory)
        allPages.append(contentsOf: listOfPagesNoFromHistory)
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
                
                list = list!.sorted(by: {
                    $0.date.compare($1.date) == .orderedDescending
                })
            }
        } catch {
            os_log("No read data...", log: OSLog.default, type: .error)
        }

        return list
    }
    
    private func addExaxmpleDate() {
        let photo1 = UIImage(named: "Image1")
        let text1 = """
        Buckingham (Buckingham Palace) – oficjalna londyńska rezydencja brytyjskich monarchów.
        Największy na świecie pałac królewski, który od 1837 roku pełni funkcję oficjalnej siedziby monarszej. Jedna z pereł architektury późnego baroku.
        Pałac został zbudowany w 1703 roku jako rezydencja miejska dla księcia i Johna Sheffielda. W roku 1761 został przekształcony w jego rezydencję prywatną. W ciągu kolejnych 75 lat pałac wielokrotnie rozbudowywano. W pałacu jest sześćset komnat, w tym dziewiętnaście reprezentacyjnych, ponad siedemdziesiąt łazienek i prawie dwieście sypialni. Rzeźbę z białego marmuru stworzył Thomas Brock w 1931 roku.
        Pałac Buckingham jest także miejscem uroczystości państwowych oraz oficjalnych spotkań głów państw. Dla Brytyjczyków pałac stanowi symbol Wielkiej Brytanii – to przed nim składano kwiaty po śmierci księżnej Diany.
"""
        guard let page1 = Page(title: "Wycieczka do Buckingham Palace", historyId: 3, date: Date(), localizationName: "Anglia, Londyn", locLon: -0.1257400, locLat: 51.5085300, image: photo1, text: text1) else {
            fatalError("Unable to instantiate ")
        }
        
        listOfPages += [page1, page1, page1, page1, page1]
    }

}
