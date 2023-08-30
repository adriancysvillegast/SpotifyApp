//
//  AlbumViewController.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 10/8/23.
//

import UIKit

class AlbumViewController: UIViewController {
    
    // MARK: - Properties
    private let album: AlbumResponse
    private var tracks = [AudioTrack]()
    private var viewModels = [AlbumCollectionCellViewModel]()
    
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
            AlbumTrackCollectionViewCell.self,
            forCellWithReuseIdentifier: AlbumTrackCollectionViewCell.identifier
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
    
    init(album: AlbumResponse) {
        self.album = album
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = album.name
        view.backgroundColor = .systemBackground
        getAlbumInfo()
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        aCollectionView.frame = view.bounds
    }
    
    // MARK: - SetupView
    
    private func setupView() {
        view.addSubview(aCollectionView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action,
                                                            target: self,
                                                            action: #selector(didTapAction))
    }
    
    // MARK: - Methods
    
    private func getAlbumInfo() {
        APIManager.shared.getAlbumDetail(with: self.album) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model) :
                    self?.tracks = model.tracks.items
                    self?.viewModels = model.tracks.items.compactMap({
                        AlbumCollectionCellViewModel(
                            name: $0.name,
                            artistName: $0.artists.first?.name ?? "-"
                        )
                    })
                    self?.aCollectionView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    
    @objc func didTapAction() {
        print("didTapAction   ------")
        let actionSheet = UIAlertController(title: album.name,
                                            message: "Actions",
                                            preferredStyle: .actionSheet
        )
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Save Album", style: .default, handler: { [weak self] _ in
            guard let strongSelf = self else { return }
            
            
            APIManager.shared.saveAlbum(album: strongSelf.album) { success in
                if success {
                    HapticsManager.shared.vibrate(for: .success)
                    NotificationCenter.default.post(name: .albumSavedNotification, object: nil)
                }else{
                    HapticsManager.shared.vibrate(for: .error)
                }
            }
        }))
        present(actionSheet, animated: true)
    }
}

// MARK: - Description
extension AlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumTrackCollectionViewCell.identifier, for: indexPath) as? AlbumTrackCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        var track = tracks[indexPath.row]
        track.album = self.album
        PlaybackPresenter.shared.startPlayback(from: self, track: track )
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
            name: album.name,
            descrption: "Releases Date: \(String.formattedDate(string: album.releaseDate))",
            owner: album.artists.first?.name ?? "-",
            artworkURL: URL(string: album.images.first?.url ?? "" )
        )
        header.delegate = self //protocol to get action playAll
        header.configure(with: headerViewModel)
        return header
    }
    
    
}

extension AlbumViewController: PlaylistHeaderCollectionReusableViewDelegate {
    func PlaylistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView) {
        let tracksWithAlbum : [AudioTrack] = tracks.compactMap {
            var track = $0
            track.album = self.album
            return track
        }
        PlaybackPresenter.shared.startPlayback(from: self, tracks: tracksWithAlbum)
    }
    
    
}
