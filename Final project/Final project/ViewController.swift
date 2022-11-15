//
//  ViewController.swift
//  Final project
//
//  Created by Omer Moav on 13/11/2022.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate{
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var recipesCollectionView: UICollectionView!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    struct APIResults:Decodable {
        let results: [Recipe]
    }
    
    struct Recipe:Decodable {
        let id: Int!
        let title: String
        let image: String?
        let imageType: String?
    }

    
    var currentAPIResultsData: APIResults?
    var currentRecipesData: [Recipe] = []
    var theImageCache: [UIImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadingSpinner.isHidden = true
        searchBar.delegate = self
        setupRecipesCollectionView()
    }
    
    
    func setupRecipesCollectionView(){
        recipesCollectionView.dataSource = self
        recipesCollectionView.delegate = self
        recipesCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    func fetchDataForRecipesCollectionView(keyword: String) {
        let recipeURL = URL(string:
                                "https://api.spoonacular.com/recipes/complexSearch?apiKey=804dbeff69ea4e25a1051ae9714d9e63&query=\(keyword.replacingOccurrences(of: " ", with: "+") )")
        let binaryAPIResultsData = try! Data(contentsOf: recipeURL!)
        currentAPIResultsData = try! JSONDecoder().decode(APIResults.self, from: binaryAPIResultsData)
        currentRecipesData = currentAPIResultsData!.results
    }
    
    func cacheImages(){
        for recipe in currentRecipesData{
            let image: UIImage?
            if recipe.image != nil {
                let stringImageUrl = "https://spoonacular.com/recipeImages/\(recipe.id!)-312x231.jpg"
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        loadingSpinner.isHidden = false
        loadingSpinner.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchDataForRecipesCollectionView(keyword: searchBar.text!)
            self.theImageCache = []
            self.cacheImages()
            DispatchQueue.main.async {
                self.loadingSpinner.stopAnimating()
                self.loadingSpinner.isHidden = true
                self.recipesCollectionView.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentRecipesData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
//        let recipeImageSubView = UIImageView(frame: cell.bounds)
//        recipeImageSubView.image = theImageCache[indexPath.item]
//        let recipeTitleSubView = UILabel(frame: CGRect(x: 0, y: 0.75*cell.bounds.height, width: cell.bounds.width, height: 0.25*cell.bounds.height))
//        recipeTitleSubView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
//        recipeTitleSubView.text = currentRecipesData[indexPath.item].title
//        recipeTitleSubView.textColor = UIColor.white
//        recipeTitleSubView.textAlignment = .center
//        cell.addSubview(recipeImageSubView)
//        cell.addSubview(recipeTitleSubView)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        for subview in cell.subviews{
            subview.removeFromSuperview()
        }
        //adding the image to the cell
        let imageFrame = CGRect(x: 0, y: 30, width: 312, height: 231)
        let recipeImageSubView = UIImageView(frame: imageFrame)
        recipeImageSubView.image = theImageCache[indexPath.item]
        recipeImageSubView.layer.cornerRadius = 10
        recipeImageSubView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        recipeImageSubView.clipsToBounds = true
        cell.addSubview(recipeImageSubView)
        //adding the title to the cell
        let recipeTitleSubView = UILabel(frame: CGRect(x: 0, y: 0, width: cell.bounds.width, height: 30))
        recipeTitleSubView.backgroundColor = UIColor.brown.withAlphaComponent(0.5)
        recipeTitleSubView.text = currentRecipesData[indexPath.item].title
        recipeTitleSubView.textColor = UIColor.white
        recipeTitleSubView.textAlignment = .center
        recipeTitleSubView.layer.cornerRadius = 10
        recipeTitleSubView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        recipeTitleSubView.clipsToBounds = true
        cell.addSubview(recipeTitleSubView)
        //adding cuisine to the cell
        let cuisineSubView = UILabel(frame: CGRect(x: 0, y: 280, width: 80, height: 20))
        cuisineSubView.backgroundColor=UIColor.brown.withAlphaComponent(0.5)
        cuisineSubView.text = " italian "
        cuisineSubView.textColor = UIColor.white
        cuisineSubView.font = UIFont.italicSystemFont(ofSize: 16)
        recipeImageSubView.layer.cornerRadius = 10
        recipeImageSubView.clipsToBounds = true
        cuisineSubView.sizeToFit()
        cell.addSubview(cuisineSubView)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        let detailedRecipeVC = DetailedRecipeViewController()
        detailedRecipeVC.recipeID = currentRecipesData[indexPath.item].id
        detailedRecipeVC.recipeTitle = currentRecipesData[indexPath.item].title
        detailedRecipeVC.recipeImage = theImageCache[indexPath.item]
        navigationController?.pushViewController(detailedRecipeVC, animated: true)
    }
}

