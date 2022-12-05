//
//  FavoriteViewController.swift
//  Final project
//
//  Created by Sproull Student on 12/5/22.
//

import UIKit
import Firebase
import FirebaseDatabase

class FavoriteViewController: UIViewController, UITableViewDataSource, UITabBarControllerDelegate {

    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    let apiKey = "d9b36e447e1a488a8c53a19d4168b2b6"
        private let ref = Database.database().reference(fromURL: "https://mealplan-327cb-default-rtdb.firebase.com/")
        
        @IBOutlet weak var favoritesTableView: UITableView!
        var favoriteRecipesData: [Dictionary<AnyHashable,Any>] = []
        var foodID : Int!
    var theImageCache: [UIImage] = []

    
        override func viewDidLoad() {
            super.viewDidLoad()
            self.tabBarController?.delegate = self
            loadingSpinner.isHidden = false
            loadingSpinner.startAnimating()
            DispatchQueue.global(qos: .userInitiated).async {
                self.fetchIDs()
                
            }
                DispatchQueue.main.async {
                    self.loadingSpinner.stopAnimating()
                    self.loadingSpinner.isHidden = true
                    self.favoritesTableView.reloadData()
                }
            setupTableView()
            favoritesTableView.reloadData()
            
            
        }
    
    func fetchIDs(){
        for i in 1...1000 {
            ref.child(String(i)).observeSingleEvent(of: .value, with: { snapshot in
                guard let value = snapshot.value as? [String: Any] else {return}
                guard let userName = value["User"] as? String else {return}
                guard let fID = value["ID"] as? Int else {return}
                self.foodID = fID
                if(userName == Auth.auth().currentUser!.uid) {
                    self.LoadRecipeData(id: fID)
                }
            })
            
        }
    }
    
    
    func LoadRecipeData(id: Int){
        let recipeURL = URL(string: "https://api.spoonacular.com/recipes/\(id)/information?apiKey=\(apiKey)&includeNutrition=false")
                  let binaryRandomRecipeResults = try! Data(contentsOf: recipeURL!)
                  if let currentRecipeResults = try! JSONSerialization.jsonObject(with: binaryRandomRecipeResults, options: .fragmentsAllowed) as? Dictionary<AnyHashable,Any>{
                      favoriteRecipesData.append(currentRecipeResults)
                  }
       }
       
       func setupTableView() {
           favoritesTableView.dataSource = self
           favoritesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
       }
       
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return favoriteRecipesData.count;
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
           cell.backgroundColor = UIColor(red: 255, green: 204, blue: 255, alpha: 0)
           guard let tit = favoriteRecipesData[indexPath.row]["title"] else {return cell}
           cell.textLabel?.text = tit as? String
           print(theImageCache)
           if let stringImgURL = favoriteRecipesData[indexPath.row]["image"] as? String{
               let imageUrl = URL(string: stringImgURL)
               let data = try? Data(contentsOf: imageUrl!)
               cell.imageView?.image = UIImage(data: data!)
           }else{
               cell.imageView?.image = UIImage(named: "No-Image-Placeholder.svg")
           }
           return cell
       }
       
       func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
           if editingStyle == .delete {
               favoritesTableView.deleteRows(at: [indexPath], with: .fade)
           }
       }
       
       func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
           print(tabBarController.selectedIndex)
           if tabBarController.selectedIndex == 2{
               favoritesTableView.reloadData()
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

