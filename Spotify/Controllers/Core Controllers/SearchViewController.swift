//
//  SearchViewController.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 17/8/23.
//

import UIKit
import SafariServices

class SearchViewController: UIViewController {

    // MARK: - Properties
    
    private var categories = [Category]()
    
    private lazy var aSearchBar: UISearchController = {
        let aSearchBar = UISearchController(searchResultsController: SearchResultsViewController())
        aSearchBar.searchBar.placeholder = "Sounds, Albums and Artists"
        aSearchBar.searchBar.searchBarStyle = .minimal
        aSearchBar.definesPresentationContext = true
        aSearchBar.searchResultsUpdater = self
        return aSearchBar
    }()
    
    private lazy var aCollectionView: UICollectionView = {
        let aCollectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout(
                sectionProvider: {_, _ -> NSCollectionLayoutSection in
                
                    let item = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .fractionalHeight(1)
                        )
                    )
                    
                    item.contentInsets = NSDirectionalEdgeInsets(top: 2,
                                                                 leading: 7,
                                                                 bottom: 2,
                                                                 trailing: 7
                    )
                    
                    let group = NSCollectionLayoutGroup.horizontal(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(180)
                        ),
                        subitem: item,
                        count: 2)
                    
                    group.contentInsets = NSDirectionalEdgeInsets(top: 10,
                                                                  leading: 1,
                                                                  bottom: 10,
                                                                  trailing: 1
                    )
                    
                    return NSCollectionLayoutSection(group: group)
            })
        )
        aCollectionView.backgroundColor = .systemBackground
        aCollectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        aCollectionView.dataSource = self
        aCollectionView.delegate = self
        return aCollectionView
    }()
    
    // MARK: - Body
    
    override func viewDidLoad() {
        super.viewDidLoad()
        aSearchBar.searchResultsUpdater = self
        aSearchBar.searchBar.delegate = self
        setupView()
        fetchCategories()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        aCollectionView.frame = view.bounds
    }
    
    // MARK: - setupView
    
    func setupView() {
        view.backgroundColor = .red
        navigationItem.searchController = aSearchBar
        view.addSubview(aCollectionView)
        
    }

    private func fetchCategories() {
        APIManager.shared.getCategories { [weak self] results in
            DispatchQueue.main.async {
                switch results {
                case .success(let categories):
                    self?.categories = categories
                    self?.aCollectionView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
// MARK: - UISearchResultsUpdating, UISearchBarDelegate
extension SearchViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //call api
        guard let resultController = aSearchBar.searchResultsController as? SearchResultsViewController, let query = searchBar.text, !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        resultController.delegate = self
        
        APIManager.shared.search(with: query) { result in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    resultController.update(with: model)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
}
// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        let category = categories[indexPath.row]
        cell.configure(with:
                        CategoryCollectionViewCellViewModel(
            name: category.name,
            artworkURL: URL(string: category.icons.first?.url ?? "")
                        )
        )
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()
        let vc = CategoryViewController(category: categories[indexPath.row])
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
// MARK: - SearchResultsViewControllerDelegate
extension SearchViewController: SearchResultsViewControllerDelegate {

    func didTapResult(_ result: SearchResult) {
        switch result {
        case .artist(let model):
            guard let url = URL(string: model.externalUrls["spotify"] ?? "") else {
                return
            }
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true)
            
        case .track(let model):
            PlaybackPresenter.shared.startPlayback(from: self, track: model)
        case .album(let model):
            let vc = AlbumViewController(album: model)
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .playlist(let model):
            let vc = PlaylistViewController(playlist: model)
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
