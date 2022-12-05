//
//  FavoriteViewController.swift
//  Final project
//
//  Created by Sproull Student on 12/4/22.
//

import UIKit
import Firebase
import FirebaseDatabase

class FavoriteViewController: UIViewController, UITableViewDataSource, UITabBarControllerDelegate {

    private let ref = Database.database().reference(fromURL: "https://mealplan-327cb-default-rtdb.firebase.com/")
    
    @IBOutlet weak var favoritesTableView: UITableView!
    
    var foodID : Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.delegate = self
        for i in 1...1000 {
            ref.child(String(i)).observeSingleEvent(of: .value, with: { snapshot in
                guard let value = snapshot.value as? [String: Any] else {return}
                guard let userName = value["User"] as? String else {return}
                guard let fID = value["ID"] as? Int else {return}
                self.foodID = fID
                if(userName == Auth.auth().currentUser!.uid) {
                    print(value)
                    print(String(self.foodID))
                }
            })
        }
        
        setupTableView()
        // Do any additional setup after loading the view.
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex == 1{
            favoritesTableView.reloadData()
        }
    }
    
    func setupTableView() {
        favoritesTableView.dataSource = self
        favoritesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let favoritesMoviesID: [Int] = UserDefaults.standard.array(forKey: "favoritesMoviesID") as! [Int]
        return favoritesMoviesID.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        let favoritesMoviesID: [Int] = UserDefaults.standard.array(forKey: "favoritesMoviesID") as! [Int]
        cell.textLabel!.text = UserDefaults.standard.string(forKey: String(favoritesMoviesID[indexPath.row]))
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var favoritesMoviesID: [Int] = UserDefaults.standard.array(forKey: "favoritesMoviesID") as! [Int]
            let movieIDToDelete: Int = favoritesMoviesID[indexPath.row]
            favoritesMoviesID = favoritesMoviesID.filter{$0 != movieIDToDelete}
            UserDefaults.standard.removeObject(forKey: String(movieIDToDelete))
            UserDefaults.standard.set(favoritesMoviesID, forKey: "favoritesMoviesID")
            favoritesTableView.deleteRows(at: [indexPath], with: .fade)
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
