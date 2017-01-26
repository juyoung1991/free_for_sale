//
//  ShowDetailsViewController.swift
//  sell_buy_item
//
//  Created by Ju Young Kim on 2016. 11. 18..
//  Copyright © 2016년 Ju Young Kim. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase

class ShowDetailsViewController: UIViewController {
    
    @IBOutlet weak var del_btn: UIBarButtonItem!
    @IBOutlet weak var edit_btn: UIBarButtonItem!
    @IBOutlet weak var scrollview: UIScrollView!
    var item_details = Dictionary<String, String>()
    var image = UIImage()
    var sale = Bool()
    var load = LoadingAnimate()
    @IBOutlet weak var item_addr_view: UIView!
    var mapView: GMSMapView!
    @IBOutlet weak var item_price: UILabel!
    @IBOutlet weak var item_descp: UILabel!
    @IBOutlet weak var user_num: UILabel!
    @IBOutlet weak var item_image: UIImageView!
    @IBOutlet weak var item_addr: UILabel!
    let rootref = FIRDatabase.database().reference()
    let storage = FIRStorage.storage()
    
    /**
     Deleting the current viewed item.
     */
    @IBAction func delete_item(_ sender: Any) {
        if(sale){
            self.load.showActivityIndicator(uiView: self.view)
            rootref.child("Sale").child(item_details["type_1"]!).child(item_details["type_2"]!).child(item_details["key"]!).removeValue(){ (error, ref) -> Void in
                if(error != nil){
                    print("error in saving data!")
                }else{
                    let imgRef = self.storage.reference().child(self.item_details["user_id"]!+"/"+self.item_details["item_name"]!)
                    imgRef.delete(completion: { (error) in
                        if(error != nil){
                            print("storage deletion error")
                        }else{
                            print("deleted everything!")
                            self.load.hideActivityIndicator(uiView: self.view)
                            self.performSegue(withIdentifier: "delete_done_sale", sender: nil)
                        }
                    })
                }
            }
        }else{
            self.load.showActivityIndicator(uiView: self.view)
            rootref.child("Buy").child(item_details["type_1"]!).child(item_details["type_2"]!).child(item_details["key"]!).removeValue(){ (error, ref) -> Void in
                if(error != nil){
                    print("error in saving data!")
                }else{
                    let imgRef = self.storage.reference().child(self.item_details["user_id"]!+"/"+self.item_details["item_name"]!)
                    imgRef.delete(completion: { (error) in
                        if(error != nil){
                            print("storage deletion error")
                        }else{
                            print("deleted everything!")
                            self.load.hideActivityIndicator(uiView: self.view)
                            self.performSegue(withIdentifier: "delete_done_buy", sender: nil)
                        }
                    })
                }
            }
        }
    }
    
    /**
     Preparing for a segue to send data across.
     - parameter sender: The data being sent to the next view controller
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "delete_done_sale"){
            let mainVC = segue.destination as! SaleListViewController
            mainVC.delete = true
        }else if(segue.identifier == "delete_done_buy"){
            let mainVC = segue.destination as! BuyListViewController
            mainVC.delete = true
        }else if(segue.identifier == "toEdit"){
            let nextVC = segue.destination as! EditDetailsViewController
            nextVC.item_details = self.item_details
            nextVC.sale = sale
            nextVC.image = image
        }
    }
    
    var item_name = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        print(item_details)
        if let user = FIRAuth.auth()?.currentUser {
            let uid = user.uid;
            if(uid == self.item_details["user_id"]){
                self.edit_btn.isEnabled = true
                self.del_btn.isEnabled = true
            }else{
                self.edit_btn.isEnabled = false
                self.del_btn.isEnabled = false
            }
        } else {
            print("This shouldn't happen because user is always logged in!")
        }
        self.scrollview.contentSize.height = 1250
        print(item_details)
        item_price.text = self.item_details["item_price"]
        item_descp.text = self.item_details["item_descp"]
        user_num.text = self.item_details["user_num"]
        item_addr.text = self.item_details["user_addr"]
        self.title = self.item_details["item_name"]
        // Do any additional setup after loading the view.
        if(item_details["item_image"] == ""){
            item_image.image = UIImage(named: "no-image.jpg")
        }else{
            item_image.image = image
        }
        self.mapView = GMSMapView(frame: self.item_addr_view.frame)
        self.scrollview.addSubview(self.mapView)
        self.show_address(addr: self.item_details["user_addr"]!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Add marker of the searched position with appropriate camera zoom
     - parameter lon: Longitude of address
     - parameter lat: Latitude of address
     - parameter title: The address
     */
    func locateWithLongitude(lon: Double, lat: Double, title: String) {
        DispatchQueue.main.async {
            let position = CLLocationCoordinate2DMake(lat, lon)
            let marker = GMSMarker(position: position)
            
            let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 17)
            self.mapView.camera = camera
            
            marker.title = title
            marker.map = self.mapView
        }
    }
    /**
     Add marker using the given addr
     - parameter addr: Longitude of address
     */
    func show_address(addr: String){
        let correctedAddr:String! = addr.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?address=\(correctedAddr!)&sensor=false")
        print("https://maps.googleapis.com/maps/api/geocode/json?address=\(correctedAddr!)&sensor=false")
        let task = URLSession.shared.dataTask(with: url! as URL) {
            data, response, error in
            
            do{
                if data != nil{
                    let dic:NSDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    let result_array = dic.object(forKey: "results") as! NSArray
                    if(result_array.count > 0){
                        let result_dict = result_array.object(at: 0) as! NSDictionary
                        let geometry = result_dict.object(forKey: "geometry") as! NSDictionary
                        let location = geometry.object(forKey: "location") as! NSDictionary
                        let lat = location.object(forKey: "lat") as! Double
                        let long = location.object(forKey: "lng") as! Double
                        
                        self.locateWithLongitude(lon: long, lat: lat, title: addr)
                    }else{
                        return
                    }
                    
                }
            }catch{
                print("Error in code")
            }
        }
        task.resume()
    }
}
