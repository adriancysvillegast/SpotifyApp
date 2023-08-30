//
//  CategoryViewController.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 18/8/23.
//

import UIKit

class CategoryViewController: UIViewController {

    // MARK: - Properties
    let category: Category
    private var playlists = [Playlist]()
    
    private lazy var aCollectionView: UICollectionView = {
        let aCollectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout(
                sectionProvider: { _,_ -> NSCollectionLayoutSection? in
                    let item = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .fractionalHeight(1)
                        )
                    )
                    item.contentInsets = NSDirectionalEdgeInsets(
                        top: 2,
                        leading: 2,
                        bottom: 2,
                        trailing: 2)
                    
                    let group = NSCollectionLayoutGroup.horizontal(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(250)),
                        subitem: item,
                        count: 2)
                    
                    group.contentInsets = NSDirectionalEdgeInsets(
                        top: 5,
                        leading: 2,
                        bottom: 5,
                        trailing: 2)
                    
                    return NSCollectionLayoutSection(group: group)
                })
        )
        aCollectionView.register(PlaylistCollectionViewCell.self, forCellWithReuseIdentifier: PlaylistCollectionViewCell.identifier)
        aCollectionView.delegate = self
        aCollectionView.dataSource = self
        aCollectionView.backgroundColor = .systemBackground
        return aCollectionView
    }()
    
    // MARK: - Init
    
    init(category: Category) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        aCollectionView.frame = view.bounds
    }
    
    // MARK: - SetupView
    private func setupView() {
        title = category.name
        view.backgroundColor = . systemBackground
        view.addSubview(aCollectionView)
    }
    
    // MARK: - Methods

    private func fetchData() {
        APIManager.shared.getCategoryPlaylist(category: category) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let playlist):
                    self?.playlists = playlist
                    self?.aCollectionView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension CategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PlaylistCollectionViewCell.identifier,
            for: indexPath) as? PlaylistCollectionViewCell  else {
            return UICollectionViewCell()
        }
        let playlist = playlists[indexPath.row]
        cell.configure(with: FeaturedPlaylistCellViewModel(
            name: playlist.name,
            creatorName: playlist.owner.displayName,
            artworkURL: URL(string: playlist.images.first?.url ?? ""))
        )
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let vc = PlaylistViewController(playlist: playlists[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
}
