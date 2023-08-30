//
//  NewReleaseCollectionViewCell.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 7/8/23.
//

import UIKit
import SDWebImage

class NewReleaseCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "NewReleaseCollectionViewCell"
    
    private lazy var aImageView: UIImageView = {
        let aImageView = UIImageView()
        aImageView.image = UIImage(systemName: "photo")
        aImageView.contentMode = .scaleAspectFill
        return aImageView
    }()
    
    private lazy var albumNameLabel: UILabel = {
        let aLabel = UILabel()
        aLabel.numberOfLines = 0
        aLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        return aLabel
    }()
    
    private lazy var numberOfTrackLabel: UILabel = {
        let aLabel = UILabel()
        aLabel.numberOfLines = 0
        aLabel.font = .systemFont(ofSize: 18, weight: .thin)
        return aLabel
    }()
    
    private lazy var artistNameLabel: UILabel = {
        let aLabel = UILabel()
        aLabel.numberOfLines = 0
        aLabel.font = .systemFont(ofSize: 18, weight: .light)
        return aLabel
    }()
    // MARK: - setupView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        [aImageView, albumNameLabel,numberOfTrackLabel, artistNameLabel].forEach {
            addSubview($0)
        }
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let imageSize: CGFloat = contentView.height - 10
        let albumLabelSize = albumNameLabel.sizeThatFits(
            CGSize(
                width: contentView.width-imageSize-10,
                height: contentView.height-10
            )
        )
        
        artistNameLabel.sizeToFit()
        numberOfTrackLabel.sizeToFit()
        aImageView.frame = CGRect(x: 5, y: 5, width: imageSize, height: imageSize)
        
        let albumLabelHeight = min(60, albumLabelSize.height)
        albumNameLabel.frame = CGRect(
            x: aImageView.right + 10,
            y: 5,
            width: albumLabelSize.width,
            height: albumLabelHeight
        )
        
        artistNameLabel.frame = CGRect(
            x: aImageView.right + 10,
            y: albumNameLabel.botton,
            width: contentView.width - aImageView.right-5,
            height: 30
        )
        
        numberOfTrackLabel.frame = CGRect(
            x: aImageView.right + 10,
            y: contentView.botton - 40,
            width: numberOfTrackLabel.width+5,
            height: 44
        )

        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        albumNameLabel.text = nil
        artistNameLabel.text = nil
        numberOfTrackLabel.text = nil
        aImageView.image = nil
    }
    
    // MARK: - Methods
    
    func configure(with viewModel: NewReleasesCellViewModel) {
        albumNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
        numberOfTrackLabel.text = "Tracks: \(viewModel.numberOfTracks) "
        aImageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
    }
}
