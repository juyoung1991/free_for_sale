//
//  ViewController.swift
//  sell_buy_item
//
//  Created by Ju Young Kim on 2016. 10. 31..
//  Copyright © 2016년 Ju Young Kim. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {}
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        
            FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
                if let user = user{
                    self.performSegue(withIdentifier: "login", sender: nil)
                }else{
                    print("no users signed in!")
                }
            })
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Signs in a user when the button linked with the IBAction is clicked.
     - parameter sender: Object that sent the action message
     */
    @IBAction func sign_in(_ sender: Any) {
        FIRAuth.auth()?.signIn(withEmail: self.emailLabel.text!, password: self.passwordLabel.text!, completion: { (auth, error) in
            if(error != nil){
                self.alertMessage(title: "Oops!", message: "Wrong email and password!")
            }else{
                self.performSegue(withIdentifier: "login", sender: nil)
            }
        })
        
    }


}

