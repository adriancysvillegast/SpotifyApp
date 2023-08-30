//
//  SettingsViewController.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 22/7/23.
//

import UIKit

class SettingsViewController: UIViewController {

    // MARK: - Properties
    private lazy var aTableView: UITableView = {
        let aTableView = UITableView(frame: .zero, style: .grouped)
        aTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        aTableView.dataSource = self
        aTableView.delegate = self
        return aTableView
    }()
    
    private var sections = [Section]()
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureModels()
        title = "Settings"
        view.backgroundColor = .systemBackground
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        aTableView.frame = view.bounds
    }
    
    // MARK: - SetupView
    
    private func setupView() {
        view.addSubview(aTableView)
    }

    
    // MARK: - Methods
    private func configureModels() {
        sections.append(Section(title: "Profile",
                                options: [Option(title: "View Your Profile", handler: { [weak self] in
            DispatchQueue.main.async {
                self?.viewProfile()
            }
            
        })]))
        sections.append(Section(title: "Account",
                                options: [Option(title: "Sign Out", handler: { [weak self] in
            DispatchQueue.main.async {
                self?.signOutTapped()
            }
            
        })]))
    }

    private func viewProfile() {
        let vc = ProfileViewController()
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func signOutTapped() {
        let alert = UIAlertController(title: "Sign Out", message: "Do you want to sign out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            
            AuthManager.shared.signOut { [weak self] success in
                if success {
                    DispatchQueue.main.async {
                        let controller = WelcomeViewController()
                        let navVC = UINavigationController(rootViewController: controller)
                        navVC.navigationBar.prefersLargeTitles = true
                        navVC.viewControllers.first?.navigationItem.largeTitleDisplayMode = .always
                        navVC.modalPresentationStyle = .fullScreen
                        self?.present(navVC, animated: true, completion: {
                            self?.navigationController?.popToRootViewController(animated: false)
                        })
                    }
                }
            }
            
        }))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = sections[indexPath.section].options[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = sections[indexPath.section].options[indexPath.row]
        model.handler()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let model = sections[section]
        return model.title
    }
    
}
