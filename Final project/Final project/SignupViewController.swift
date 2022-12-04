//
//  SignupViewController.swift
//  Final project
//
//  Created by Connor Browder on 12/4/22.
//

import UIKit
import Firebase

class SignupViewController: UIViewController {

    
    
    @IBOutlet weak var emailtextfield: UITextField!
    @IBOutlet weak var passwordtextfield: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signupClicked(_ sender: UIButton) {
        guard let email = emailtextfield.text else { return }
        guard let password = passwordtextfield.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { firebaseResult, error in
            if let e = error {
                print("error")
            }
            else {
                self.performSegue(withIdentifier: "goToNext", sender: self)
            }
            
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
