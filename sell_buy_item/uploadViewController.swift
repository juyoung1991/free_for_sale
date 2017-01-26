//
//  uploadViewController.swift
//  sell_buy_item
//
//  Created by Ju Young Kim on 2016. 11. 7..
//  Copyright © 2016년 Ju Young Kim. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

//http://stackoverflow.com/questions/29137488/how-do-i-resize-the-uiimage-to-reduce-upload-image-size
extension UIImage {
    /**
    Compress the image size
    - parameter percentag: Float value of the amount of compression
     */
    func resizeWith(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}

class uploadViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UISearchControllerDelegate, UISearchBarDelegate{
    
    let rootref = FIRDatabase.database().reference()
    
    var types = ["Electronics", "Clothes", "Household", "Ticket", "Transportation", "Book"]
    
    var elec_types = ["Laptop", "Desktop", "Mobile Phone", "Tablet", "Other"]
    
    var clothes_types = ["Top", "Bottom", "other"]
    
    var household_types = ["Plates,Pot,Pan", "Refridgerator", "Microwave", "Cutlery", "Furniture", "Other"]
    
    var ticket_types = ["Concert,Show", "Bus", "Other"]
    
    var trans_types = ["Car", "Motocycle", "Bicycle", "Other"]
    
    var book_types = ["Academic", "eBook", "Other"]
    
    var component_type = "Electronics" //by Default
    
    var indicator = UIActivityIndicatorView()
    
    var load = LoadingAnimate()
    
    var sale = Bool()
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var item_type: UITextField!
    
    @IBOutlet weak var item_name: UITextField!
    
    @IBOutlet weak var item_price: UITextField!
    
    @IBOutlet weak var user_number: UITextField!
    
    @IBOutlet weak var item_descp: UITextView!
    
    @IBOutlet weak var item_image: UIImageView!
    
    @IBOutlet weak var addrLabel: UILabel!
    
    /**
     Create a loading animation in the middle of the view
     */
    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        indicator.center = self.view.center
        self.view.addSubview(indicator)
    }
    
