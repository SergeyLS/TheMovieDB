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

    /* CODEREVIEW_10
     Старайся не использовать NS классы для которых есть swift-овые аналоги (Dictionary, Array, Set, URLRequest, ...)
     */
    var populars = [[String : AnyObject]]()
    
    
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
        
        /* CODEREVIEW_4
         Смотри CODEREVIEW_2
         */
        cell.title = popular["name"] as? String
        

        
        //let id = popular["id"] as? String
        let profile_path = popular["profile_path"] as? String
       
        cell.photo.image = UIImage(named: "spinner")
        cell.photo.startRotating()

        
        /* CODEREVIEW_11
         profile_path может быть nil - нельзы просто '!' использовать иначе может быть CRASH
         URL(string:) может вернуть nil, тогда опять может быть CRASH
         */
        if let profile_path = profile_path, let url = URL(string: TMDBConfig.buildImagePath(poster_path: profile_path)) {
            let imageRequest = URLRequest(url: url)
            
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
            }, failure: { (imageRequest, imageResponse, error) -> Void in
                // do something for the failure condition
            })
        }

        return cell
    }
    

    
    
    //==================================================
    // MARK: - load
    //==================================================
   
    func loadData() {
        /* CODEREVIEW_9
         Для всех захардкодженных текстов лучше сразу использовать NSLocalizedString на случай добавления новых локализаций(языков)
         */
        ProgressHUBController.show(label: NSLocalizedString("Гружу...", comment: "Text for ProgressHUBController"))
        
        
        /* CODEREVIEW_5
         У тебя ж есть уже 'билдер' API... Тут что случилось? Лень случилась?
         */
        let stringURL = TMDBConfig.popular + TMDBConfig.API_KEY + "&language=en-US&page=1"
        
        let url = URL(string: stringURL)!
        
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        /* CODEREVIEW_6
         У тебя парсинг запускается в main thread-е!!!
         Лучше колбэки для URL тасков в main thread не перенаправлять.
         */
        let session = URLSession(configuration: .default)
//        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { [weak self] (data: Data?, response: URLResponse?, error: Error?) in
            /* CODEREVIEW_7
             Я бы сделал так c вложеными if-ами
             Если ты используешь '!' для try, то должен быть на 100% уверен что операция вернет то, что ты ожидаешь!!!
             С парсингом никогда нельзы быть в этом уверенным!!!
             */
            if let data = data,
            let dataDictionary = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String : Any],
            let popularsRep = dataDictionary["results"] as? [[String : AnyObject]] {
                //print(dataDictionary)
                
                self?.populars = popularsRep
                
                /* CODEREVIEW_8
                 А все UI-ные операции запускать в main thread-е с помощью Grand Center Dispatcher (GCD)
                 */
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
            
            DispatchQueue.main.async {
                self?.refreshControl?.endRefreshing()
                ProgressHUBController.hide()
            }
        }
        task.resume()

        
        
     }
    
 
}
