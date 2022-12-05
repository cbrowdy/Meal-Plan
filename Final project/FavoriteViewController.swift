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
    var favoriteRecipesData: [[AnyHashable:Any]] = []
    var theImageCache: [UIImage] = []
    
    
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
        self.tabBarController?.delegate = self
        LoadFavoriteRecipesData()
        cacheImages()
        setupTableView()
    }
    
    
    func LoadFavoriteRecipesData(){
        for id in self.recipes{
            let randomRecipeURL = URL(string: "https://api.spoonacular.com/recipes/\(id!)/information?apiKey=1fb7da19f9b4445aa293b61cfa6d479f&includeNutrition=false")
            let binaryRandomRecipeResults = try! Data(contentsOf: randomRecipeURL!)
            if let currentRecipeResults = try! JSONSerialization.jsonObject(with: binaryRandomRecipeResults, options: .fragmentsAllowed) as? Dictionary<AnyHashable,Any>{
                favoriteRecipesData.append(currentRecipeResults)
            }
        }
    }
        
        func cacheImages(){
            for recipeData in favoriteRecipesData{
                let image: UIImage?
                if recipeData["image"] as? String != nil {
                    let stringImageUrl = "https://spoonacular.com/recipeImages/\(recipeData["id"] as? Int)-312x231.jpg"
                    let imageUrl = URL(string: stringImageUrl)
                    let data = try? Data(contentsOf: imageUrl!)
                    image = UIImage(data: data!)
                }
                else{
                    image = UIImage(named: "No-Image-Placeholder.svg")
                }
                theImageCache.append(image!)
            }
        }
        
        func setupTableView() {
            favoritesTableView.dataSource = self
            favoritesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return favoriteRecipesData.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
            cell.textLabel!.text = favoriteRecipesData[indexPath.row]["title"] as? String
            cell.imageView?.image = theImageCache[indexPath.row]
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
