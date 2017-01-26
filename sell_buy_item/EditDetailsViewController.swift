import UIKit
import Firebase
import FirebaseStorage

class EditDetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UISearchControllerDelegate, UISearchBarDelegate{
    
    let rootref = FIRDatabase.database().reference()
    
    var image = UIImage()
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var item_name: UITextField!
    
    @IBOutlet weak var item_price: UITextField!
    
    @IBOutlet weak var user_number: UITextField!
    
    @IBOutlet weak var item_descp: UITextView!
    
    @IBOutlet weak var item_image: UIImageView!
    
    @IBOutlet weak var addrLabel: UILabel!
    
    var item_details = Dictionary<String, String>()
    
    var sale = Bool()
    
    var load = LoadingAnimate()
    
    var image_changed = false
    
    /**
     Unwind function to allow other viewcontroller to unwind to this view
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
            image_changed = true
            
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
        let user = FIRAuth.auth()?.currentUser
        let type_1 = item_details["type_1"]
        let type_2 = item_details["type_2"]
        let key = item_details["key"]
        let name = item_name.text
        let price = item_price.text
        let descp = item_descp.text
        let image = item_image.image
        let addr = addrLabel.text
        let number = user_number.text
        var img_url_str:String?
        
        if(name != "" && price != "" && descp != "" && addr != "" && number != ""){
            if(image != nil){
                self.load.showActivityIndicator(uiView: self.view)
                let storageRef = FIRStorage.storage().reference()
                let imageref = storageRef.child((user?.uid)!).child(name!)
                if(image_changed){
                    let imageData = UIImagePNGRepresentation(image!.resizeWith(percentage: 0.1)!)
                    let uploadTask = imageref.put(imageData!, metadata: nil, completion: { (metadata, error) in
                        print("")
                        if(error != nil){
                            print("Error uploading image")
                        }else{
                            let img_url = metadata!.downloadURL()!
                            self.addToDataBase(type_1: type_1!, type_2: type_2!, user: user!, name: name!, price: price!, descp: descp!, number: number!, addr: addr!, url: img_url.absoluteString, key: key!)
                        }
                    })
                }else{
                    let imageData = UIImagePNGRepresentation(image!)
                    let uploadTask = imageref.put(imageData!, metadata: nil, completion: { (metadata, error) in
                        print("")
                        if(error != nil){
                            print("Error uploading image")
                        }else{
                            let img_url = metadata!.downloadURL()!
                            self.addToDataBase(type_1: type_1!, type_2: type_2!, user: user!, name: name!, price: price!, descp: descp!, number: number!, addr: addr!, url: img_url.absoluteString, key: key!)
                        }
                    })
                }
                
                
            }else{
                img_url_str = ""
                self.addToDataBase(type_1: type_1!, type_2: type_2!, user: user!, name: name!, price: price!, descp: descp!, number: number!, addr: addr!, url: img_url_str!, key: key!)
            }
        }else{
            self.alertMessage(title: "Oops!", message: "Make sure you fill everything out!")
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "edit_done_sale"){
            let mainVC = segue.destination as! SaleListViewController
            mainVC.edit = true
        }else if(segue.identifier == "edit_done_buy"){
            let mainVC = segue.destination as! BuyListViewController
            mainVC.edit = true
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
    func addToDataBase(type_1:String, type_2:String, user:FIRUser, name:String, price:String, descp:String, number: String, addr:String, url: String, key:String){
        if(sale){
            self.rootref.child("Sale").child(type_1).child(type_2).child(key).setValue(["user_id": user.uid, "item_name": name, "item_price": price, "item_descp": descp, "user_num": number, "user_addr": addr, "item_image": url]){ (error, ref) -> Void in
                if(error != nil){
                    print("error in saving data!")
                }else{
                    print("edited!")
                    self.load.hideActivityIndicator(uiView: self.view)
                    self.performSegue(withIdentifier: "edit_done_sale", sender: nil)
                }
            }
        }else{
            self.rootref.child("Buy").child(type_1).child(type_2).child(key).setValue(["user_id": user.uid, "item_name": name, "item_price": price, "item_descp": descp, "user_num": number, "user_addr": addr, "item_image": url]){ (error, ref) -> Void in
                if(error != nil){
                    print("error in saving data!")
                }else{
                    print("edited!")
                    self.load.hideActivityIndicator(uiView: self.view)
                    self.performSegue(withIdentifier: "edit_done_buy", sender: nil)
                }
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.item_name.text = item_details["item_name"]
        self.item_price.text = item_details["item_price"]
        self.user_number.text = item_details["user_num"]
        self.item_descp.text = item_details["item_descp"]
        self.scrollView.contentSize.height = 1400
        self.item_image.image = self.image
        self.addrLabel.text = item_details["user_addr"]

        item_descp.layer.borderWidth = 0.5
        item_descp.layer.borderColor = UIColor.gray.cgColor
        
        item_image.layer.borderWidth = 0.5
        item_image.layer.borderColor = UIColor.gray.cgColor
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}










