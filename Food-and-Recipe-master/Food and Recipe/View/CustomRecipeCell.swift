//
//  CustomRecipeCell.swift
//  Food and Recipe
//
//  Created by Ajay Choudhary on 05/10/19.
//  Copyright © 2019 Ajay Choudhary. All rights reserved.
//

import UIKit

class CustomRecipeCell: UITableViewCell {
    
    let recipeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let recipeTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont(name: "Marker Felt", size: 20)
        return label
    }()
    
    let durationTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 11)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    private func setupView() {
        setupRecipeImageView()
        setupRecipeTitle()
        setupDurationTitle()
    }
    
    private func setupRecipeImageView() {
        addSubview(recipeImageView)
        
        recipeImageView.translatesAutoresizingMaskIntoConstraints = false
        recipeImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5).isActive = true
        recipeImageView.heightAnchor.constraint(equalToConstant: 109).isActive = true
        recipeImageView.widthAnchor.constraint(equalToConstant: 109).isActive = true
        recipeImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    private func setupRecipeTitle() {
        addSubview(recipeTitle)
        
        recipeTitle.translatesAutoresizingMaskIntoConstraints = false
        recipeTitle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        recipeTitle.leadingAnchor.constraint(equalTo: recipeImageView.trailingAnchor, constant: 8).isActive = true
        recipeTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5).isActive = true
        recipeTitle.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    private func setupDurationTitle() {
        addSubview(durationTitle)
        
        durationTitle.translatesAutoresizingMaskIntoConstraints = false
        durationTitle.leadingAnchor.constraint(equalTo: recipeImageView.trailingAnchor, constant: 5).isActive = true
        durationTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5).isActive = true
        durationTitle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        durationTitle.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
