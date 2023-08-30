//
//  HomeViewController.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 22/7/23.
//

import UIKit

enum BrowseSectionType {
    case newRelease(viewMode: [NewReleasesCellViewModel])
    case featuredPlaylist(viewMode: [FeaturedPlaylistCellViewModel])
    case recommendedTracks(viewMode: [RecommendedTrackCellViewModel])
    
    var title: String {
        switch self {
        case .newRelease:
            return "New Releases"
        case .featuredPlaylist:
            return "Feature Playlist"
        case .recommendedTracks:
            return "Recommended"
        }
    }
}

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    private lazy var aCollectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _  -> NSCollectionLayoutSection? in
            return HomeViewController.createSectionLayout(section: sectionIndex)
        }
        let aCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        aCollectionView.delegate = self
        aCollectionView.dataSource = self
        aCollectionView.register(NewReleaseCollectionViewCell.self, forCellWithReuseIdentifier: NewReleaseCollectionViewCell.identifier)
        aCollectionView.register(PlaylistCollectionViewCell.self, forCellWithReuseIdentifier: PlaylistCollectionViewCell.identifier)
        aCollectionView.register(RecommendedTrackCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier)
        aCollectionView.register(TitleHeaderCollectionReusableView.self,
                                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                 withReuseIdentifier: TitleHeaderCollectionReusableView.identifier)
        return aCollectionView
    }()
    
    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    var newAlbums: [AlbumResponse] = []
    var playlist: [Playlist] = []
    var tracks: [AudioTrack] = []
    
    //to Save Data on fetchData
    private var sections = [BrowseSectionType]()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupView()
        fetchData()
        addLongTapGesture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        aCollectionView.frame = view.bounds
    }
    
    // MARK: - setupView
    
    private func setupView() {
        view.addSubview(aCollectionView)
        view.addSubview(spinner)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(goToProfile))
        
    }
    
    // MARK: - Methods
    
    @objc private func goToProfile() {
        let vc = SettingsViewController()
        vc.title = "Settings"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func fetchData() {
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        
        var newRelease : NewReleasesResponse?
        var featuredPlaylist: FeaturedPlaylistResponse?
        var recommendation: RecomendationsResponse?
        
        //        New Releases
        APIManager.shared.getReleases { result in
            defer {
                group.leave()
            }
            
            switch result {
            case .success(let model):
                newRelease = model
            case .failure(let error):
                print("error in \(#function) --> \(error.localizedDescription)")
            }
        }
        
        //        Featured Playlist
        APIManager.shared.getFeaturedPlaylist { result in
            defer {
                group.leave()
            }
            
            switch result {
            case .success(let model):
                featuredPlaylist = model
            case .failure(let error):
                print("error in \(#function) --> \(error.localizedDescription)")
            }
        }
        
        //        Recommended tracks
        APIManager.shared.getRecommendedGenres { result in
            
            switch result {
            case .success(let model):
                let genres = model.genres
                var seedns = Set<String>()
                while seedns.count < 5 {
                    if let random = genres.randomElement() {
                        seedns.insert(random)
                    }
                }
                
                APIManager.shared.getRecomendations(genres: seedns) { recommendedResults in
                    defer {
                        group.leave()
                    }
                    
                    switch recommendedResults {
                    case .success(let model):
                        recommendation = model
                    case .failure(let error):
                        print("error in \(#function) --> \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                print("error in \(#function) --> \(error.localizedDescription)")
            }
        }
        
        group.notify(queue: .main) {
            guard let newAlbums = newRelease?.albums.items,
                  let playlist = featuredPlaylist?.playlists.items,
                  let tracks = recommendation?.tracks else {
                return
            }
            self.configureModels(newAlbums: newAlbums, playlist: playlist, tracks: tracks)
        }
    }
    
    private func configureModels(newAlbums: [AlbumResponse],
                                 playlist: [Playlist],
                                 tracks: [AudioTrack] ) {
        self.newAlbums = newAlbums
        self.playlist = playlist
        self.tracks = tracks
        //        configure Models
        sections.append(.newRelease(viewMode: newAlbums.compactMap({
            return NewReleasesCellViewModel(
                name: $0.name,
                numberOfTracks: $0.totalTracks,
                artistName: $0.artists.first?.name ?? "-",
                artworkURL: URL(string: $0.images.first?.url ?? ""))
        })))
        
        sections.append(.featuredPlaylist(viewMode: playlist.compactMap({
            return FeaturedPlaylistCellViewModel(
                name: $0.description,
                creatorName: $0.owner.displayName,
                artworkURL: URL(string: $0.images.first?.url ?? ""))
        })))
        
        sections.append(.recommendedTracks(viewMode: tracks.compactMap({
            return RecommendedTrackCellViewModel(
                name: $0.name,
                artistName: $0.artists.first?.name ?? "-",
                artworkURL: URL(string: $0.album?.images.first?.url ?? ""))
        })))
        
        aCollectionView.reloadData()
    }
    
    private func addLongTapGesture() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        aCollectionView.isUserInteractionEnabled = true
        aCollectionView.addGestureRecognizer(gesture)
    }
    
    @objc func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        let touchPoint = gesture.location(in: aCollectionView)
        guard let indexPath = aCollectionView.indexPathForItem(at: touchPoint),
              indexPath.section == 2 else {
            return
        }
        let model = tracks[indexPath.row]
        
        let actionSheet = UIAlertController(
            title: model.name,
            message: "Would you like to add this track to a playlist?",
            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        actionSheet.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
            DispatchQueue.main.async {
                let vc = LibraryPlaylistsViewController()
                vc.selectionHandler = { playlist in
                    APIManager.shared.addTrackPlaylist(
                        track: model,
                        playlist: playlist) { success in
                            DispatchQueue.main.async {
                                if success {
                                    self?.showAlert(title: "Success", message: "Track: \(model.name) was added to playlist: \(playlist.name)")
                                }else {
                                    self?.showAlert(title: "Error", message: "We got a error adding \(model.name) to playlist: \(playlist.name)")
                                }
                            }
                        }
                }
                vc.title = "Select Playlist"
                self?.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
                
            }
             
        }))
        
        
        present(actionSheet, animated: true)
    }
    
    private func showAlert(title:String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Description

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = sections[section]
        
        switch type {
        case .newRelease(let viewModel) :
            return viewModel.count
        case .featuredPlaylist(let viewModel) :
            return viewModel.count
        case .recommendedTracks(let viewModel):
            return viewModel.count
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let type = sections[indexPath.section]
        
        switch type {
        case .newRelease(let viewModels) :
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: NewReleaseCollectionViewCell.identifier,
                for: indexPath) as? NewReleaseCollectionViewCell else {
                return UICollectionViewCell()
            }
            let viewModel = viewModels[indexPath.row]
            cell.configure(with: viewModel)
            return cell
            
        case .featuredPlaylist(let viewModels) :
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PlaylistCollectionViewCell.identifier,
                for: indexPath) as? PlaylistCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewModels[indexPath.row])
            return cell
        case .recommendedTracks(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier,
                for: indexPath) as? RecommendedTrackCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewModels[indexPath.row])
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TitleHeaderCollectionReusableView.identifier, for: indexPath) as? TitleHeaderCollectionReusableView,
              kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let title = sections[indexPath.section].title
        header.configure(with: title)
        
        return header
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()
        let section = sections[indexPath.section]
        
        switch section {
        case .featuredPlaylist:
            let playlist = playlist[indexPath.row]
            let vc = PlaylistViewController(playlist: playlist)
            vc.title = playlist.description
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .newRelease:
            let album = newAlbums[indexPath.row]
            let vc = AlbumViewController(album: album)
            vc.title = album.name
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .recommendedTracks:
            let track = tracks[indexPath.row]
            PlaybackPresenter.shared.startPlayback(from: self, track: track)
        }
    }
    
    static func createSectionLayout(section: Int) -> NSCollectionLayoutSection {
        
        let suplementaryViews = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(50)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)
        ]
        
        switch section {
        case 0:
            
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0))
            )
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(390)),
                subitem: item,
                count: 3)
            
            
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.9),
                    heightDimension: .absolute(390)),
                subitem: verticalGroup,
                count: 1)
            
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            section.boundarySupplementaryItems = suplementaryViews
            return section
            
        case 1:
            
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(200),
                    heightDimension: .absolute(200)
                )
            )
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(200),
                    heightDimension: .absolute(400)
                ),
                subitem: item,
                count: 2// two columns
            )
            
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(200),
                    heightDimension: .absolute(400)
                ),
                subitem: verticalGroup,
                count: 1// one columns
            )
            
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .continuous
            section.boundarySupplementaryItems = suplementaryViews
            return section
            
        case 2:
            
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(80)
                ),
                subitem: item,
                count: 1
            )
            
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = suplementaryViews
            return section
            
        default:
            
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0))
            )
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(390)),
                subitem: item,
                count: 1)
            
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = suplementaryViews
            return section
        }
    }
    
}
