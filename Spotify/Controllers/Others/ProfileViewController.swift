//
//  ProfileViewController.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 22/7/23.
//
import SDWebImage
import UIKit

class ProfileViewController: UIViewController {

    // MARK: - Properties
    
    private lazy var aTableView: UITableView = {
        let aTableView = UITableView(frame: .zero, style: .grouped)
        aTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        aTableView.isHidden = true
        aTableView.dataSource = self
        aTableView.delegate = self
        return aTableView
    }()
    
    private var models = [String]()
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        view.backgroundColor = .systemBackground
        
        fetchProfile()
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        aTableView.frame = view.bounds
    }
    
    // MARK: - Methods
    
    private func setupView() {
        view.addSubview(aTableView)
    }
    
    private func fetchProfile() {
        APIManager.shared.getCurrentUserProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self?.updateView(with: model)
                    break
                case .failure(let error):
                    self?.failedToGetProfile()
                    print(error.localizedDescription)
                }
            }
            
        }
    }
    
    private func updateView(with model: UserProfile) {
        aTableView.isHidden = false
        //configure Cell
        models.append("Full name: \(model.displayName)")
        models.append("Email Address: \(model.email)")
        models.append("User ID: \(model.id)")
        models.append("Plan: \(model.product)")
        createTableHeader(with: model.images.first?.url)
        aTableView.reloadData()
    }
    
    private func createTableHeader(with string: String?) {
        guard let urlString = string, let url = URL(string: urlString) else {
            return
        }
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.width/1.5))
        let imageSize: CGFloat = headerView.height/2
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
        headerView.addSubview(imageView)
        imageView.center = headerView.center
        imageView.contentMode = .scaleAspectFill
        imageView.sd_setImage(with: url)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageSize/2
        
        aTableView.tableHeaderView = headerView
        
    }
    
    private func failedToGetProfile() {
        let label = UILabel(frame: .zero)
        label.text = "Failed to load profile"
        label.sizeToFit()
        label.textColor = .secondaryLabel
        view.addSubview(label)
        label.center = view.center
    }
}
// MARK: - UITableViewDelegate, UITableViewDataSource

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = models[indexPath.row]
        return cell
    }
    
    
}
