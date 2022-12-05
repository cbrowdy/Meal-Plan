//
//  FavoriteViewController.swift
//  Final project
//
//  Created by Sproull Student on 12/4/22.
//

import UIKit
import Firebase
import FirebaseDatabase

class FavoriteViewController: UIViewController {

    private let ref = Database.database().reference(fromURL: "https://mealplan-327cb-default-rtdb.firebase.com/")
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 1...1000 {
            ref.child(String(i)).observeSingleEvent(of: .value, with: { snapshot in
                guard let value = snapshot.value as? [String: Any] else {return}
                guard let userName = value["User"] as? String else {return}
                if(userName == Auth.auth().currentUser!.uid) {
                    print(value)
                }
            })
        }
        

        // Do any additional setup after loading the view.
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
