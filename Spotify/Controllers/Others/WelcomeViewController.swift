//
//  WelcomeViewController.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 22/7/23.
//

import UIKit

class WelcomeViewController: UIViewController {

    // MARK: - Properties
    private lazy var signInButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("Sign In with Spotify", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 9
        return button
    }()
    
    private lazy var aImageBackground: UIImageView = {
        let aImageView = UIImageView()
        aImageView.contentMode = .scaleAspectFill
        aImageView.image = UIImage(named: "background-Image")
        return aImageView
    }()
    
    private lazy var aOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.7
        return view
    }()
    
    private lazy var aLogo: UIImageView = {
        let aImageView = UIImageView()
        aImageView.contentMode = .scaleAspectFill
        aImageView.image = UIImage(named: "logo")
        return aImageView
    }()
    
    private lazy var aLabel: UILabel = {
        let aLabel = UILabel()
        aLabel.numberOfLines = 0
        aLabel.textColor = .white
        aLabel.textAlignment = .center
        aLabel.text = "Listen to Millions\nof Songs on\n the go"
        aLabel.font = .systemFont(ofSize: 30, weight: .semibold)
        return aLabel
    }()
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Spotify"
        view.backgroundColor = .systemGreen
        setupView()
        addTargets()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        aImageBackground.frame = view.bounds
        aOverlayView.frame = view.bounds
        aLogo.frame = CGRect(x: (view.width - 100)/2, y: (view.height-200)/2 ,width: 100, height: 100)
        signInButton.frame = CGRect(x: 20,
                                    y: view.height-50-view.safeAreaInsets.bottom,
                                    width: view.width-40,
                                    height: 50
        )
        aLabel.frame = CGRect(x: 30, y: aLogo.botton+20, width: view.width-60, height: 180 )
    }
    
    // MARK: - setupView
    private func setupView() {
        view.addSubview(aImageBackground)
        view.addSubview(aOverlayView)
        view.addSubview(aLogo)
        view.addSubview(aLabel)
        view.addSubview(signInButton)
    }

    // MARK: - Methods
    
    private func addTargets() {
        signInButton.addTarget(self, action: #selector(goToAuth), for: .touchUpInside)
    }
    
    @objc func goToAuth() {
        let vc = AuthViewController()
        vc.compleationHandler = { [weak self] success in
            DispatchQueue.main.async {
                self?.handelSignIn(success: success)
            }
        }
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func handelSignIn(success: Bool) {
        guard success else {
            let alert = UIAlertController(title: "Oops", message: "Somethings went wrong when sign in.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        
        let mainTabBar = TabBarViewController()
        mainTabBar.modalPresentationStyle = .fullScreen
        present(mainTabBar, animated: true)
    }
}
