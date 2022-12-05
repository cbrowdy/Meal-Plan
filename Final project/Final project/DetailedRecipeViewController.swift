//
//  DetailedRecipeViewController.swift
//  Final project
//
//  Created by Omer Moav on 14/11/2022.
//

import UIKit
import Firebase
import FirebaseDatabase

class DetailedRecipeViewController: UIViewController, UITableViewDataSource {
    
    let apiKey = "d9b36e447e1a488a8c53a19d4168b2b6"
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
        let value: Double?
        let unit: String?
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
                                "https://api.spoonacular.com/recipes/\(recipeID!)/ingredientWidget.json?apiKey=\(apiKey)")
        let binaryAPIResultsData = try! Data(contentsOf: ingredientsURL!)
        ingredientsAPIResultsData = try! JSONDecoder().decode(ingredientsAPIResults.self, from: binaryAPIResultsData)
        ingredientsData = ingredientsAPIResultsData!.ingredients
    }
    
    func fetchDataForInstructionsTableView() {
        let instructionsURL = URL(string:
                                "https://api.spoonacular.com/recipes/\(recipeID!)/analyzedInstructions?apiKey=\(apiKey)")
        let binaryAPIResultsData = try? Data(contentsOf: instructionsURL!)
        if binaryAPIResultsData != nil{
            instructionsAPIResultsData = try! JSONDecoder().decode([instructionsAPIResults].self, from: binaryAPIResultsData!)
            print(instructionsAPIResultsData!)
            instructionsData = (instructionsAPIResultsData?[0].steps)!
            //instructionsData = instructionsAPIResultsData?[0].steps ?? [Step(number: 0, step: "No Instructions Provided", ingredients: nil, equipment: nil, length: Length(number: nil, unit: nil))]
        }else{
            instructionsData = [Step(number: 0, step: "No Instructions Provided", ingredients: nil, equipment: nil, length: Length(number: nil, unit: nil))]
        }
        
    }

    
    func setupTableViews(){
        ingredientsTableView.dataSource = self
        ingredientsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ingredientCell")
//        ingredientsTableView.estimatedRowHeight = 85.0
//        ingredientsTableView.rowHeight = UITableView.automaticDimension
        
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
//            cell.textLabel!.text = ingredientsData[indexPath.row].name!
              cell.textLabel!.text = currentIngredient
//            cell.textLabel!.lineBreakMode = .byWordWrapping
//            cell.textLabel!.numberOfLines = 0
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
    
    private let ref = Database.database().reference(fromURL: "https://mealplan-327cb-default-rtdb.firebase.com/")
    @IBAction func favoriteRecipe(_ sender: UIButton) {
        
        let object: [String: Any] = [
            "ID":recipeID!,
            "User":String(Auth.auth().currentUser!.uid)
        ]
        ref.child(String(Int.random(in: 0..<1000))).setValue(object)
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
