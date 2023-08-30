//
//  ActionLabelView.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 27/8/23.
//

import UIKit

protocol ActionLabelViewDelegate: AnyObject {
    func actionLabeldidTapButton(_ actionView: ActionLabelView)
}

class ActionLabelView: UIView {

    // MARK: - Properties
    
    weak var delegate: ActionLabelViewDelegate?
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.setTitleColor(.link, for: .normal)
        return button
    }()
    
    // MARK: - SetupView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        isHidden = true
        [label, button].forEach { addSubview($0) }
        
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button.frame = CGRect(x: 0, y: height-40, width: width, height: 40)
        label.frame = CGRect(x: 0, y: 0, width: width, height: height-45)
    }
    
    // MARK: - Methods
    
    @objc func didTapButton() {
        delegate?.actionLabeldidTapButton(self)
    }
    
    func configure(with viewModel: ActionLabelViewViewModel) {
        label.text = viewModel.text
        button.setTitle(viewModel.actionTitle, for: .normal)
    }
}
