//
//  ViewController.swift
//  Food and Recipe
//
//  Created by Ajay Choudhary on 26/09/19.
//  Copyright © 2019 Ajay Choudhary. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    let tableView = UITableView()
    var activityIndicatorContainer: UIView!
    var refreshButton: UIBarButtonItem!
    var activityIndicator: UIActivityIndicatorView!
    var recipes = [Recipe]()
    
    override func loadView() {
        super.loadView()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: - Setup View
    
    private func setupView() {
        self.title = "Feed"
        view.backgroundColor = .white
        setupTableView()
        setupRefreshButton()
        setupActivityIndicator()
        showActivityIndicator(show: true)
        SpoonacularClient.getRandomRecipe(completion: handleRecipes)
    }
    
    private func setupRefreshButton() {
        refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshTapped))
        self.navigationItem.rightBarButtonItem = refreshButton
    }
    
    @objc func refreshTapped() {
        setupActivityIndicator()
        showActivityIndicator(show: true)
        SpoonacularClient.getRandomRecipe(completion: handleRecipes)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 120
        tableView.register(CustomRecipeCell.self, forCellReuseIdentifier: "cell")
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func setupActivityIndicator() {
        
        activityIndicatorContainer = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        activityIndicatorContainer.center.x = view.center.x
        activityIndicatorContainer.center.y = view.center.y
        activityIndicatorContainer.backgroundColor = UIColor.black
        activityIndicatorContainer.alpha = 0.8
        activityIndicatorContainer.layer.cornerRadius = 10
          
        // Configure the activity indicator
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorContainer.addSubview(activityIndicator)
        view.addSubview(activityIndicatorContainer)
            
        // Constraints
        activityIndicator.centerXAnchor.constraint(equalTo: activityIndicatorContainer.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: activityIndicatorContainer.centerYAnchor).isActive = true
    }
    
    private func showActivityIndicator(show: Bool) {
      if show {
        DispatchQueue.main.async{
            self.tableView.allowsSelection = false
            self.activityIndicator.startAnimating()
            self.refreshButton.isEnabled = false
        }
      } else {
            DispatchQueue.main.async{
                self.tableView.allowsSelection = true
                self.refreshButton.isEnabled = true
                self.activityIndicator.stopAnimating()
                self.activityIndicatorContainer.removeFromSuperview()
            }
        }
    }
    
    //MARK: - Handle API Response
    
    func handleRecipes(recipes: [Recipe], error: Error?) {
        self.showActivityIndicator(show: false)
        if let error = error {
            DispatchQueue.main.async {
                self.presentAlert(title: error.localizedDescription, message: "")
            }
        }
        self.recipes = recipes
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}

    //MARK: - Setup TableView

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomRecipeCell
        let recipe = recipes[indexPath.row]
        if let title = recipe.title {
            cell.recipeTitle.text = title
        }
        if let time = recipe.timeRequired {
            cell.durationTitle.text = String("\(time) minutes")
        }
        cell.recipeImageView.image = UIImage(named: "imagePlaceholder")
        if let imageURL = recipe.imageURL {
            SpoonacularClient.downloadRecipeImage(imageURL: imageURL) { (image, success) in
                cell.recipeImageView.image = image
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recipe = recipes[indexPath.row]
        if recipe.ingredients?.count == 0 {
            if let url = URL(string: recipe.sourceURL ?? "") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    self.presentAlert(title: "Recipe Unavailable", message: "")
                }
            } else {
                self.presentAlert(title: "Recipe Unavailable", message: "")
            }
        } else {
            let detailVC = DetailViewController()
            detailVC.recipe = recipe
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
}





