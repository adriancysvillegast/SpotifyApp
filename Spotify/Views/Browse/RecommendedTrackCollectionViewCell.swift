//
//  RecommendedTrackCollectionViewCell.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 7/8/23.
//

import UIKit
import SDWebImage

class RecommendedTrackCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "RecommendedTrackCollectionViewCell"
    
    private lazy var aImageView: UIImageView = {
        let aImageView = UIImageView()
        aImageView.image = UIImage(systemName: "photo")
        aImageView.contentMode = .scaleAspectFill
        return aImageView
    }()
    
    private lazy var trackNameLabel: UILabel = {
        let aLabel = UILabel()
        aLabel.numberOfLines = 0
        aLabel.font = .systemFont(ofSize: 18, weight: .regular)
        return aLabel
    }()
    
    private lazy var artistsNameLabel: UILabel = {
        let aLabel = UILabel()
        aLabel.numberOfLines = 0
        aLabel.font = .systemFont(ofSize: 15, weight: .thin)
        return aLabel
    }()
    // MARK: - setupView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .secondarySystemBackground
        
        [aImageView, trackNameLabel, artistsNameLabel].forEach {
            addSubview($0)
        }
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        aImageView.frame = CGRect(
            x: 5,
            y: 2,
            width: contentView.height-4,
            height: contentView.height-4
        )
        
        trackNameLabel.frame = CGRect(
            x: aImageView.right+10,
            y: 0,
            width: contentView.width-aImageView.right-15,
            height: contentView.height/2
        )
        
        artistsNameLabel.frame = CGRect(
            x: aImageView.right+10,
            y: contentView.height/2,
            width: contentView.width-aImageView.right-15,
            height: contentView.height/2
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackNameLabel.text = nil
        artistsNameLabel.text = nil
        aImageView.image = nil
    }
    
    // MARK: - Methods
    
    func configure(with viewModel: RecommendedTrackCellViewModel) {
        trackNameLabel.text = viewModel.name
        artistsNameLabel.text = viewModel.artistName
        aImageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
    }
    
}
