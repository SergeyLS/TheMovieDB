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

     var populars = [NSDictionary] ()
    
    
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
        
        cell.name.text = popular["name"] as? String
        

        
        //let id = popular["id"] as? String
        let profile_path = popular["profile_path"] as? String
       
        cell.photo.image = UIImage(named: "spinner")
        cell.photo.startRotating()

        
        let imageURL = TMDBConfig.buildImagePath(poster_path: profile_path!)
        let imageRequest = NSURLRequest(url: NSURL(string:imageURL)! as URL)

        
        cell.photo.setImageWith(
            imageRequest as URLRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                cell.photo.stopRotating()
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                   // print("Image was NOT cached, fade in image")
                    cell.photo.image = image
                  } else {
                    //print("Image was cached so just update the image")
                    cell.photo.image = image
                }
        },
            failure: { (imageRequest, imageResponse, error) -> Void in
                // do something for the failure condition
        })

            
        
        
        return cell
    }
    

    
    
    //==================================================
    // MARK: - load
    //==================================================
   
    func loadData() {
        ProgressHUBController.show(label: "Гружу...")
        
        
        let stringURL = TMDBConfig.popular + TMDBConfig.API_KEY + "&language=en-US&page=1"
        
        let url = URL(string: stringURL)!
        
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    //print(dataDictionary)
                    
                    self.populars = (dataDictionary["results"] as! [NSDictionary])
                    
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                    ProgressHUBController.hide()
                    
                }
            }
            
        }
        task.resume()

        
        
     }
    
 
}
