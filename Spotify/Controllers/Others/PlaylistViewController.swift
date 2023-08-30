//
//  PlaylistViewController.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 22/7/23.
//

import UIKit

class PlaylistViewController: UIViewController {
    
    // MARK: - Properties
    public var isOwner: Bool = false
    
    private let playlist: Playlist
    
    private var viewModels = [RecommendedTrackCellViewModel]()
    private var tracks = [AudioTrack]()
    
    private lazy var aCollectionView: UICollectionView = {
        let aCollectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout:
                UICollectionViewCompositionalLayout { _, _  -> NSCollectionLayoutSection? in
                    let item = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .fractionalHeight(1.0)
                        )
                    )
                    item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 2, bottom: 1, trailing: 2)
                    
                    let group = NSCollectionLayoutGroup.vertical(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(60)
                        ),
                        subitem: item,
                        count: 1
                    )
                    
                    let section = NSCollectionLayoutSection(group: group)
                    //add Header to aCollectionView
                    section.boundarySupplementaryItems = [
                        NSCollectionLayoutBoundarySupplementaryItem(
                            layoutSize: NSCollectionLayoutSize(
                                widthDimension: .fractionalWidth(1),
                                heightDimension: .fractionalWidth(1)),
                            elementKind: UICollectionView.elementKindSectionHeader,
                            alignment: .top)
                    ]
                    return section
                })
        //cells
        aCollectionView.register(
            RecommendedTrackCollectionViewCell.self,
            forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier
        )
        //header
        aCollectionView.register(
            PlaylistHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier
        )
        aCollectionView.backgroundColor = .systemBackground
        aCollectionView.delegate = self
        aCollectionView.dataSource = self
        return aCollectionView
    }()
    
    
    init(playlist: Playlist) {
        self.playlist = playlist
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = playlist.name
        view.backgroundColor = .systemBackground
        // Do any additional setup after loading the view.
        setupView()
        getPlaylistInfo()
        addLongTapGesture()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action,
                                                            target: self,
                                                            action: #selector(didTapShare))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        aCollectionView.frame = view.bounds
    
    }
    
    // MARK: - SetupView
    private func setupView() {
        view.addSubview(aCollectionView)
    }
    
    private func addLongTapGesture() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        aCollectionView.addGestureRecognizer(gesture)
    }
    
    @objc func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else {
            return
        }
        
        let touchPoint = gesture.location(in: aCollectionView)
        guard let indexPath = aCollectionView.indexPathForItem(at: touchPoint) else {
            return
        }
        
        let trackToDelete = tracks[indexPath.row]
        
        let actionCheet = UIAlertController(
            title: "Remove",
            message: "Would you like to delete \(trackToDelete.name) ?",
            preferredStyle: .actionSheet)
        
        actionCheet.addAction(UIAlertAction(title: "Cancel",
                                             style: .cancel,
                                             handler: nil))
        
        actionCheet.addAction(UIAlertAction(title: "Delete", style: .default, handler: { [weak self] _ in
            guard let strongSelf = self else { return }
            
            APIManager.shared.removeTrackFromPlaylist(
                track: trackToDelete,
                playlist: strongSelf.playlist) { success in
                    DispatchQueue.main.async {
                        if success {
                            strongSelf.tracks.remove(at: indexPath.row)
                            strongSelf.viewModels.remove(at: indexPath.row)
                            strongSelf.aCollectionView.reloadData()
                        }else {
                            print("ERROR Removing track")
                        }
                    }
                }
        }))
        present(actionCheet, animated: true)
    }
    
    // MARK: - Methods
    private func getPlaylistInfo() {
        APIManager.shared.getPlaylistDetail(with: self.playlist) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self?.tracks = model.tracks.items.compactMap({ $0.track })
                    self?.viewModels = model.tracks.items.compactMap({
                        RecommendedTrackCellViewModel(
                            name: $0.track.name,
                            artistName: $0.track.artists.first?.name ?? "-",
                            artworkURL: URL(string: $0.track.album?.images.first?.url ?? ""))
                    })
                    self?.aCollectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    @objc private func didTapShare() {
        guard let url = URL(string: playlist.externalUrls["spotify"] ?? "") else {
            return
        }
        
        let vc = UIActivityViewController(
            activityItems: [url]
            , applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true, completion: nil)
    }
    
    
}

// MARK: - Description
extension PlaylistViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier, for: indexPath) as? RecommendedTrackCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let track = tracks[indexPath.row]
        PlaybackPresenter.shared.startPlayback(from: self, track: track)
    }
    
//    for header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier,
            for: indexPath) as? PlaylistHeaderCollectionReusableView,
              kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let headerViewModel = PlaylistHeaderViewModel(
            name: playlist.name,
            descrption: playlist.description,
            owner: playlist.owner.displayName,
            artworkURL: URL(string: playlist.images.first?.url ?? "" )
        )
        header.delegate = self //protocol to get action playAll
        header.configure(with: headerViewModel)
        return header
    }
    
    
}

extension PlaylistViewController: PlaylistHeaderCollectionReusableViewDelegate {
    func PlaylistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView) {
        PlaybackPresenter.shared.startPlayback(from: self, tracks: tracks)
    }
    
    
}
