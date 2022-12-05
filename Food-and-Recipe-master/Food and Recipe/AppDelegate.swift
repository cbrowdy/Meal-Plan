//
//  AppDelegate.swift
//  Food and Recipe
//
//  Created by Ajay Choudhary on 26/09/19.
//  Copyright © 2019 Ajay Choudhary. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let homeVC = HomeViewController()
        let homeNC = UINavigationController(rootViewController: homeVC)
        homeNC.tabBarItem.title = "Home"
        homeNC.tabBarItem.image = UIImage(named: "home")
        
        let searchVC = SearchViewController()
        let searchNC = UINavigationController(rootViewController: searchVC)
        searchNC.tabBarItem.title = "Search"
        searchNC.tabBarItem.image = UIImage(named: "search")
        
        let savedVC = SavedViewController()
        let savedNC = UINavigationController(rootViewController: savedVC)
        savedNC.tabBarItem.title = "Saved"
        savedNC.tabBarItem.image = UIImage(named: "save")
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [homeNC, searchNC, savedNC]
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.saveContext()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Food_and_Recipe")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

