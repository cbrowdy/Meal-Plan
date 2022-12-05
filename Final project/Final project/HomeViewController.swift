//
//  HomeViewController.swift
//  Final project
//
//  Created by Omer Moav on 04/12/2022.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDataSource {
    
//    var recipeID: Int! = 133212
    
    var recipeData:Dictionary<String,Any>!
    var recipeID: Int!
    var recipeTitle: String!
    var recipeImage: UIImage?
    
    var ingredientsAPIResultsData: DetailedRecipeViewController.ingredientsAPIResults?
    var ingredientsData: [DetailedRecipeViewController.Ingredient] = []
    var instructionsAPIResultsData: [DetailedRecipeViewController.instructionsAPIResults]?
    var instructionsData: [DetailedRecipeViewController.Step] = []
    
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var recipeUIImage: UIImageView!
    @IBOutlet weak var ingredientsTableView: UITableView!
    @IBOutlet weak var instructionsTableView: UITableView!
    @IBOutlet weak var ingredientsTableViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var instructionsTableViewHeightConstraints: NSLayoutConstraint!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        GenerateRandomRecipe()
        recipeNameLabel.text = recipeTitle
        recipeUIImage.image = recipeImage
        fetchDataForIngredientsTableView()
        fetchDataForInstructionsTableView()
        setupTableViews()
    }
    
    func GenerateRandomRecipe(){
        let randomRecipeURL = URL(string: "https://api.spoonacular.com/recipes/random?apiKey=7ca4f47e9c2a400fafd3cb3fb95298fb&number=1&includeNutrition=false")
        let binaryRandomRecipeResults = try! Data(contentsOf: randomRecipeURL!)
        if let randomRecipeResults = try! JSONSerialization.jsonObject(with: binaryRandomRecipeResults, options: .fragmentsAllowed) as? [String:Any]{
            recipeData = (((randomRecipeResults["recipes"] as! NSArray)[0]) as! Dictionary<String,Any>)
            recipeID = recipeData["id"]! as? Int ?? 0
            recipeTitle = recipeData["title"] as? String ?? ""
            if let stringRecipeImageURL = recipeData["image"] as? String {
                let recipeImageURL = URL(string: stringRecipeImageURL)
                let data = try? Data(contentsOf: recipeImageURL!)
                recipeImage = UIImage(data: data!)
            }
            else {
                recipeImage = UIImage(named: "No-Image-Placeholder.svg")
            }
        }
    }
    
    func fetchDataForIngredientsTableView() {
        let ingredientsURL = URL(string:
                                "https://api.spoonacular.com/recipes/\(recipeID!)/ingredientWidget.json?apiKey=7ca4f47e9c2a400fafd3cb3fb95298fb")
        let binaryAPIResultsData = try! Data(contentsOf: ingredientsURL!)
        ingredientsAPIResultsData = try! JSONDecoder().decode(DetailedRecipeViewController.ingredientsAPIResults.self, from: binaryAPIResultsData)
        ingredientsData = ingredientsAPIResultsData!.ingredients
    }
    
    func fetchDataForInstructionsTableView() {
        let instructionsURL = URL(string:
                                "https://api.spoonacular.com/recipes/\(recipeID!)/analyzedInstructions?apiKey=7ca4f47e9c2a400fafd3cb3fb95298fb")
        let binaryAPIResultsData = try! Data(contentsOf: instructionsURL!)
        instructionsAPIResultsData = try! JSONDecoder().decode([DetailedRecipeViewController.instructionsAPIResults].self, from: binaryAPIResultsData)
        print(instructionsAPIResultsData!)
        instructionsData = instructionsAPIResultsData?[0].steps ?? [DetailedRecipeViewController.Step(number: 0, step: "No Instructions Provided", ingredients: nil, equipment: nil, length: DetailedRecipeViewController.Length(number: nil, unit: nil))]
    }

    func setupTableViews(){
        ingredientsTableView.dataSource = self
        ingredientsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ingredientCell")
        
        instructionsTableView.dataSource = self
        instructionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "instructionCell")
        instructionsTableView.estimatedRowHeight = 150.0
        instructionsTableView.rowHeight = UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.ingredientsTableView {
            return ingredientsData.count
        }
        else if tableView == self.instructionsTableView {
            return instructionsData.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.ingredientsTableView {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "ingredientCell")
            let currentIngredient = getIngredientByIndex(index: indexPath.row)
            cell.textLabel!.text = currentIngredient
            return cell
        }
        else if tableView == self.instructionsTableView {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "instructionCell")
            cell.textLabel!.text = instructionsData[indexPath.row].step ?? ""
            cell.textLabel!.numberOfLines = 0
            return cell
        }
        return UITableViewCell()
    }
    
    func getIngredientByIndex(index: Int) -> String {
        let ingredient = ingredientsData[index].name
        let amountValue:String = String(ingredientsData[index].amount?.us?.value ?? 0)
        let amountUnit:String = ingredientsData[index].amount?.us?.unit ?? ""
        return amountValue + " " + amountUnit + " " + (ingredient ?? "")
    }
    
    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()
        self.ingredientsTableViewHeightConstraints?.constant = self.ingredientsTableView.contentSize.height
        self.instructionsTableViewHeightConstraints?.constant = self.instructionsTableView.contentSize.height
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
