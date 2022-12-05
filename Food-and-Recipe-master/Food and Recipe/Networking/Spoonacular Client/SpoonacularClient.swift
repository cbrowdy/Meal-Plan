//
//  SpoonacularClient.swift
//  Food and Recipe
//
//  Created by Ajay Choudhary on 26/09/19.
//  Copyright © 2019 Ajay Choudhary. All rights reserved.
//

import UIKit

class SpoonacularClient {
    static let apiKey = "a67a5241c34f45429f75c2d8a1858a67"
    static let host = "api.spoonacular.com"
    static let scheme = "https"
    
    static var randomRecipeURL: URL {
        var components = URLComponents()
        components.host = host
        components.path = "/recipes/random"
        components.scheme = scheme
        
        components.queryItems = [URLQueryItem]()
        components.queryItems?.append(URLQueryItem(name: "apiKey", value: SpoonacularClient.apiKey))
        components.queryItems?.append(URLQueryItem(name: "number", value: "8"))
        
        return components.url!
    }
    
    class func getRandomRecipe(completion: @escaping ([Recipe], Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: SpoonacularClient.randomRecipeURL) { (data, response, error) in
            if error != nil {
                completion([], error)
                return
            }
            guard let data = data else {
                completion([], error)
                return
            }
            do {
                let responseObject = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [AnyHashable: Any]
                if let recipeArray = responseObject?["recipes"] as? [[String: Any]] {
                    let recipes = createRecipes(recipeArray: recipeArray)
                    completion(recipes, nil)
                }
                else {
                    completion([], error)
                }
            } catch {
                completion([], error)
            }
        }
        task.resume()
        
    }
    
    class func downloadRecipeImage(imageURL: String, completion: @escaping (UIImage?, Bool) -> Void) {
        if let url = URL(string: imageURL) {
            DispatchQueue.global(qos: .userInitiated).async {
                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                    guard let data = data else {
                        completion(nil, false)
                        return
                    }
                    DispatchQueue.main.async{
                        completion(UIImage(data: data), true)
                    }
                }
                task.resume()
            }
        }
    }
    
    private class func createRecipes(recipeArray: [[String: Any]]) -> [Recipe] {
        var recipes = [Recipe]()
        for recipeInfo in recipeArray {
            let recipe = configureRecipe(recipeInfo: recipeInfo)
            recipes.append(recipe)
        }
        return recipes
    }
    
    private class func configureRecipe(recipeInfo: [String: Any]) -> Recipe{
        var recipe = Recipe()
        
        if let title = recipeInfo["title"] as? String {
            recipe.title = title
        }
        
        if let servings = recipeInfo["servings"] as? Int {
            recipe.servings = servings
        }
        
        if let imageURL = recipeInfo["image"] as? String {
            recipe.imageURL = imageURL
        }
        
        if let sourceURL = recipeInfo["sourceUrl"] as? String {
            recipe.sourceURL = sourceURL
        }

        if let ingredientArray = recipeInfo["extendedIngredients"] as? [[String: Any]] {
            if ingredientArray.count == 0 {
                recipe.ingredients = []
            } else {
                var ingredients = [String]()
                for ingredient in ingredientArray {
                    if let ingredient = ingredient["originalString"] as? String {
                        ingredients.append(ingredient)
                    }
                }
                recipe.ingredients = ingredients
            }
        } else {
            recipe.ingredients = []
        }
        
        if let timeRequired = recipeInfo["readyInMinutes"] as? Int {
            recipe.timeRequired = timeRequired
        }
        
        if let instructions = recipeInfo["analyzedInstructions"] as? [[String : Any]]  {
            if instructions.count == 0 {
                recipe.instructions = []
            } else {
                var instructionsArray = [String]()
                for instructionSteps in instructions {
                    if let instructionSteps = instructionSteps["steps"] as? [[String : Any]] {
                        for step in instructionSteps {
                            if let instructionStep = step["step"] as? String {
                                instructionsArray.append(instructionStep)
                            }
                        }
                    }
                }
                recipe.instructions = instructionsArray
            }
        } else {
            recipe.instructions = []
        }
        return recipe
    }
    
    class func getUserSearchedRecipe(id: Int, completion: @escaping (Recipe?, Bool, Error?) -> Void){
        var url: URL {
            var components = URLComponents()
            components.host = host
            components.path = "/recipes/\(id)/information"
            components.scheme = scheme
            
            components.queryItems = [URLQueryItem]()
            components.queryItems?.append(URLQueryItem(name: "apiKey", value: SpoonacularClient.apiKey))
            
            return components.url!
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                completion(nil, false, error)
                return
            }
            guard let data = data else {
                completion(nil, false, error)
                return
            }
            do {
                if let responseObject = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any] {
                    let recipe = configureRecipe(recipeInfo: responseObject)
                    completion(recipe, true, nil)
                }
            } catch {
                completion(nil, false, error)
            }
            
        }
        task.resume()
    }
    
    
    class func autoCompleteRecipeSearch(query: String, completion: @escaping ([AutoCompleteSearchResponse], Error?) -> Void) -> URLSessionTask {
        var searchURL: URL {
            var components = URLComponents()
            components.host = host
            components.path = "/recipes/autocomplete"
            components.scheme = scheme
            
            components.queryItems = [URLQueryItem]()
            components.queryItems?.append(URLQueryItem(name: "apiKey", value: SpoonacularClient.apiKey))
            components.queryItems?.append(URLQueryItem(name: "number", value: "8"))
            components.queryItems?.append(URLQueryItem(name: "query", value: query))
            
            return components.url!
        }
        let task = URLSession.shared.dataTask(with: searchURL) { (data, response, error) in
            guard let data = data else {
                completion([], error)
                return
            }
            do {
                let responseObject = try JSONDecoder().decode([AutoCompleteSearchResponse].self, from: data)
                completion(responseObject, nil)
            } catch {
                completion([], error)
            }
        }
        return task
    }
    
    class func search(query: String, completion: @escaping ([SearchedRecipes], Bool, Error?) -> Void) {
        var searchURL: URL {
            var components = URLComponents()
            components.host = host
            components.path = "/recipes/complexSearch"
            components.scheme = scheme
            
            components.queryItems = [URLQueryItem]()
            components.queryItems?.append(URLQueryItem(name: "apiKey", value: SpoonacularClient.apiKey))
            components.queryItems?.append(URLQueryItem(name: "number", value: "8"))
            components.queryItems?.append(URLQueryItem(name: "query", value: query))
            
            return components.url!
        }
        
        let task = URLSession.shared.dataTask(with: searchURL) { (data, response, error) in
            guard let data = data else {
                completion([], false, error)
                return
            }
            do {
                let responseObject = try JSONDecoder().decode(SearchResultResponse.self, from: data)
                completion(responseObject.results, true, nil)
            } catch {
                completion([], false, error)
            }
        }
        task.resume()
    }
    
    
}


