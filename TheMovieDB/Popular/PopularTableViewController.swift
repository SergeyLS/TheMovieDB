//
//  PopularTableViewController.swift
//  TheMovieDB
//
//  Created by Sergey Leskov on 1/26/17.
//  Copyright © 2017 Sergey Leskov. All rights reserved.
//

import UIKit
import AFNetworking

class PopularTableViewController: UITableViewController {

    //==================================================
    // MARK: - Stored Properties
    //==================================================

    //var populars = [[String : AnyObject]]()
    
    var populars = [People]()
    
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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return populars.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PopularTableViewCell
        
        let popular = populars[indexPath.row]
        
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
      
        
//        if let fotoCore = popular.photo {
//            DispatchQueue.main.async {
//                cell.photo.image = UIImage(data: fotoCore)
//                cell.photo.stopRotating()
//            }
//            
//        } else {
//            DispatchQueue.main.async {
//                
//                if let profile_path = profile_path,
//                    let url = URL(string: TMDBConfig.buildImagePathX3(poster_path: profile_path)),
//                    let data = try? Data(contentsOf: url)
//                {
//                    
//                    
//                      
//                    var image = UIImage(data: data)
//                    //image = ImageController.ResizeImage(image: image, newWidth: 600)
//                    
//                    cell.photo.image = image
//                    
//                    popular.photo = data
//                    PersistenceController.shared.saveContext()
//                }
//            }
//            
//            
//        }
        
        
        
        return cell
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
 
//        let stringURL = TMDBConfig.popular + TMDBConfig.API_KEY + "&language=en-US&page=1"
//        
//        let url = URL(string: stringURL)!
//        
//        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
//        
//        let session = URLSession(configuration: .default)
//        //        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
//        let task: URLSessionDataTask = session.dataTask(with: request) { [weak self] (data: Data?, response: URLResponse?, error: Error?) in
//            if let data = data,
//                let dataDictionary = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String : Any],
//                let popularsRep = dataDictionary["results"] as? [[String : AnyObject]] {
//                //print(dataDictionary)
//                
//                self?.populars = popularsRep
//                DispatchQueue.main.async {
//                    self?.tableView.reloadData()
//                }
//            }
//            
//            DispatchQueue.main.async {
//                self?.refreshControl?.endRefreshing()
//                ProgressHUBController.hide()
//            }
//        }
//        task.resume()
        
        
//        // the get funciton is called here
//        PopularController.getFromTMDB() { [weak self] result in
//            switch result {
//            case .success(let popularDict):
//                
//                self?.populars = popularDict
//                DispatchQueue.main.async {
//                    self?.tableView.reloadData()
//                    self?.refreshControl?.endRefreshing()
//                    ProgressHUBController.hide()
//                }
//              
//                
//             case .failure(let error):
//                print(error)
//            }
//        }
        
        
        
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
