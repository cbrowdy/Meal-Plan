//
//  DetailedRecipeViewController.swift
//  Final project
//
//  Created by Omer Moav on 14/11/2022.
//

import UIKit

class DetailedRecipeViewController: UIViewController, UITableViewDataSource {
    
    var recipeID: Int!
    var recipeTitle: String!
    var recipeImage: UIImage?
    
    var ingredientsAPIResultsData: ingredientsAPIResults?
    var ingredientsData: [Ingredient] = []
    var instructionsAPIResultsData: [instructionsAPIResults]?
    var instructionsData: [Step] = []
    
    struct ingredientsAPIResults:Decodable {
        let ingredients: [Ingredient]
    }
    
    struct Ingredient:Decodable {
        let name: String?
        let image: String?
        let amount: Amount?
    }
    
    struct Amount:Decodable {
        let metric: Metric?
        let us: US?
    }
    
    struct Metric:Decodable {
        let value: Double?
        let unit: String?
    }
    
    struct US:Decodable {
        let metric: Double?
        let us: String?
    }
    
    struct instructionsAPIResults:Decodable {
        let name: String?
        let steps:[Step]?
    }
    
    struct Step:Decodable {
        let number: Int?
        let step: String?
        let ingredients:[IngredientOfInstruction]?
        let equipment: [Equipment]?
        let length: Length?
    }
    
    struct IngredientOfInstruction:Decodable {
        let id: Int?
        let name:String?
        let localizedName: String?
        let image: String?
    }
    
    struct Equipment:Decodable {
        let id: Int?
        let name:String?
        let localizedName: String?
        let image: String?
        let temperature: Temperature?
    }
    
    struct Temperature:Decodable {
        let number: Double?
        let unit: String?
    }
    
    struct Length: Decodable {
        let number: Int?
        let unit: String?
    }
    
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var recipeUIImage: UIImageView!
    @IBOutlet weak var ingredientsTableView: UITableView!
    @IBOutlet weak var instructionsTableView: UITableView!
    @IBOutlet weak var ingredientsTableViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var instructionsTableViewHeightConstraints: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        recipeNameLabel.text = recipeTitle
        recipeUIImage.image = recipeImage
        fetchDataForIngredientsTableView()
        fetchDataForInstructionsTableView()
        setupTableViews()
    }
    
    func fetchDataForIngredientsTableView() {
        let ingredientsURL = URL(string:
                                "https://api.spoonacular.com/recipes/\(recipeID!)/ingredientWidget.json?apiKey=804dbeff69ea4e25a1051ae9714d9e63")
        let binaryAPIResultsData = try! Data(contentsOf: ingredientsURL!)
        ingredientsAPIResultsData = try! JSONDecoder().decode(ingredientsAPIResults.self, from: binaryAPIResultsData)
        ingredientsData = ingredientsAPIResultsData!.ingredients
    }
    
    func fetchDataForInstructionsTableView() {
        let instructionsURL = URL(string:
                                "https://api.spoonacular.com/recipes/\(recipeID!)/analyzedInstructions?apiKey=804dbeff69ea4e25a1051ae9714d9e63")
        let binaryAPIResultsData = try! Data(contentsOf: instructionsURL!)
        instructionsAPIResultsData = try! JSONDecoder().decode([instructionsAPIResults].self, from: binaryAPIResultsData)
        print(instructionsAPIResultsData!)
        instructionsData = instructionsAPIResultsData?[0].steps ?? [Step(number: 0, step: "No Instructions Provided", ingredients: nil, equipment: nil, length: Length(number: nil, unit: nil))]
    }

    
    func setupTableViews(){
        ingredientsTableView.dataSource = self
        ingredientsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ingredientCell")
        instructionsTableView.dataSource = self
        instructionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "instructionCell")
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
            cell.textLabel!.text = ingredientsData[indexPath.row].name!
            return cell
        }
        else if tableView == self.instructionsTableView {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "instructionCell")
            cell.textLabel!.text = instructionsData[indexPath.row].step ?? ""
            return cell
        }
        return UITableViewCell()
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
