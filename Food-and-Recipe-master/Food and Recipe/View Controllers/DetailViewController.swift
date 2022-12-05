//
//  DetailViewController.swift
//  Food and Recipe
//
//  Created by Ajay Choudhary on 29/09/19.
//  Copyright © 2019 Ajay Choudhary. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var recipe: Recipe!
    var ingredientsArray = [String]()
    var ingredients = [Ingredient]()
    var image = UIImage()
    var isSavedRecipe = false
    var foodRecipe: FoodRecipe!
    let instructionsButton = UIButton()
    let tableView = UITableView.init(frame: CGRect.zero, style: .grouped)
    
    //MARK:- Core Data setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if foodRecipe != nil {
            isSavedRecipe = true
            setupFetchRequest()
            return
        }
        if let ingredients = recipe.ingredients {
            self.ingredientsArray = ingredients
        }
        setupNavigationButtons()
    }
    
    private func setupFetchRequest() {
        let fetchRequest: NSFetchRequest<Ingredient> = Ingredient.fetchRequest()
        let predicate = NSPredicate(format: "foodRecipe == %@", foodRecipe)
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = predicate
        if let result = try? appDelegate.persistentContainer.viewContext.fetch(fetchRequest) {
            ingredients = result
            tableView.reloadData()
        }
    }
    
    //MARK: - Setup View
    
    override func loadView() {
        super.loadView()
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        self.tabBarController?.tabBar.isHidden = true
        setupInstructionButton()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 85.0
        tableView.rowHeight = UITableView.automaticDimension
        
        
        view.addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: instructionsButton.topAnchor, constant: -5).isActive = true
    }
    
    //MARK:- Setup Navigation Buttons
    
    private func setupNavigationButtons() {
        if isSavedRecipe == false {
            let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveAction))
            self.navigationItem.rightBarButtonItem = saveButton
        }
    }
    
    private func setupInstructionButton() {
        view.addSubview(instructionsButton)
        
        instructionsButton.translatesAutoresizingMaskIntoConstraints = false
        instructionsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        instructionsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        instructionsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        instructionsButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        instructionsButton.setTitle("Instructions", for: .normal)
        instructionsButton.setTitleColor(.white, for: .normal)
        instructionsButton.backgroundColor = #colorLiteral(red: 0.3259045561, green: 0.6834023016, blue: 1, alpha: 1)
        instructionsButton.addTarget(self, action: #selector(showInstructionsAction), for: .touchUpInside)
    }
    
    @objc func saveAction() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let imageData = image.pngData()
        let foodRecipe = FoodRecipe(context: appDelegate.persistentContainer.viewContext)
        foodRecipe.title = recipe.title
        foodRecipe.sourceURL = recipe.sourceURL
        foodRecipe.timeRequired = Int64(recipe.timeRequired!)
        foodRecipe.image = imageData
        
            
        if ingredientsArray.count != 0 {
            for ingredientString in ingredientsArray {
                let ingredient = Ingredient(context: appDelegate.persistentContainer.viewContext)
                ingredient.ingredient = ingredientString
                ingredient.foodRecipe = foodRecipe
            }
        } else {
            foodRecipe.ingredients = []
        }
        
        if let instructions = recipe.instructions {
            if instructions.count != 0 {
                var count = 1
                for instructionString in instructions {
                    let instruction = Instruction(context: appDelegate.persistentContainer.viewContext)
                    instruction.instruction = instructionString
                    instruction.foodRecipe = foodRecipe
                    instruction.stepNumber = Int64(count)
                    count += 1
                }
            } else {
                foodRecipe.instructions = []
            }
        }
        
        do {
            try appDelegate.persistentContainer.viewContext.save()
            presentAlert(title: "Recipe Saved", message: "")
        } catch {
            presentAlert(title: "Unable to save the recipe", message: "")
        }
    }

    @objc func showInstructionsAction() {
        if isSavedRecipe {
            if foodRecipe.instructions?.count == 0 {
                if let url = URL(string: foodRecipe.sourceURL ?? "") {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        self.presentAlert(title: "Instructions Unavailable", message: "")
                    }
                } else {
                    self.presentAlert(title: "Instructions Unavailable", message: "")
                }
            } else {
                let instructionsVC = InstructionsViewController()
                instructionsVC.foodRecipe = foodRecipe
                self.navigationController?.pushViewController(instructionsVC, animated: true)
            }
            return
        }
                
        if let instructions = recipe.instructions {
            if instructions.count == 0 {
                if let url = URL(string: recipe.sourceURL ?? "") {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        self.presentAlert(title: "Instructions Unavailable", message: "")
                    }
                } else {
                    self.presentAlert(title: "Instructions Unavailable", message: "")
                }
            } else {
                let instructionsVC = InstructionsViewController()
                instructionsVC.recipe = recipe
                self.navigationController?.pushViewController(instructionsVC, animated: true)
            }
        } else {
            presentAlert(title: "Instructions Unavailable", message: "")
        }
    }
    
    private func createHeaderView() -> CustomHeaderCell{
        let headerView = CustomHeaderCell()
        if isSavedRecipe == false {
            if let title = recipe.title  {
                headerView.recipeTitleLabel.text = title
            }
            if let time = recipe.timeRequired {
                headerView.timingLabel.text = " Time Required: \(time) Minutes"
            }
            if let imageURL = recipe.imageURL {
                SpoonacularClient.downloadRecipeImage(imageURL: imageURL) { (image, success) in
                    if success {
                        if let image = image {
                            self.image = image
                        } else {
                            self.image = UIImage(named: "imagePlaceholder")!
                        }
                        headerView.imageView.image = image
                    } else {
                        headerView.imageView.image = UIImage(named: "imagePlaceholder")
                        self.presentAlert(title: "Image not available", message: "")
                    }
                }
            }
            headerView.ingredientsLabel.text = "  Ingredients (\(ingredientsArray.count) items)"
        } else {
            headerView.recipeTitleLabel.text = foodRecipe.title
            headerView.timingLabel.text = "Time Required: \(foodRecipe.timeRequired) Minutes"
            headerView.imageView.image = UIImage(data: foodRecipe.image!)
            headerView.ingredientsLabel.text = "  Ingredients (\(foodRecipe.ingredients!.count) items)"
        }
        return headerView
    }
    
}

    //MARK: - Setup TableView

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.frame.width
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = createHeaderView()
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSavedRecipe == false {
            return ingredientsArray.count
        } else {
            return ingredients.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = UIFont(name: "Verdana", size: 16)
        if isSavedRecipe == false {
            let ingredient = ingredientsArray[indexPath.row]
            cell.textLabel?.text = "\(indexPath.row + 1). \(ingredient)"
        } else {
            cell.textLabel?.text = "\(indexPath.row + 1). \(ingredients[indexPath.row].ingredient!)"
        }
        return cell
    }
}



