//
//  SearchViewController.swift
//  Food and Recipe
//
//  Created by Ajay Choudhary on 26/09/19.
//  Copyright © 2019 Ajay Choudhary. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    let searchBar = UISearchBar()
    let tableView = UITableView()
    var recipeSearchSuggestions = [AutoCompleteSearchResponse]()
    var currentSearchTask: URLSessionTask?
    
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
        self.title = "Search"
        view.backgroundColor = .white
        seatupSearchBar()
        setupTableView()
    }
    
    private func seatupSearchBar() {
        view.addSubview(searchBar)
        
        searchBar.delegate = self
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        searchBar.placeholder = "Search"
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
}

    //MARK: - Setup SearchBar

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentSearchTask?.cancel()
        currentSearchTask = SpoonacularClient.autoCompleteRecipeSearch(query: searchText) { (recipeSearchSuggestions, error) in
            self.recipeSearchSuggestions = recipeSearchSuggestions
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        currentSearchTask?.resume()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.resignFirstResponder()
    }
}

    //MARK: - Setup TableView

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeSearchSuggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.font = UIFont(name: "Verdana", size: 16)
        cell?.textLabel?.text = recipeSearchSuggestions[indexPath.row].title
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let searchResultVC = SearchResultsViewController()
        searchResultVC.searchQuery = recipeSearchSuggestions[indexPath.row].title
        self.navigationController?.pushViewController(searchResultVC, animated: true)
    }
    
}
