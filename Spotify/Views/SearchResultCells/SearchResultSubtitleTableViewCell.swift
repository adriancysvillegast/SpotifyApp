//
//  SearchResultSubtitleTableViewCell.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 22/8/23.
//
import UIKit
import SDWebImage

class SearchResultSubtitleTableViewCell: UITableViewCell {

    // MARK: - Properties
    static let identifier = "SearchResultSubtitleTableViewCell"

    private lazy var aLabel: UILabel = {
        let aLabel = UILabel()
        aLabel.numberOfLines = 1
        return aLabel
    }()
    
    private lazy var aSublabel: UILabel = {
        let aLabel = UILabel()
        aLabel.textColor = .secondaryLabel
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
        contentView.addSubview(aSublabel)
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
        
        let labelHeight = contentView.height/2
        
        aLabel.frame = CGRect(
            x: iconImage.right + 10,
            y: 0,
            width: contentView.width-iconImage.right-15,
            height: labelHeight
        )
        
        aSublabel.frame = CGRect(
            x: iconImage.right + 10,
            y: aLabel.botton,
            width: contentView.width-iconImage.right-15,
            height: labelHeight
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        iconImage.image = nil
        aLabel.text = nil
        aSublabel.text = nil
    }
    
    // MARK: - configure
    func configure(with viewModel: SearchResultSubtitleTableViewCellViewModel) {
        aLabel.text = viewModel.title
        aSublabel.text = viewModel.subtitle
        iconImage.sd_setImage(with: viewModel.imageURL,
                              placeholderImage: UIImage(systemName: "photo") ,
                              completed: nil
        )
    }

}