    /**
     Unwind function so allow other viewcontroller to unwind to this current view
     */
    @IBAction func unwindToThisVIew(_ sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? mapViewController {
            self.addrLabel.text = sourceViewController.addr
        }
    }
    /**
     Create alert pop up message box
     - parameter title: Title of the alert message
     - parameter message: Message of the alert message
     */
    func alertMessage(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

    /**
     Set item_image variable to the picked image
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let picked_image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            item_image.image = picked_image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    /**
     Open up the photo library inside the device
     */
    @IBAction func upload_image(_ sender: Any) {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    /**
     Open up the camera inside the device
     */
    @IBAction func take_picture(_ sender: Any) {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    /**
     When the submit button is clicked, all item details is added to the database and referred back to the list view.
     */
    @IBAction func submit_item(_ sender: Any) {
        indicator.startAnimating()
        indicator.backgroundColor = UIColor.white
        let user = FIRAuth.auth()?.currentUser
        var type_1:String
        var type_2:String
        var type_arr:[String]
        if(item_type.text == ""){
            type_1 = ""
            type_2 = ""
        }else{
            type_arr = (item_type.text?.components(separatedBy: "/"))!
            type_1 = type_arr[0]
            type_2 = type_arr[1]
        }
        
        let name = item_name.text
        let price = item_price.text
        let descp = item_descp.text
        let image = item_image.image
        let addr = addrLabel.text
        let number = user_number.text
        var img_url_str:String?
        
        if(name != "" && price != "" && descp != "" && addr != "" && number != "" && type_1 != "" && type_2 != ""){
            if(image != nil){
                self.load.showActivityIndicator(uiView: self.view)
                let storageRef = FIRStorage.storage().reference()
                let imageref = storageRef.child((user?.uid)!).child(name!)
                let imageData = UIImagePNGRepresentation(image!.resizeWith(percentage: 0.1)!)
//                let imageData = UIImagePNGRepresentation(image!)
                
                let uploadTask = imageref.put(imageData!, metadata: nil, completion: { (metadata, error) in
                    print("")
                    if(error != nil){
                        print("Error uploading image")
                    }else{
                        let img_url = metadata!.downloadURL()!
                        self.addToDataBase(type_1: type_1, type_2: type_2, user: user!, name: name!, price: price!, descp: descp!, number: number!, addr: addr!, url: img_url.absoluteString)
                    }
                })
            }else{
                img_url_str = ""
                self.addToDataBase(type_1: type_1, type_2: type_2, user: user!, name: name!, price: price!, descp: descp!, number: number!, addr: addr!, url: img_url_str!)
            }
        }else{
            self.alertMessage(title: "Oops!", message: "Make sure you fill everything out!")
        }
        
    }
    /**
     Preparing for a segue to send data across.
     - parameter sender: The data being sent to the next view controller
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "upload_done_sale"){
            let mainVC = segue.destination as! SaleListViewController
            mainVC.upload = true
        }else if(segue.identifier == "upload_done_buy"){
            let mainVC = segue.destination as! BuyListViewController
            mainVC.upload = true
        }
    }
    
    /**
     Helper function that adds information to database
     - parameter type_1: The primary type of item
     - parameter type_2: The secondary type of item
     - parameter user: The current user
     - parameter name: Name of user
     - parameter price: Price of item
     - parameter descp: Description of item
     - parameter addr: Address of user
     - parameter url: URL of the image storage
     */
    func addToDataBase(type_1:String, type_2:String, user:FIRUser, name:String, price:String, descp:String, number: String, addr:String, url: String){
        if(sale){
            let key = self.rootref.child("Sale").child(type_1).child(type_2).child((user.uid)).childByAutoId().key
            self.rootref.child("Sale").child(type_1).child(type_2).child(key).setValue(["user_id": user.uid, "item_name": name, "item_price": price, "item_descp": descp, "user_num": number, "user_addr": addr, "item_image": url]){ (error, ref) -> Void in
                if(error != nil){
                    print("error in uploading data!")
                }else{
                    print("uploaded!")
                    self.load.hideActivityIndicator(uiView: self.view)
                    self.performSegue(withIdentifier: "upload_done_sale", sender: nil)
                }
            }
        }else{
            let key = self.rootref.child("Sale").child(type_1).child(type_2).child((user.uid)).childByAutoId().key
            self.rootref.child("Buy").child(type_1).child(type_2).child(key).setValue(["user_id": user.uid, "item_name": name, "item_price": price, "item_descp": descp, "user_num": number, "user_addr": addr, "item_image": url]){ (error, ref) -> Void in
                if(error != nil){
                    print("error in uploading data!")
                }else{
                    print("uploaded!")
                    self.load.hideActivityIndicator(uiView: self.view)
                    self.performSegue(withIdentifier: "upload_done_buy", sender: nil)
                }
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(sale){
            self.navigationItem.title = "What would you like to sell?"
        }else{
            self.navigationItem.title = "What would you like to buy?"
        }
        let myPickerView = UIPickerView()
        self.scrollView.contentSize.height = 1400
        myPickerView.delegate = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(uploadViewController.done_pressed))
        
        toolBar.setItems([doneButton], animated: false)
        
        item_type.inputView = myPickerView
        item_type.inputAccessoryView = toolBar
        
        item_descp.layer.borderWidth = 0.5
        item_descp.layer.borderColor = UIColor.gray.cgColor
        
        item_image.layer.borderWidth = 0.5
        item_image.layer.borderColor = UIColor.gray.cgColor
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    
    func done_pressed(){
        item_type.resignFirstResponder()
    }
    
    /**
     Number of data sources (column) in pickerView
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    /**
     Specify number of rows in each column
     - parameter component: Column of pickerView
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(component == 0){
            return types.count
        }else{
            if (component_type == "Electronics") {
                return elec_types.count
            }else if (component_type == "Clothes"){
                return clothes_types.count
            }else if (component_type == "Household"){
                return household_types.count
            }else if (component_type == "Ticket"){
                return ticket_types.count
            }else if (component_type == "Transportation"){
                return trans_types.count
            }else{
                return book_types.count
            }
        }
    }
    
    /**
     Specify the title(text) of each element in row
     - parameter row: Row of pickerView
     - parameter component: Column of pickerView
     */
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(component == 0){
            return types[row]
        }else{
            if (component_type == "Electronics") {
                return elec_types[row]
            }else if (component_type == "Clothes"){
                return clothes_types[row]
            }else if (component_type == "Household"){
                return household_types[row]
            }else if (component_type == "Ticket"){
                return ticket_types[row]
            }else if (component_type == "Transportation"){
                return trans_types[row]
            }else{
                return book_types[row]
            }
        }
    }
    
    /**
     Reload the second column everytime you scroll the first column(component)
     - parameter row: Row of pickerView
     - parameter component: Column of pickerView
     */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        component_type = types[pickerView.selectedRow(inComponent: 0)]
        pickerView.reloadComponent(1)
        
        item_type.text = print_type(main_type: pickerView.selectedRow(inComponent: 0), pickerView: pickerView)
        
    }
    
    /**
     Reload the second column everytime you scroll the first column(component)
     - parameter main_type: The first component of pickerView
     - parameter pickerView: pickerView that we need to implement
     */
    func print_type(main_type: Int, pickerView: UIPickerView) -> String{
        if(main_type == 0){
            return types[main_type] + "/" + elec_types[pickerView.selectedRow(inComponent: 1)]
        }else if(main_type == 1){
            return types[main_type] + "/" + clothes_types[pickerView.selectedRow(inComponent: 1)]
        }else if(main_type == 2){
            return types[main_type] + "/" + household_types[pickerView.selectedRow(inComponent: 1)]
        }else if(main_type == 3){
            return types[main_type] + "/" + ticket_types[pickerView.selectedRow(inComponent: 1)]
        }else if(main_type == 4){
            return types[main_type] + "/" + trans_types[pickerView.selectedRow(inComponent: 1)]
        }else{
            return types[main_type] + "/" + book_types[pickerView.selectedRow(inComponent: 1)]
        }
    }
    
    
}









