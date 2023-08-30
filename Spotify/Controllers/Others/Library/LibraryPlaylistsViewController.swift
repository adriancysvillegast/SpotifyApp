//
//  LibraryPlaylistsViewController.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 27/8/23.
//

import UIKit

class LibraryPlaylistsViewController: UIViewController {

    // MARK: - Properties
    private var playlists = [Playlist]()
    
    public var selectionHandler: ((Playlist) -> Void)?
    
    private lazy var aTableView: UITableView = {
        let aTableView = UITableView(frame: .zero, style: .grouped)
        aTableView.register(SearchResultSubtitleTableViewCell.self, forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier)
        aTableView.isHidden = true
        aTableView.delegate = self
        aTableView.dataSource = self
        return aTableView
    }()
    
    private lazy var noPlaylistLabel: ActionLabelView = {
        let view = ActionLabelView()
        view.delegate = self
        return ActionLabelView()
    }()
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        noPlaylistLabel.delegate = self
        setupView()
        setUpNotPlaylist()
        fetchData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noPlaylistLabel.frame = CGRect(x: 0, y: 0, width: 160, height: 160)
        noPlaylistLabel.center =  view.center
        aTableView.frame = view.bounds
        
    }

    // MARK: - setupView
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(aTableView)
        
        if selectionHandler != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        }
    }
    
    private func setUpNotPlaylist() {
        view.addSubview(noPlaylistLabel)
        noPlaylistLabel.configure(with: ActionLabelViewViewModel(text: "You don't have any playlists yet",
                                                                 actionTitle: "Create")
        )
    }
    // MARK: - Methods

    
    private func fetchData() {
        APIManager.shared.getCurrentUserPlaylists { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let playlist):
                    self?.playlists = playlist
                    self?.updateUI()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func updateUI() {
        if playlists.isEmpty {
            noPlaylistLabel.isHidden = false
            aTableView.isHidden = true
        }else{
            noPlaylistLabel.isHidden = true
            aTableView.reloadData()
            aTableView.isHidden = false
            
        }
    }
    
    func showAlertToCreatePlaylist() {
        let alert = UIAlertController(title: "New Playlist", message: "Enter playlist name", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Playlist Name"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { _ in
            guard let field = alert.textFields?.first,
                  let text = field.text,
                  !text.trimmingCharacters(in: .whitespaces).isEmpty else {
                return
            }
            
            APIManager.shared.createPlaylist(with: text) { [weak self] success in
                    if success {
                        HapticsManager.shared.vibrate(for: .success)
                        self?.fetchData()
                    } else {
                        HapticsManager.shared.vibrate(for: .error)
                        print("error creating playlist")
                    }
            }
        }))
        present(alert, animated: true)

    }
    
    @objc func didTapClose() {
        dismiss(animated: true)
    }
    
}

// MARK: - ActionLabelViewDelegate

extension LibraryPlaylistsViewController: ActionLabelViewDelegate {
    func actionLabeldidTapButton(_ actionView: ActionLabelView) {
        showAlertToCreatePlaylist()
    }

}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension LibraryPlaylistsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else {
            return UITableViewCell()
        }
        let playlist = playlists[indexPath.row]
        cell.configure(
            with: SearchResultSubtitleTableViewCellViewModel(
                title: playlist.name,
                subtitle: playlist.owner.displayName,
                imageURL: URL(string: playlist.images.first?.url ?? "" ))
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()
        let playlist = playlists[indexPath.row]
        
        //to get te playlist
        guard selectionHandler == nil else {
            selectionHandler?(playlist)
            dismiss(animated: true, completion: nil)
            return
        }
        
        let vc = PlaylistViewController(playlist: playlist)
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.isOwner = true
        navigationController?.pushViewController(vc, animated: true)
    }
}
