//
//  LibraryToggleView.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 27/8/23.
//

import UIKit

protocol LibraryToggleViewDelegate: AnyObject {
    func LibraryToggleViewDidTapPlaylists(_ toggleView: LibraryToggleView)
    func LibraryToggleViewDidTapAlbums(_ toggleView: LibraryToggleView)
}

class LibraryToggleView: UIView {

    // MARK: - enum
    
    enum State {
        case playlist
        case album
    }
    
    // MARK: - Properties
    var state: State = .playlist
    
    weak var delegate: LibraryToggleViewDelegate?
    
    private lazy var playlistButton: UIButton = {
        let button = UIButton()
        button.setTitle("Playlist", for: .normal)
        button.setTitleColor(.label, for: .normal)
        return button
    }()
    
    private lazy var albumsButton: UIButton = {
        let button = UIButton()
        button.setTitle("Albums ", for: .normal)
        button.setTitleColor(.label, for: .normal)
        return button
    }()
    
    private lazy var indicatorView: UIView = {
       let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 4
        return view
    }()
    
    // MARK: - SetupView

    override init(frame: CGRect) {
        super.init(frame: frame)
        [playlistButton, albumsButton, indicatorView].forEach { addSubview($0) }
        
        playlistButton.addTarget(self, action: #selector(didTapPlaylist), for: .touchUpInside)
        albumsButton.addTarget(self, action: #selector(didTapAlbums), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playlistButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        albumsButton.frame = CGRect(x: playlistButton.right, y: 0, width: 100, height: 40)
        layoutIndicator()
    }
    
    // MARK: - Methods
    
    private func layoutIndicator() {
        switch state {
        case .playlist:
            indicatorView.frame = CGRect(x: 0, y: playlistButton.botton, width: 100, height: 3)
        case .album:
            indicatorView.frame = CGRect(x: 100, y: playlistButton.botton, width: 100, height: 3)
        }
    }
    
    @objc func didTapPlaylist() {
        state = .playlist
        UIView.animate(withDuration: 0.2) {
            self.layoutIndicator()
        }
        delegate?.LibraryToggleViewDidTapPlaylists(self)
    }
    
    @objc func didTapAlbums() {
        state = .album
        UIView.animate(withDuration: 0.2) {
            self.layoutIndicator()
        }
        delegate?.LibraryToggleViewDidTapAlbums(self)
    }
    
    func update(for state: State) {
        self.state = state
        UIView.animate(withDuration: 0.2) {
            self.layoutIndicator()
        }
    }
}
