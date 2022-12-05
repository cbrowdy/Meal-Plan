//
//  CustomHeaderCell.swift
//  Food and Recipe
//
//  Created by Ajay Choudhary on 02/10/19.
//  Copyright © 2019 Ajay Choudhary. All rights reserved.
//

import UIKit

class CustomHeaderCell: UIView {
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = ContentMode.scaleAspectFill
        return imageView
    }()
    
    let recipeTitleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        label.textColor = .black
        label.numberOfLines = 0
        label.minimumScaleFactor = 0.5
        label.font = UIFont(name: "Marker Felt", size: 28)
        return label
    }()
    
    let timingLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textColor = .black
        label.font = UIFont(name: "Verdana", size: 16)
        return label
    }()
    
    let ingredientsLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textColor = .black
        label.font = UIFont(name: "Verdana-Bold", size: 18)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(imageView)
        addSubview(recipeTitleLabel)
        addSubview(timingLabel)
        addSubview(ingredientsLabel)
        
        setupView()
    }
    
    private func setupView() {
        setupImageView()
        setupRecipeTitleLabel()
        setupIngredientsLabel()
        setupTimingLabel()
    }
    
    private func setupImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    private func setupRecipeTitleLabel() {
        recipeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        recipeTitleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        recipeTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        recipeTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    private func setupIngredientsLabel() {
        ingredientsLabel.translatesAutoresizingMaskIntoConstraints = false
        ingredientsLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        ingredientsLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        ingredientsLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        ingredientsLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    private func setupTimingLabel() {
        timingLabel.translatesAutoresizingMaskIntoConstraints = false
        timingLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        timingLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        timingLabel.bottomAnchor.constraint(equalTo: ingredientsLabel.topAnchor).isActive = true
        timingLabel.heightAnchor.constraint(equalToConstant: 45).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) as not been implemented")
    }
    
}
