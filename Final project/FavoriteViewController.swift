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

        private let ref = Database.database().reference(fromURL: "https://mealplan-327cb-default-rtdb.firebase.com/")
        
        @IBOutlet weak var favoritesTableView: UITableView!
        var favoriteRecipesData: [Dictionary<AnyHashable,Any>] = []
        var foodID : Int!
        var recipeID : Int! = 659015
        var recipes: Set<Int?> = []
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
                        //print(value)
                        
                        self.recipes.insert(self.foodID)
                        //print(String(self.foodID))
                    }
                })
                
            }
            for j in self.recipes{
                print(j!)
                //LoadRecipeData(id: j!)
            }
            LoadRecipeData(id: recipeID)
            setupTableView()
            
        }
    
    
    @IBAction func refreshFav(_ sender: UIButton) {
        for j in self.recipes{
            print(j!)
            LoadRecipeData(id: j!)
        }
        setupTableView()
    }
    
    func LoadRecipeData(id: Int){
           let randomRecipeURL = URL(string: "https://api.spoonacular.com/recipes/\(id)/information?apiKey=1b4fa62e8edf48c3b6f2fcb456aded47&includeNutrition=false")
                  let binaryRandomRecipeResults = try! Data(contentsOf: randomRecipeURL!)
                  if let currentRecipeResults = try! JSONSerialization.jsonObject(with: binaryRandomRecipeResults, options: .fragmentsAllowed) as? Dictionary<AnyHashable,Any>{
                      favoriteRecipesData.append(currentRecipeResults)
   //                   recipeTitle = recipeData["title"] as? String ?? ""
   //                   if let stringRecipeImageURL = recipeData["image"] as? String {
   //                       let recipeImageURL = URL(string: stringRecipeImageURL)
   //                       let data = try? Data(contentsOf: recipeImageURL!)
   //                       recipeImage = UIImage(data: data!)
   //                   }
   //                   else {
   //                       recipeImage = UIImage(named: "No-Image-Placeholder.svg")
   //                   }
                  }
       }
       
       func setupTableView() {
           favoritesTableView.dataSource = self
           favoritesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
       }
       
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   //        let favoritesMoviesID: [Int] = UserDefaults.standard.array(forKey: "favoritesMoviesID") as! [Int]
   //        return favoritesMoviesID.count
           return 1;
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   //        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
   //        let favoritesMoviesID: [Int] = UserDefaults.standard.array(forKey: "favoritesMoviesID") as! [Int]
   //        cell.textLabel!.text = UserDefaults.standard.string(forKey: String(favoritesMoviesID[indexPath.row]))
           let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
           guard let tit = favoriteRecipesData[indexPath.row]["title"] else {return cell}
           cell.textLabel?.text = tit as? String
           if let stringRecipeImageURL = favoriteRecipesData[indexPath.row]["image"] as? String {
                          let recipeImageURL = URL(string: stringRecipeImageURL)
                          let data = try? Data(contentsOf: recipeImageURL!)
               cell.imageView?.image = UIImage(data: data!)
                      }
                      else {
                          cell.imageView?.image = UIImage(named: "No-Image-Placeholder.svg")
                      }
           return cell
       }
       
       func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
           if editingStyle == .delete {
   //            var favoritesMoviesID: [Int] = UserDefaults.standard.array(forKey: "favoritesMoviesID") as! [Int]
   //            let movieIDToDelete: Int = favoritesMoviesID[indexPath.row]
   //            favoritesMoviesID = favoritesMoviesID.filter{$0 != movieIDToDelete}
   //            UserDefaults.standard.removeObject(forKey: String(movieIDToDelete))
   //            UserDefaults.standard.set(favoritesMoviesID, forKey: "favoritesMoviesID")
               favoritesTableView.deleteRows(at: [indexPath], with: .fade)
           }
       }
       
       func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
           if tabBarController.selectedIndex == 1{
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
