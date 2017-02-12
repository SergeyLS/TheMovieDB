//
//  CircularCollectionViewController.swift
//  TheMovieDB
//
//  Created by Sergey Leskov on 2/12/17.
//  Copyright © 2017 Sergey Leskov. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "Cell"

class CircularCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {
    
    //==================================================
    // MARK: - Stored Properties
    //==================================================
    var fetchResultController = CoreDataManager.shared.fetchedResultsController(entityName: "People", keyForSort: "name")
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CircularCollectionViewCell
        
        let people = fetchResultController.object(at: indexPath) as! People
        
        cell.name.text = people.name
        
//        cell.photo.image = UIImage(named: "spinner")
//        cell.photo.startRotating()
        
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
        ProgressHUBController.show(label: NSLocalizedString("Load...", comment: "Text for ProgressHUBController"))
        
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
            
            if let cell = sender as? CircularCollectionViewCell,
                let indexPath = collectionView?.indexPath(for: cell) {
                let people = fetchResultController.object(at: indexPath ) as! People
                
                if let fotoCore = people.photo {
                    destinationController.imageData = fotoCore
                }
            }
        }
    }
    
    
}
