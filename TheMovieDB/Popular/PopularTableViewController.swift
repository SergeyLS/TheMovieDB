//
//  PopularTableViewController.swift
//  TheMovieDB
//
//  Created by Sergey Leskov on 1/26/17.
//  Copyright © 2017 Sergey Leskov. All rights reserved.
//

import UIKit
import AFNetworking
import CoreData

class PopularTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    //==================================================
    // MARK: - Stored Properties
    //==================================================

    var populars = [People]()
    
    /* CODEREVIEW_2
     Для отображения данных из БД в таблице используй NSFetchedResultsController
     */
    lazy var fetchResultController: NSFetchedResultsController<People> = { () -> NSFetchedResultsController<People> in
        
        let request: NSFetchRequest<People> = People.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let resultController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataManager.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        resultController.delegate = self
        
        return resultController
    }()

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
  
        let popular = fetchResultController.object(at: indexPath)
        
        cell.title = popular.name
        
        
        
        //let id = popular["id"] as? String
        //let profile_path = popular.profile_path
        
        cell.photo.image = UIImage(named: "spinner")
        cell.photo.startRotating()
        
        DispatchQueue.main.async {
            PopularController.getImage(people: popular, imageSize: ImageSize.thumbnail, completion: { (image) in
                
                cell.photo.image = image
                cell.photo.stopRotating()
                
            })
        }
      
        
        return cell
    }
    
    
    /* CODEREVIEW_12
     Колбэк тебе не нужен. Когда данные в базе обновляются NSFetchedResultsController об этом узнает и запускает делегата controllerDidChangeContent(_ controller:)
     */
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.reloadData()
    }

    //==================================================
    // MARK: - Navigation
    //==================================================
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "detail") {
            let destinationController = segue.destination as! DetailViewController
            let row = (self.tableView.indexPathForSelectedRow! as NSIndexPath).row
            
            let popular = populars[row]
            
            if let fotoCore = popular.photo {
                 destinationController.imageData = fotoCore
            }

            
           }
    }


    
    
    //==================================================
    // MARK: - load
    //==================================================
    
    func loadData() {
        ProgressHUBController.show(label: NSLocalizedString("Гружу...", comment: "Text for ProgressHUBController"))
 

        
        /* CODEREVIEW_6
         Для отображения данных из БД в таблице используй NSFetchedResultsController
         */
        PopularController.getFromCore() { [weak self] result in
            switch result {
            case .success(let popularArray):
                
                self?.populars = popularArray
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.refreshControl?.endRefreshing()
                    ProgressHUBController.hide()
                }
                
            case .failure( _):
                //print(error)
                
                self?.populars = []
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.refreshControl?.endRefreshing()
                    ProgressHUBController.hide()
                }
            }
            
        }
    }
    
 
}
