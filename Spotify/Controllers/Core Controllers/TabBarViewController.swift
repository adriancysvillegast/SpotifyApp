//
//  TabBarViewController.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 22/7/23.
//

import UIKit

class TabBarViewController: UITabBarController {
    // MARK: - Properties
    
    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.hidesBackButton = true
        setupVCs()
    }
    
    // MARK: - Methods
    fileprivate func createNavController(for rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {

        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        navController.navigationBar.tintColor = .label
        navController.navigationBar.prefersLargeTitles = true
        rootViewController.navigationItem.title = title
        return navController
    }

    func setupVCs() {
            viewControllers = [
                createNavController(for: HomeViewController(), title: NSLocalizedString("Browse", comment: ""), image: UIImage(systemName: "house")!),
                createNavController(for: SearchViewController(), title: NSLocalizedString("Search", comment: ""), image: UIImage(systemName: "magnifyingglass")!),
                createNavController(for: LibraryViewController(), title: "Library", image: UIImage(systemName: "square.stack")!)
            ]
        }

}
