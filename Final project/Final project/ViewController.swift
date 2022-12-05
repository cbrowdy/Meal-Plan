//
//  ViewController.swift
//  Final project
//
//  Created by Omer Moav on 13/11/2022.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate{
    
    let apiKey = "1b4fa62e8edf48c3b6f2fcb456aded47"
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
    var extendedInfoArr: [Dictionary<AnyHashable, Any>] = []
    var currentRecipesData: [Recipe] = []
    var theImageCache: [UIImage] = []
    var indexesToDisplay: [Int] = []
    var extendedInfoBackUp: [Dictionary<AnyHashable, Any>] = []
    var currentRecipesBackUp: [Recipe] = []
    var theImageCacheBackUp: [UIImage] = []

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
        extendedInfoArr = []
        currentRecipesData = []
        let recipeURL = URL(string:
                                "https://api.spoonacular.com/recipes/complexSearch?apiKey=\(apiKey)&query=\(keyword.replacingOccurrences(of: " ", with: "+") )")
        let binaryAPIResultsData = try! Data(contentsOf: recipeURL!)
        currentAPIResultsData = try! JSONDecoder().decode(APIResults.self, from: binaryAPIResultsData)
        currentRecipesData = currentAPIResultsData!.results
        currentRecipesBackUp = currentRecipesData
        var i = 0
        while i < currentRecipesData.count{
            let moreInfo = URL(string: "https://api.spoonacular.com/recipes/\(currentRecipesData[i].id!)/information?apiKey=\(apiKey)&includeNutrition=false")
            let binaryExtendedResults = try! Data(contentsOf: moreInfo!)
            if let currentExtndedInfo = try! JSONSerialization.jsonObject(with: binaryExtendedResults, options: .fragmentsAllowed) as? [AnyHashable: Any]{
                extendedInfoArr.append(currentExtndedInfo)
            }
            i+=1
        }
        extendedInfoBackUp = extendedInfoArr
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
        theImageCacheBackUp = theImageCache
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let index = indexPath.item
        for subview in cell.subviews{
            subview.removeFromSuperview()
        }
        //adding the image to the cell
        let imgSubview = addImage(index: index)
        cell.addSubview(imgSubview)
        
        
        //adding the title to the cell
        let recipeTitleSubView = UILabel(frame: CGRect(x: 0, y: 0, width: cell.bounds.width, height: 30))
        recipeTitleSubView.backgroundColor = UIColor.brown.withAlphaComponent(0.5)
        recipeTitleSubView.text = currentRecipesData[index].title
        recipeTitleSubView.textColor = UIColor.white
        recipeTitleSubView.textAlignment = .center
        recipeTitleSubView.layer.cornerRadius = 10
        recipeTitleSubView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        recipeTitleSubView.clipsToBounds = true
        cell.addSubview(recipeTitleSubView)
        
        //creating subviews for tags
        let firstView = UILabel(frame: CGRect(x: 0, y: 280, width: 80, height: 20))
        let secondView = UILabel(frame: CGRect(x: cell.bounds.midX-40, y: 280, width: 80, height: 20))
        let thirdView = UILabel(frame: CGRect(x: cell.bounds.maxX-80, y: 280, width: 80, height: 20))
        let fourthView = UILabel(frame: CGRect(x: 0, y: 320, width: 80, height: 20))
        let fifthView = UILabel(frame: CGRect(x: cell.bounds.midX-40 , y: 320, width: 80, height: 20))
        let sixthView = UILabel(frame: CGRect(x: cell.bounds.maxX-80 , y: 320, width: 80, height: 20))
        
        let labels = [firstView, secondView, thirdView, fourthView, fifthView, sixthView]
        addText(labels: labels, index: index)
        for i in 0...5 {
            labels[i].backgroundColor=UIColor.brown.withAlphaComponent(0.5)
            labels[i].font = UIFont.italicSystemFont(ofSize: 13)
            labels[i].sizeToFit()
            let prevFrame = labels[i].frame
            if i%3 == 1{
                labels[i].frame = CGRect(x: cell.bounds.midX - prevFrame.width/2, y: prevFrame.minY, width: prevFrame.width+10, height: prevFrame.height)
            }else{
                labels[i].frame = CGRect(x: prevFrame.minX, y: prevFrame.minY, width: prevFrame.width+10, height: prevFrame.height)
            }
            labels[i].layer.masksToBounds = true
            labels[i].layer.cornerRadius = 5
            labels[i].textAlignment = .center
            cell.addSubview(labels[i])
        }
        
        return cell
    }
    
    
    //adding tags for the labels
    func addText(labels: [UILabel], index: Int){
        var i: Int = 0
        var couisinesArr = extendedInfoArr[index]["cuisines"] as? [String]
        while couisinesArr?.isEmpty == false{
            labels[i].text = couisinesArr?[0]
            couisinesArr?.remove(at: 0)
            i+=1
            if i == 5 {return}
        }
        if extendedInfoArr[index]["vegetarian"]! as! Bool == true{
            labels[i].text = "Vegetarian"
            i+=1
            if i == 5 {return}
        }
        if extendedInfoArr[index]["vegan"]! as! Bool == true{
            labels[i].text = "Vegan"
            i+=1
            if i == 5 {return}
        }
        if extendedInfoArr[index]["glutenFree"]! as! Bool == true{
            labels[i].text = "Gluten Free"
            i+=1
            if i == 5 {return}
        }
        if extendedInfoArr[index]["dairyFree"]! as! Bool == true{
            labels[i].text = "Dairy Free"
            i+=1
            if i == 5 {return}
        }
        if extendedInfoArr[index]["veryHealthy"]! as! Bool == true{
            labels[i].text = "Very Healthy"
            i+=1
            if i == 5 {return}
        }
        if extendedInfoArr[index]["cheap"]! as! Bool == true{
            labels[i].text = "Cheap"
            i+=1
            if i == 5 {return}
        }
        if extendedInfoArr[index]["veryPopular"]! as! Bool == true{
            labels[i].text = "Very Popular"
            i+=1
            if i == 5 {return}
        }
        if extendedInfoArr[index]["sustainable"]! as! Bool == true{
            labels[i].text = "Sustainable"
            i+=1
            if i == 5 {return}
        }
        if extendedInfoArr[index]["lowFodmap"]! as! Bool == true{
            labels[i].text = "Low Fodmap"
            i+=1
            if i == 5 {return}
        }
    }
    
    
    func addImage(index: Int) -> UIImageView{
        let imageFrame = CGRect(x: 0, y: 30, width: 312, height: 231)
        let recipeImageSubView = UIImageView(frame: imageFrame)
        recipeImageSubView.image = theImageCache[index]
        recipeImageSubView.layer.cornerRadius = 10
        recipeImageSubView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        recipeImageSubView.clipsToBounds = true
        return recipeImageSubView
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        let detailedRecipeVC = DetailedRecipeViewController()
        detailedRecipeVC.recipeID = currentRecipesData[indexPath.item].id
        detailedRecipeVC.recipeTitle = currentRecipesData[indexPath.item].title
        detailedRecipeVC.recipeImage = theImageCache[indexPath.item]
        navigationController?.pushViewController(detailedRecipeVC, animated: true)
    }
    
    @IBOutlet weak var cheapOutlet: UIButton!
    @IBAction func cheap(_ sender: Any) {
        reloadAfterFilter(tag: "cheap")
        cheapOutlet.tintColor = UIColor.black
    }
    
    @IBOutlet weak var veganOutlet: UIButton!
    @IBAction func vegan(_ sender: Any) {
        reloadAfterFilter(tag: "vegan")
        veganOutlet.tintColor = UIColor.black
    }
    
    @IBOutlet weak var vegetarianOutlet: UIButton!
    @IBAction func vegetarian(_ sender: Any) {
        reloadAfterFilter(tag: "vegetarian")
        vegetarianOutlet.tintColor = UIColor.black
    }
    
    @IBOutlet weak var healthyOutlet: UIButton!
    @IBAction func healthy(_ sender: Any) {
        reloadAfterFilter(tag: "veryHealthy")
        healthyOutlet.tintColor = UIColor.black
    }
    
    @IBOutlet weak var glutenFreeOutlet: UIButton!
    @IBAction func glutenFree(_ sender: Any) {
        reloadAfterFilter(tag: "glutenFree")
        glutenFreeOutlet.tintColor = UIColor.black
    }
    
    @IBOutlet weak var dairyFreeOutlet: UIButton!
    @IBAction func dairyFree(_ sender: Any) {
        reloadAfterFilter(tag: "dairyFree")
        dairyFreeOutlet.tintColor = UIColor.black
    }
    
    @IBAction func clearFilters(_ sender: Any) {
        currentRecipesData = currentRecipesBackUp
        theImageCache = theImageCacheBackUp
        extendedInfoArr = extendedInfoBackUp
        cheapOutlet.tintColor = UIColor.systemBlue
        veganOutlet.tintColor = UIColor.systemBlue
        vegetarianOutlet.tintColor = UIColor.systemBlue
        healthyOutlet.tintColor = UIColor.systemBlue
        glutenFreeOutlet.tintColor = UIColor.systemBlue
        dairyFreeOutlet.tintColor = UIColor.systemBlue
        recipesCollectionView.reloadData()
    }
    
    func reloadAfterFilter(tag: String){
        var i = 0
        while i < currentRecipesData.count{
            if extendedInfoArr[i]["\(tag)"]! as! Bool == false{
                currentRecipesData.remove(at: i)
                theImageCache.remove(at: i)
                extendedInfoArr.remove(at: i)
            }
            else{i+=1}
        }
        recipesCollectionView.reloadData()
    }
    
    
}

