//
//  PopularTableViewController.swift
//  TheMovieDB
//
//  Created by Sergey Leskov on 1/26/17.
//  Copyright © 2017 Sergey Leskov. All rights reserved.
//

import UIKit
import CoreData

class PopularTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    //==================================================
    // MARK: - Stored Properties
    //==================================================

     var fetchResultController = CoreDataManager.shared.FetchedResultsController(entityName: "People", keyForSort: "name")
        
    //==================================================
    // MARK: - General
    //==================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UIRefreshControl
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.white
        refreshControl?.tintColor = UIColor.gray
        refreshControl?.addTarget(self, action: #selector(loadData), for: UIControlEvents.valueChanged)
        
        
        fetchResultController.delegate = self
        do {
            try fetchResultController.performFetch()
        } catch {
            print(error)
        }
        
        loadData()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //==================================================
    // MARK: - Table view data source
    //==================================================

    override func numberOfSections(in tableView: UITableView) -> Int {
         return fetchResultController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchResultController.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PopularTableViewCell
  
        let people = fetchResultController.object(at: indexPath) as! People
        
        
         updateCell(cell: cell, people: people)

        return cell
    }
    
    
    func updateCell(cell: PopularTableViewCell, people: People)  {
        
        cell.title = people.name
        cell.photo.image = UIImage(named: "spinner")
        cell.photo.startRotating()
        
         DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            PopularController.getImage(people: people, imageSize: ImageSize.thumbnail, completion: { (image) in
                DispatchQueue.main.async {
                    cell.photo.image = image
                    cell.photo.stopRotating()
                }
            })
        }
    }
    
    
    //==================================================
    // MARK: - Fetched Results Controller Delegate
    //==================================================
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath as IndexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                if let cell = tableView.cellForRow(at: indexPath as IndexPath) as? PopularTableViewCell,
                    let people = fetchResultController.object(at: indexPath as IndexPath) as? People
                {
                    updateCell(cell: cell, people: people)
                }
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath as IndexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    
    //==================================================
    // MARK: - Navigation
    //==================================================
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "detail") {
            let destinationController = segue.destination as! DetailViewController
            let indexPath = (self.tableView.indexPathForSelectedRow!)
            
            let people = fetchResultController.object(at: indexPath ) as! People
            
            if let fotoCore = people.photo {
                 destinationController.imageData = fotoCore
            }

            
           }
    }


    
    
    //==================================================
    // MARK: - load
    //==================================================
    
    func loadData() {
        ProgressHUBController.show(label: NSLocalizedString("Load...", comment: "Text for ProgressHUBController"))
        
        
        PopularController.getFromCore() { [weak self] result in
            DispatchQueue.main.async {
                self?.refreshControl?.endRefreshing()
                ProgressHUBController.hide()
            }
            
        }
      }
    
 
}
