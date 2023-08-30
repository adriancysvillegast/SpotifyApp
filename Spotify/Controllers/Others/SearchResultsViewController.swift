//
//  SearchResultsViewController.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 22/7/23.
//

import UIKit

protocol SearchResultsViewControllerDelegate: AnyObject {
    func didTapResult(_ result: SearchResult)
}

class SearchResultsViewController: UIViewController {

    // MARK: - Properties
    
    weak var delegate : SearchResultsViewControllerDelegate?
    private var sections: [SearchSection] = []
    
    private lazy var aTableView: UITableView = {
        let aTableView = UITableView(frame: .zero, style: .grouped)
        aTableView.delegate = self
        aTableView.dataSource = self
        aTableView.isHidden = true
        aTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        aTableView.register(SearchResultDefaultTableViewCell.self,
                            forCellReuseIdentifier: SearchResultDefaultTableViewCell.identifier)
        aTableView.register(SearchResultSubtitleTableViewCell.self,
                            forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier)
        aTableView.backgroundColor = .systemBackground
        aTableView.rowHeight = 70
        return aTableView
    }()
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        aTableView.frame = view.bounds
    }
     
    // MARK: - setupView
    private func setupView() {
        view.backgroundColor = .clear
        view.addSubview(aTableView)
    }

    // MARK: - Methods
    func update(with model: [SearchResult]) {
        let artists = model.filter {
            switch $0 {
            case .artist:
                return true
            default: return false
            }
        }
        
        let albums = model.filter {
            switch $0 {
            case .album:
                return true
            default: return false
            }
        }
        
        let playlist = model.filter {
            switch $0 {
            case .playlist:
                return true
            default: return false
            }
        }
        
        let track = model.filter {
            switch $0 {
            case .track:
                return true
            default: return false
            }
        }
        
        self.sections = [
            SearchSection(title: "Artists", result: artists),
            SearchSection(title: "Albums", result: albums),
            SearchSection(title: "Playlists", result: playlist),
            SearchSection(title: "Songs", result: track)
        ]
        self.aTableView.reloadData()
        
        if !sections.isEmpty {
            self.aTableView.isHidden =  false
        }
    }
}

extension SearchResultsViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].result.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = sections[indexPath.section].result[indexPath.row]

        switch result {
        case .artist(let artist):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultDefaultTableViewCell.identifier, for: indexPath) as? SearchResultDefaultTableViewCell else {
                return UITableViewCell()
            }
            
            let viewModel = SearchResultDefaultTableViewCellViewModel(
                title: artist.name,
                imageURL: URL(string: artist.images?.first?.url ?? "" )
            )
            cell.configure(with: viewModel)
            
            return cell
        case .track(let songs):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else {
                return UITableViewCell()
            }
            
            let viewModel = SearchResultSubtitleTableViewCellViewModel(
                title: songs.name,
                subtitle: songs.artists.first?.name ?? "-",
                imageURL: URL(string: songs.album?.images.first?.url ?? "" )
            )
            cell.configure(with: viewModel)
            return cell
        case .album(let album):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else {
                return UITableViewCell()
            }
            
            let viewModel = SearchResultSubtitleTableViewCellViewModel(
                title: album.name,
                subtitle: album.artists.first?.name ?? "-",
                imageURL: URL(string: album.images.first?.url ?? "" )
            )
            cell.configure(with: viewModel)
            return cell
        case .playlist(let playlist):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else {
                return UITableViewCell()
            }
            
            let viewModel = SearchResultSubtitleTableViewCellViewModel(
                title: playlist.name,
                subtitle: playlist.owner.displayName,
                imageURL: URL(string: playlist.images.first?.url ?? "" )
            )
            cell.configure(with: viewModel)
            return cell
        }
    }
     
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result = sections[indexPath.section].result[indexPath.row]
        
        self.delegate?.didTapResult(result)
    }
}
