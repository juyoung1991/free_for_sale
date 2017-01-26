//
//  RegisterViewController.swift
//  sell_buy_item
//
//  Created by Ju Young Kim on 2016. 10. 31..
//  Copyright © 2016년 Ju Young Kim. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    let rootref = FIRDatabase.database().reference()
    
    @IBOutlet weak var emailLabel: UITextField!

    @IBOutlet weak var firstNameLabel: UITextField!
    
    @IBOutlet weak var lastNameLabel: UITextField!
    
    @IBOutlet weak var passWordLabel: UITextField!
    
    @IBOutlet weak var passWordConfirmLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
     Create new account and add it to database
     - parameter sender: Object that sent the action message
     */
    @IBAction func createAccount(_ sender: Any) {
        let email = emailLabel.text
        let first_name = firstNameLabel.text
        let last_name = lastNameLabel.text
        let password = passWordLabel.text
        let passwordConfirm = passWordConfirmLabel.text
        if(password != passwordConfirm){
            self.alertMessage(title: "Oops!", message: "password not matching!")
        }else{
            if(email != "" && password != ""){
                FIRAuth.auth()?.createUser(withEmail: email!, password: password!, completion:  { (user, error) in
                    if (error != nil){
                        //if there is an error
                        self.alertMessage(title: "Oops!", message: (error?.localizedDescription)!)
                        
                    }else{
                        //Add info to database
                        self.rootref.child("users").child((user!.uid)).setValue(["userEmail": email, "first name": first_name, "last name": last_name, "password": password])
                        //Segue to next page
                        self.performSegue(withIdentifier: "toList", sender: nil)
                    }
                })
            }else{
                self.alertMessage(title: "Oops!", message: "Please check your email and password.")
            }
        }

    }
}

