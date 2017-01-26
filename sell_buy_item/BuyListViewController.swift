//
//  BuyListViewController.swift
//  sell_buy_item
//
//  Created by Ju Young Kim on 2016. 11. 17..
//  Copyright © 2016년 Ju Young Kim. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class BuyListViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate {
    
    let rootref = FIRDatabase.database().reference()
    let storage = FIRStorage.storage()
    var item_names = [String]()
    var item_image_urls = Dictionary<String, String>()
    var item_details = [Dictionary<String, String>]()
    var item_images = Dictionary<String, UIImage>()
    var group = DispatchGroup()
    var processRunning = false
    var index = 0;
    var edit = Bool()
    var delete = Bool()
    var upload = Bool()
    var load = LoadingAnimate()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        if(edit || delete || upload){
            load.showActivityIndicator(uiView: self.view)
            item_details.removeAll()
            self.load_data()
            edit = false
            delete = false
            upload = false
        }else{
            load.showActivityIndicator(uiView: self.view)
            self.load_data()
        }
    }
    /**
     Call the firebase function
     */
    func load_data(){
        self.group.enter()
        self.processRunning = true
        get_firebase_data(){
            if(self.processRunning){
                self.processRunning = false
                self.group.leave()
            }
        }
        
        self.group.notify(queue: DispatchQueue.main, execute: {
            print("done")
        })
    }
    /**
     Get data from firebase database
     - parameter completionHandler: Function to be called once it's finished
     */
    func get_firebase_data(completionHandler: () -> ()){
        rootref.child("Buy").observe(.value, with: { (snapshot) in
            if(snapshot.exists()){
                var item_data = snapshot.value! as! Dictionary<String, AnyObject>
                for(type_2_container,item_list) in item_data{
                    var type_1 = type_2_container
                    for(uid_container, item_detail_container) in item_list as! Dictionary<String, AnyObject>{
                        var type_2 = uid_container
                        print("uid_container...")
                        print(uid_container)
                        for(key, item_detail_cont) in item_detail_container as! Dictionary<String, AnyObject>{
                            print("printing key...")
                            print(key)
                            var item_detail_dict = item_detail_cont as? Dictionary<String,String>
                            var item_detail_temp = Dictionary<String, String>()
                            for mykey in (item_detail_dict?.keys)!{
                                item_detail_temp[mykey] = item_detail_dict?[mykey]
                            }
                            item_detail_temp["key"] = key
                            item_detail_temp["type_1"] = type_1
                            item_detail_temp["type_2"] = type_2
                            self.item_details.append(item_detail_temp)
                            if(!self.item_names.contains(item_detail_dict!["item_name"]!)){
                                self.item_names.append(item_detail_dict!["item_name"]!)
                                self.item_image_urls[item_detail_dict!["item_name"]!] = item_detail_dict!["item_image"]!
                                
                            }
                            
                        }
                    }
                }
                print("item_url count...")
                print(self.item_image_urls.count)
                print(self.item_image_urls)
                for (item_name, url) in self.item_image_urls{
                    if(url == ""){
                        self.item_images[item_name] = UIImage(named: "no-image.jpg")
                        if(self.item_images.count == self.item_image_urls.count){
                            self.load.hideActivityIndicator(uiView: self.view)
                            self.collectionView?.reloadData()
                            print("full images...")
                            print(self.item_images)
                        }
                    }else{
                        let image_ref = self.storage.reference(forURL: url)
                        image_ref.data(withMaxSize: 10*1024*1024, completion: { (data, error) in
                            if(error != nil){
                                print("error getting image!")
                            }else{
                                let item_image = UIImage(data: data!)
                                self.item_images[item_name] = item_image!
                                print("printing item images count...")
                                print(self.item_images.count)
                                if(self.item_images.count == self.item_image_urls.count){
                                    self.load.hideActivityIndicator(uiView: self.view)
                                    self.collectionView?.reloadData()
                                    print("full images...")
                                    print(self.item_images)
                                }
                            }
                        })
                    }
                }
            }else{
                self.load.hideActivityIndicator(uiView: self.view)
            }
        })
        completionHandler()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.item_details.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:BuycollectViewCellController = collectionView.dequeueReusableCell(withReuseIdentifier: "CellBuy", for: indexPath) as! BuycollectViewCellController
        cell.cell_name_buy.text = self.item_details[indexPath.row]["item_name"]
        if(self.item_images.count > 0){
            print(indexPath.row)
            for(item_name, image) in self.item_images{
                if(item_name == self.item_details[indexPath.row]["item_name"]){
                    cell.cell_image_buy.image = image
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.index = indexPath.row
        self.performSegue(withIdentifier: "toDetail", sender: self)
    }
    /**
     Preparing for a segue to send data across.
     - parameter sender: The data being sent to the next view controller
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toDetail"){
            let nextVC = segue.destination as! ShowDetailsViewController
            nextVC.item_details = self.item_details[self.index]
            for(item_name, image) in self.item_images{
                if(item_name == self.item_details[self.index]["item_name"]){
                    nextVC.image = image
                }
            }
            nextVC.sale = false
        }else if(segue.identifier == "new_item_buy"){
            let nextVC = segue.destination as! uploadViewController
            nextVC.sale = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /**
     Signs out a user when the button linked with the IBAction is clicked.
     - parameter sender: Object that sent the action message
     */
    @IBAction func log_out(_ sender: Any) {
        do{
            try! FIRAuth.auth()!.signOut()
            self.performSegue(withIdentifier: "logout", sender: nil)
            print("user logged out!")
        } catch {
            print("error")
        }
    }
    
}
