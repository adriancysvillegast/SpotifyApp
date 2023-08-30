//
//  LibraryAlbumsViewController.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 27/8/23.
//

import UIKit

class LibraryAlbumsViewController: UIViewController {

    // MARK: - Properties
    private var albums = [AlbumResponse]()
    
    private lazy var aTableView: UITableView = {
        let aTableView = UITableView(frame: .zero, style: .grouped)
        aTableView.register(SearchResultSubtitleTableViewCell.self, forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier)
        aTableView.isHidden = true
        aTableView.delegate = self
        aTableView.dataSource = self
        return aTableView
    }()
    
    private lazy var noAlbumsView: ActionLabelView = {
        let view = ActionLabelView()
        view.delegate = self
        return ActionLabelView()
    }()
    
    private var observer: NSObjectProtocol?
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        noAlbumsView.delegate = self
        setupView()
        setUpNotAlbums()
        fetchData()
        observer = NotificationCenter.default.addObserver(
            forName: .albumSavedNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                self?.fetchData()
        })
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noAlbumsView.frame = CGRect(x: (view.width-150) / 2, y: (view.height - 150) / 2, width: 160, height: 160)
        aTableView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
    }

    // MARK: - setupView
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(aTableView)
    }
    
    private func setUpNotAlbums() {
        view.addSubview(noAlbumsView)
        noAlbumsView.configure(with: ActionLabelViewViewModel(text: "You have not any albums yet",
                                                                 actionTitle: "Browse")
        )
    }
    // MARK: - Methods

    
    private func fetchData() {
        albums.removeAll()
        APIManager.shared.getCurrentUserAlbums { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let albums):
                    self?.albums = albums
                    self?.updateUI()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func updateUI() {
        if albums.isEmpty {
            noAlbumsView.isHidden = false
            aTableView.isHidden = true
        }else{
            noAlbumsView.isHidden = true
            aTableView.reloadData()
            aTableView.isHidden = false
            
        }
    }
    
    @objc func didTapClose() {
        dismiss(animated: true)
    }
    
}

// MARK: - ActionLabelViewDelegate

extension LibraryAlbumsViewController: ActionLabelViewDelegate {
    func actionLabeldidTapButton(_ actionView: ActionLabelView) {
        tabBarController?.selectedIndex = 0
    }

}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension LibraryAlbumsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else {
            return UITableViewCell()
        }
        let album = albums[indexPath.row]
        cell.configure(
            with: SearchResultSubtitleTableViewCellViewModel(
                title: album.name,
                subtitle: album.artists.first?.name ?? "-" ,
                imageURL: URL(string: album.images.first?.url ?? "" ))
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        HapticsManager.shared.vibrateForSelection()
        let album = albums[indexPath.row]
        
        let vc = AlbumViewController(album: album)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
