//
//  SearchResultDefaultTableViewCell.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 21/8/23.
//

import UIKit
import SDWebImage

class SearchResultDefaultTableViewCell: UITableViewCell {

    // MARK: - Properties
    static let identifier = "SearchResultDefaultTableViewCell"

    private lazy var aLabel: UILabel = {
        let aLabel = UILabel()
        aLabel.numberOfLines = 1
        return aLabel
    }()
    
    private let iconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    // MARK: - setupView
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(aLabel)
        contentView.addSubview(iconImage)
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = contentView.height-10
        iconImage.frame = CGRect(
            x: 10,
            y: 5,
            width: imageSize,
            height: imageSize
        )
        iconImage.layer.cornerRadius = imageSize/2
        iconImage.layer.masksToBounds = true
        aLabel.frame = CGRect(
            x: iconImage.right + 10,
            y: 0,
            width: contentView.width-iconImage.right-15,
            height: contentView.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        iconImage.image = nil
        aLabel.text = nil
    }
    
    // MARK: - configure
    func configure(with viewModel: SearchResultDefaultTableViewCellViewModel) {
        aLabel.text = viewModel.title
        iconImage.sd_setImage(with: viewModel.imageURL, completed: nil)
    }

}
