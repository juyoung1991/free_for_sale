//
//  searchResultController.swift
//  sell_buy_item
//
//  Created by Ju Young Kim on 2016. 11. 8..
//  Copyright © 2016년 Ju Young Kim. All rights reserved.
//

import UIKit


protocol LocateOnTheMap{
    func locateWithLongitude(lon: Double, lat: Double, title:String)
}

class searchResultController: UITableViewController {
    var mapviewController: mapViewController!
    var searchResults: [String?] = []
    var delegate: LocateOnTheMap!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchResults = Array()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        cell.textLabel?.text = self.searchResults[indexPath.row]
        return cell
    }
    

    /**
     Access the google API and parse the JSON file
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.dismiss(animated: true, completion: nil)
        let correctedAddr:String! = self.searchResults[indexPath.row]?.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?address=\(correctedAddr!)&sensor=false")
        let task = URLSession.shared.dataTask(with: url! as URL) {
            data, response, error in
            
            do{
                if data != nil{
                    let dic:NSDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    let result_array = dic.object(forKey: "results") as! NSArray
                    let result_dict = result_array.object(at: 0) as! NSDictionary
                    let geometry = result_dict.object(forKey: "geometry") as! NSDictionary
                    let location = geometry.object(forKey: "location") as! NSDictionary
                    let lat = location.object(forKey: "lat") as! Double
                    let long = location.object(forKey: "lng") as! Double
                
                    self.delegate.locateWithLongitude(lon: long, lat: lat, title: self.searchResults[indexPath.row]!)
                }
            }catch{
                print("Error in code")
            }
        }
        task.resume()
    }
    
    /**
     Reload the table view data
     - parameter array: Array of auto completed address
     */
    func reloadDataWithArray(array:[String]){
        self.searchResults = array
        self.tableView.reloadData()
    }
}
