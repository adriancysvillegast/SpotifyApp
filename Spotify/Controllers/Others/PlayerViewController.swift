//
//  PlayerViewController.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 22/7/23.
//

import UIKit
import SDWebImage

protocol PlayerViewControllerDelegate: AnyObject {
    func didTapPlayPause()
    func didTapForward()
    func didTapBackward()
    func didSlideSlider(_ value: Float)
}

class PlayerViewController: UIViewController {

    // MARK: - Properties
    weak var dataSource: PlayerDataSource?
    weak var delegate: PlayerViewControllerDelegate?
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let controlsView = Spotify.PlayerControlsView() //i need to used here spotify because xcode show me an error, i don't know why 
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        configureBarButton()
        controlsView.delegate = self
        configure()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: view.width,
            height: view.width
        )
        controlsView.frame = CGRect(
            x: 10,
            y: imageView.botton+10,
            width: view.width-10,
            height: view.height-imageView.height-view.safeAreaInsets.top-view.safeAreaInsets.bottom-15
        )
    }
    
    // MARK: - SetupView
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        view.addSubview(controlsView)
    }

    // MARK: - Methods

    private func configureBarButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapAction))
    }
    
    @objc func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapAction() {
//        add action
    }
    
    private func configure() {
        imageView.sd_setImage(with: dataSource?.image, completed: nil)
        controlsView.configure(
            with: PlayerControlsViewViewModel(
                title: dataSource?.songName,
                subtitle: dataSource?.subtitle)
        )
    }
    
    func refreshUI() {
        configure() 
    }
}

// MARK: - PlayerControlsViewDelegate
extension PlayerViewController: PlayerControlsViewDelegate {
    func PlayerControlsView(_ playerControlsView: PlayerControlsView, didSlideSlider value: Float) {
        delegate?.didSlideSlider(value)
    }
    
    func PlayerControlsViewDidtapPlayPauseButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapPlayPause()
    }
    
    func PlayerControlsViewDidtapForwardButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapForward()
    }
    
    func PlayerControlsViewDidtapBackwardButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapBackward()
    }
    
}
