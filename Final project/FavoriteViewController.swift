//
//  FavoriteViewController.swift
//  Final project
//
//  Created by Sproull Student on 12/5/22.
//

import UIKit
import Firebase
import FirebaseDatabase

class FavoriteViewController: UIViewController {

        private let ref = Database.database().reference(fromURL: "https://mealplan-327cb-default-rtdb.firebase.com/")
        
        @IBOutlet weak var favoritesTableView: UITableView!
        
        var foodID : Int!
        var recipes: Set<Int?> = []
        override func viewDidLoad() {
            super.viewDidLoad()
            for i in 1...1000 {
                ref.child(String(i)).observeSingleEvent(of: .value, with: { snapshot in
                    guard let value = snapshot.value as? [String: Any] else {return}
                    guard let userName = value["User"] as? String else {return}
                    guard let fID = value["ID"] as? Int else {return}
                    if(userName == Auth.auth().currentUser!.uid) {
                        //print(value)
                        self.foodID = fID
                        self.recipes.insert(self.foodID)
                        //print(String(self.foodID))
                    }
                })
                
            }
            
            
        }
    
    
    @IBAction func refreshFav(_ sender: UIButton) {
        for j in self.recipes{
            print(j!)
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
