//
//  Extension + UIViewController.swift
//  Food and Recipe
//
//  Created by Ajay Choudhary on 04/10/19.
//  Copyright © 2019 Ajay Choudhary. All rights reserved.
//

import UIKit

extension UIViewController {
    func presentAlert(title: String, message: String) {
         let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
         let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
         alertVC.addAction(alertAction)
         present(alertVC, animated: true)
     }
}
