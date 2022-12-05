//
//  searchResultResponse.swift
//  Food and Recipe
//
//  Created by Ajay Choudhary on 03/10/19.
//  Copyright © 2019 Ajay Choudhary. All rights reserved.
//

import Foundation

struct SearchResultResponse: Codable {
    let offset: Int
    let number: Int
    let totalResults: Int
    let results: [SearchedRecipes]
}
