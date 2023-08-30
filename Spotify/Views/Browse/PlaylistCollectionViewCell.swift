//
//  PlaylistCollectionViewCell.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 7/8/23.
//

import UIKit
import SDWebImage

class PlaylistCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    static let identifier = "PlaylistCollectionViewCell"
    
    private lazy var aImageView: UIImageView = {
        let aImageView = UIImageView()
        aImageView.image = UIImage(systemName: "photo")
        aImageView.contentMode = .scaleAspectFill
        aImageView.layer.masksToBounds = true
        aImageView.layer.cornerRadius = 4
        return aImageView
    }()
    
    private lazy var playlistNameLabel: UILabel = {
        let aLabel = UILabel()
        aLabel.numberOfLines = 0
        aLabel.textAlignment = .center
        aLabel.font = .systemFont(ofSize: 18, weight: .regular)
        return aLabel
    }()
    
    private lazy var creatorNameLabel: UILabel = {
        let aLabel = UILabel()
        aLabel.numberOfLines = 0
        aLabel.textAlignment = .center
        aLabel.font = .systemFont(ofSize: 15, weight: .thin)
        return aLabel
    }()
    // MARK: - setupView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        contentView.backgroundColor = .secondarySystemBackground
        [aImageView, playlistNameLabel, creatorNameLabel].forEach {
            addSubview($0)
        }
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        creatorNameLabel.frame = CGRect(
            x: 3,
            y: contentView.height-30,
            width: contentView.width-6,
            height: 30
        )
        
        playlistNameLabel.frame = CGRect(
            x: 3,
            y: contentView.height-60,
            width: contentView.width-6,
            height: 30
        )
        
        let imageSize = contentView.height-70
        aImageView.frame =  CGRect(
            x: (contentView.width-imageSize)/2,
            y: 3,
            width: imageSize,
            height: imageSize
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playlistNameLabel.text = nil
        creatorNameLabel.text = nil
        aImageView.image = nil
    }
    
    // MARK: - Methods
    
    func configure(with viewModel: FeaturedPlaylistCellViewModel) {
        playlistNameLabel.text = viewModel.name
        creatorNameLabel.text = viewModel.creatorName
        aImageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
    }
    
}
