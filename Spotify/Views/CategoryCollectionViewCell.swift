//
//  CategoryCollectionViewCell.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 17/8/23.
//

import UIKit
import SDWebImage

class CategoryCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "CategoryCollectionViewCell"
    
    private lazy var aImageView: UIImageView = {
       let aImageView = UIImageView()
        aImageView.tintColor = .white
        aImageView.contentMode = .scaleAspectFill
        aImageView.image = UIImage(systemName: "music.quarternote.3",
                                   withConfiguration:
                                    UIImage.SymbolConfiguration(
                                        pointSize: 50,
                                        weight: .regular )
        )
        return aImageView
    }()
    
    private lazy var color : [UIColor] = [
        .systemPink,
        .systemRed,
        .systemBlue,
        .systemCyan,
        .systemMint,
        .systemIndigo,
        .systemPurple
    ]
    
    private lazy var aLabel: UILabel = {
        let aLabel = UILabel()
        aLabel.textColor = .white
        aLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        return aLabel
    }()
    // MARK: - setupView
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(aImageView)
        contentView.addSubview(aLabel)
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        aLabel.text = nil
        aImageView.image = UIImage(systemName: "music.quarternote.3",
                                   withConfiguration:
                                    UIImage.SymbolConfiguration(
                                        pointSize: 50,
                                        weight: .regular )
        )
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        aLabel.frame =  CGRect(x: 10,
                               y: contentView.height/2,
                               width: contentView.width-20,
                               height: contentView.height/2)
        
        aImageView.frame = contentView.bounds
    }
    
    
    // MARK: - Configure
    func configure(with model: CategoryCollectionViewCellViewModel) {
        aLabel.text = model.name
        aImageView.sd_setImage(with: model.artworkURL, completed: nil)
        contentView.backgroundColor = color.randomElement()
    }
}
