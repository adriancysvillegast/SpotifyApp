//
//  PlaylistHeaderCollectionReusableView.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 11/8/23.
//

import UIKit
import SDWebImage

protocol PlaylistHeaderCollectionReusableViewDelegate: AnyObject {
    func PlaylistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView)
}

final class PlaylistHeaderCollectionReusableView: UICollectionReusableView {
    // MARK: - Properties
    static let identifier = "PlaylistHeaderCollectionReusableView"
    weak var delegate: PlaylistHeaderCollectionReusableViewDelegate?
    
    private lazy var nameLabel: UILabel = {
        let aLabel = UILabel()
        aLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        return aLabel
    }()
    
    private lazy var descriptioLabel: UILabel = {
        let aLabel = UILabel()
        aLabel.numberOfLines = 0
        aLabel.textColor = .secondaryLabel
        aLabel.font = .systemFont(ofSize: 18, weight: .regular)
        return aLabel
    }()
    
    private lazy var ownerLabel: UILabel = {
        let aLabel = UILabel()
        aLabel.textColor = .secondaryLabel
        aLabel.font = .systemFont(ofSize: 18, weight: .light)
        return aLabel
    }()
    
    private lazy var aImage: UIImageView = {
        let aImage = UIImageView()
        aImage.contentMode = .scaleAspectFill
        aImage.image = UIImage(systemName: "music.note.list")
        return aImage
    }()
    
    private lazy var playButton: UIButton = {
        let aButton = UIButton()
        aButton.backgroundColor = .systemGreen
        let image = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .regular) )
        aButton.setImage(image, for: .normal)
        aButton.tintColor = .white
        aButton.layer.cornerRadius = 30
        aButton.layer.masksToBounds = true
        return aButton
    }()
    
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        [nameLabel, descriptioLabel, ownerLabel, aImage, playButton].forEach {
            addSubview($0)
        }
        playButton.addTarget(self, action: #selector(didTapPlayAll), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - SetupView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize : CGFloat = height / 1.8
        aImage.frame = CGRect(x: (width-imageSize) / 2, y: 0, width: imageSize, height: imageSize)
        nameLabel.frame = CGRect(x: 10, y: aImage.botton, width: width - 20, height: 44)
        descriptioLabel.frame = CGRect(x: 10, y: nameLabel.botton, width: width - 20, height: 44)
        ownerLabel.frame = CGRect(x: 10, y: descriptioLabel.botton, width: width - 20, height: 44)
        playButton.frame = CGRect(x: width-80, y: height-80, width: 60, height: 60)
    }
    
    // MARK: - Methods
    
    func configure(with viewModel: PlaylistHeaderViewModel) {
        nameLabel.text = viewModel.name
        descriptioLabel.text = viewModel.descrption
        ownerLabel.text = viewModel.owner
        aImage.sd_setImage(with: viewModel.artworkURL, placeholderImage: UIImage(systemName: "photo"))
    }
    
    @objc private func didTapPlayAll() {
        delegate?.PlaylistHeaderCollectionReusableViewDidTapPlayAll(self)
    }
}
