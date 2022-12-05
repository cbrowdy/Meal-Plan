//
//  InstructionsViewController.swift
//  Food and Recipe
//
//  Created by Ajay Choudhary on 01/10/19.
//  Copyright © 2019 Ajay Choudhary. All rights reserved.
//

import UIKit
import CoreData

class InstructionsViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let tableView = UITableView()
    var recipe: Recipe!
    var foodRecipe: FoodRecipe!
    var isSavedRecipe = false
    var instructions = [Instruction]()
    var instructionsArray = [String]()
    
    //MARK: - Core Data setup
    
    override func viewDidLoad() {
        if foodRecipe != nil {
            isSavedRecipe = true
            setupFetchRequest()
            return
        }
        if let instructions = recipe.instructions {
            self.instructionsArray = instructions
        } else {
            presentAlert(title: "Instructions Unavailable", message: "")
        }
    }
    
    private func setupFetchRequest() {
        let fetchRequest: NSFetchRequest<Instruction> = Instruction.fetchRequest()
        let predicate = NSPredicate(format: "foodRecipe == %@", foodRecipe)
        let sortDescriptor = NSSortDescriptor(key: "stepNumber", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        if let result = try? appDelegate.persistentContainer.viewContext.fetch(fetchRequest) {
            instructions = result
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
        self.title = "Instructions"
        setupTableView()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

    //MARK: - Setup TableView

extension InstructionsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSavedRecipe {
            return instructions.count
        } else {
            return instructionsArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if isSavedRecipe == false {
            let instruction = instructionsArray[indexPath.row]
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = UIFont(name: "Verdana", size: 16)
            cell.textLabel?.text = "\(indexPath.row + 1). \(instruction)"
        } else {
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = UIFont(name: "Verdana", size: 16)
            cell.textLabel?.text = "\(indexPath.row + 1). \(instructions[indexPath.row].instruction!)"
        }
        return cell
    }
}

