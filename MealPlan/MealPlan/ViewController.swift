//
//  ViewController.swift
//  MealPlan
//
//  Created by James Pieper on 11/11/22.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    //var data: [String] = []
    var recipes: [Recipe] = []
    
    
    
    
    struct APIResults:Decodable {
        //let page: Int
        //let total_results: Int
        //let total_pages: Int
        let results: [Recipe]
    }
    
    struct Recipe:Decodable {
        let id: Int!
        let title: String
        let image: String?
        let imageType: String?
    }

    @IBOutlet weak var inputFood: UITextField!
    
    @IBOutlet weak var btnSubmit: UIButton!
    
    
    @IBOutlet weak var recipesTable: UITableView!
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = recipesTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = recipes[indexPath.row].title
        
        return cell
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func searchAPI(_ sender: Any) {
        
        let input = inputFood.text
        inputFood.text = ""
        
        let recipeURL = URL(string:
                                "https://api.spoonacular.com/recipes/complexSearch?apiKey=d713c1e77ea84be39804e88d3307595a&query=\(input ?? "default")")
        
        let recipeData = try! Data(contentsOf: recipeURL!)
        
        
        self.recipes = try! JSONDecoder().decode(APIResults.self, from: recipeData).results
        
        DispatchQueue.main.async {
            self.recipesTable.reloadData()
        }
        
        print(recipes)
        //responseText.text = String(recipes[0].title)
        
        //responseText.text = inputFood.text;
    }
    
}

