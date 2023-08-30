//
//  TitleHeaderCollectionReusableView.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 13/8/23.
//

import UIKit

class TitleHeaderCollectionReusableView: UICollectionReusableView {
    
    // MARK: - properties
    
    static let identifier = "TitleHeaderCollectionReusableView"
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 22, weight: .regular)
        
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        
        addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - SetupView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(x: 15, y: 0, width: width-30, height: height)
    }
    
    // MARK: - Methods
    
    func configure(with title: String) {
        titleLabel.text = title
    }
    
}
