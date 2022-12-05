//
//  searchRecipeObject.swift
//  Food and Recipe
//
//  Created by Ajay Choudhary on 03/10/19.
//  Copyright © 2019 Ajay Choudhary. All rights reserved.
//

import Foundation

struct SearchedRecipes: Codable {
    let id: Int
    let title: String
    let image: String
    let imageType: String
}
