//
//  PopularCollectionViewController.swift
//  TheMovieDB
//
//  Created by Sergey Leskov on 1/26/17.
//  Copyright © 2017 Sergey Leskov. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "Cell"

/* CODEREVIEW_9
 Для CollectionView все тоже самое что и для TableView
 */

class PopularCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {

    
    //==================================================
    // MARK: - Stored Properties
    //==================================================
    var fetchResultController = CoreDataManager.shared.newFetchedResultsController(entityName: "People", keyForSort: "name")
    let refreshControl = UIRefreshControl()

    
    //==================================================
    // MARK: - General
    //==================================================
 
    override func viewDidLoad() {
        super.viewDidLoad()


        fetchResultController.delegate = self
        
        refreshControl.backgroundColor = UIColor.white
        refreshControl.tintColor = UIColor.gray
        refreshControl.addTarget(self, action: #selector(loadData), for: UIControlEvents.valueChanged)
        collectionView!.addSubview(refreshControl)
        
        do {
            try fetchResultController.performFetch()
        } catch {
            print(error)
        }
        
        
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //==================================================
    // MARK: - UICollectionViewDataSource
    //==================================================

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
         return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if let sections = fetchResultController.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PopularCollectionViewCell
    
        let people = fetchResultController.object(at: indexPath) as! People

        cell.name.text = people.name
        
        cell.photo.image = UIImage(named: "spinner")
        cell.photo.startRotating()
        
        DispatchQueue.main.async {
            PopularController.getImage(people: people, imageSize: ImageSize.thumbnail, completion: { (image) in
                
                cell.photo.image = image
                cell.photo.stopRotating()
                
            })
        }

    
        return cell
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
//                    self?.collectionView?.reloadData()
//                    self?.refreshControl.endRefreshing()
//                    ProgressHUBController.hide()
//                }
//                
//            case .failure( _):
//                //print(error)
//                self?.populars = []
//                DispatchQueue.main.async {
//                    self?.collectionView?.reloadData()
//                    self?.refreshControl.endRefreshing()
//                    ProgressHUBController.hide()
//                }
//                
//                
//            }
//        }
        
        PopularController.getFromCore() { [weak self] result in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
                ProgressHUBController.hide()
            }
            
        }

        
    }

    //==================================================
    // MARK: - fetchResultController
    //==================================================
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.reloadData()
    }

    
    
    //==================================================
    // MARK: - Navigation
    //==================================================
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "detail") {
            let destinationController = segue.destination as! DetailViewController
            
            if let cell = sender as? PopularCollectionViewCell,
                let indexPath = collectionView?.indexPath(for: cell) {
                 let people = fetchResultController.object(at: indexPath ) as! People
                
                if let fotoCore = people.photo {
                    destinationController.imageData = fotoCore
                }
                
            }
            
            
            
        }
    }

 
}
