//
//  AlbumTrackCollectionViewCell.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 14/8/23.
//

import UIKit
import SDWebImage

class AlbumTrackCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "AlbumTrackCollectionViewCell"

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
        
        [ trackNameLabel, artistsNameLabel].forEach {
            addSubview($0)
        }
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        trackNameLabel.frame = CGRect(
            x: 10,
            y: 0,
            width: contentView.width-15,
            height: contentView.height/2
        )
        
        artistsNameLabel.frame = CGRect(
            x: 10,
            y: contentView.height/2,
            width: contentView.width-15,
            height: contentView.height/2
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackNameLabel.text = nil
        artistsNameLabel.text = nil
    }
    
    // MARK: - Methods
    
    func configure(with viewModel: AlbumCollectionCellViewModel) {
        trackNameLabel.text = viewModel.name
        artistsNameLabel.text = viewModel.artistName
    }
    
}
