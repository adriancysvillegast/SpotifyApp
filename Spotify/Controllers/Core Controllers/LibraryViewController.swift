//
//  LibraryViewController.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 22/7/23.
//

import UIKit

class LibraryViewController: UIViewController, UIScrollViewDelegate {

    // MARK: - Properties
    
    private let playlistVC = LibraryPlaylistsViewController()
    private let albumVC = LibraryAlbumsViewController()
    
    private lazy var toogleView : LibraryToggleView = {
       let view = LibraryToggleView()
        view.delegate = self
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
       let scroll = UIScrollView()
        scroll.isPagingEnabled = true
        scroll.delegate = self
        scroll.contentSize = CGSize(width: view.width*2, height: scroll.height)
        return scroll
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupChild()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top+55,
            width: view.width,
            height: view.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom - 55
        )
        
        toogleView.frame = CGRect(
            x: view.center.x/2,
            y: view.safeAreaInsets.top,
            width: 200,
            height: 55
        )
    }

    // MARK: - setupView
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        view.addSubview(toogleView)
    }
    
    private func setupChild() {
        addChild(playlistVC)
        addChild(albumVC)
        
        [playlistVC.view, albumVC.view].forEach {
            scrollView.addSubview($0)
        }
        
        playlistVC.view.frame = CGRect(
            x: 0,
            y: 0,
            width: scrollView.width,
            height: scrollView.height
        )
        
        albumVC.view.frame = CGRect(
            x: view.width,
            y: 0,
            width: scrollView.width,
            height: scrollView.height
        )
        
        playlistVC.didMove(toParent: self)
        albumVC.didMove(toParent: self)
    }
    
    private func setBarButtons() {
        switch toogleView.state {
        case .playlist:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddPlaylist))
        case .album :
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    // MARK: - Methods
    @objc func didTapAddPlaylist() {
        playlistVC.showAlertToCreatePlaylist()
    }
    
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x >= (view.width-170) {
            toogleView.update(for: .album)
            setBarButtons()
        }else {
            toogleView.update(for: .playlist)
            setBarButtons()
        }
    }
}



// MARK: - LibraryToggleViewDelegate
extension LibraryViewController: LibraryToggleViewDelegate {
    
    func LibraryToggleViewDidTapPlaylists(_ toggleView: LibraryToggleView) {
        scrollView.setContentOffset(.zero, animated: true)
        setBarButtons()
    }
    
    func LibraryToggleViewDidTapAlbums(_ toggleView: LibraryToggleView) {
        scrollView.setContentOffset(CGPoint(x: view.width, y: 0), animated: true)
        setBarButtons()
    }
}

