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

     var fetchResultController = CoreDataManager.shared.newFetchedResultsController(entityName: "People", keyForSort: "name")
        
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
        
        cell.title = people.name
        
        
        
        //let id = popular["id"] as? String
        //let profile_path = popular.profile_path
        
        cell.photo.image = UIImage(named: "spinner")
        cell.photo.startRotating()
        
        /* CODEREVIEW_11
         В этой точке ты и так уже в main срэде. Тебе нужно запустить загрузку картинки и ее рэсайз в background потоке, а отрисовать на UI уже в main срэде
         Но при этом варианте (ниже) нарушается Правило 2: "people" нельзя передавать в другой срэд - Сделай через URLSession         
         */
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            PopularController.getImage(people: people, imageSize: ImageSize.thumbnail, completion: { (image) in
                DispatchQueue.main.async {
                    cell.photo.image = image
                    cell.photo.stopRotating()
                }
            })
        }
        
        return cell
    }
    
    //==================================================
    // MARK: - fetchResultController
    //==================================================
     func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.reloadData()
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
        ProgressHUBController.show(label: NSLocalizedString("Гружу...", comment: "Text for ProgressHUBController"))
        
        //        PopularController.getFromCore() { [weak self] result in
        //            switch result {
        //            case .success(let popularArray):
        //
        //                self?.populars = popularArray
        //                DispatchQueue.main.async {
        //                    self?.tableView.reloadData()
        //                    self?.refreshControl?.endRefreshing()
        //                    ProgressHUBController.hide()
        //                }
        //
        //            case .failure( _):
        //                //print(error)
        //
        //                self?.populars = []
        //                DispatchQueue.main.async {
        //                    self?.tableView.reloadData()
        //                    self?.refreshControl?.endRefreshing()
        //                    ProgressHUBController.hide()
        //                }
        //            }
        //
        //        }
        
        
        PopularController.getFromCore() { [weak self] result in
            DispatchQueue.main.async {
                self?.refreshControl?.endRefreshing()
                ProgressHUBController.hide()
            }
            
        }
      }
    
 
}
