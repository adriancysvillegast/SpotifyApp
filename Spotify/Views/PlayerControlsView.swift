//
//  PlayerControlsView.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 23/8/23.
//

import Foundation
import UIKit

protocol PlayerControlsViewDelegate: AnyObject {
    func PlayerControlsViewDidtapPlayPauseButton(_ playerControlsView: PlayerControlsView)
    func PlayerControlsViewDidtapForwardButton(_ playerControlsView: PlayerControlsView)
    func PlayerControlsViewDidtapBackwardButton(_ playerControlsView: PlayerControlsView)
    func PlayerControlsView(_ playerControlsView: PlayerControlsView, didSlideSlider value: Float)
}



final class PlayerControlsView: UIView {
    
    
    // MARK: - Properties
    
    private var isPlaying = true
    weak var delegate: PlayerControlsViewDelegate?
    
    private lazy var slider: UISlider = {
       let slider = UISlider()
        slider.value = 0.5
        return slider
    }()
    
    private lazy var nameLabel: UILabel = {
       let aLabel = UILabel()
        aLabel.numberOfLines = 1
        aLabel.text = "THIS IS THE NAME"
        aLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        return aLabel
    }()
    
    private lazy var subtitleLabel: UILabel = {
       let aLabel = UILabel()
        aLabel.numberOfLines = 1
        aLabel.text = "HERE WILL BE THE ARTISTS"
        aLabel.font = .systemFont(ofSize: 18, weight: .regular)
        aLabel.textColor = .secondaryLabel
        return aLabel
    }()
    
    private lazy var backButton: UIButton = {
       let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "backward.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        button.setImage(image, for: .normal )
        return button
    }()
    
    private lazy var nextButton: UIButton = {
       let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "forward.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        button.setImage(image, for: .normal )
        return button
    }()
    
    private lazy var playPauseButton: UIButton = {
       let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        button.setImage(image, for: .normal )
        return button
    }()
    
    // MARK: - setupView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
         
        [nameLabel, subtitleLabel,slider, backButton, playPauseButton, nextButton].forEach { view in
            addSubview(view)
        }
        clipsToBounds = true
        backButton.addTarget(self, action: #selector(didtapBack), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didtapNext), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(didtapPlayPause), for: .touchUpInside)
        
        slider.addTarget(self, action: #selector(updateVolumen), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.frame = CGRect(x: 0, y: 0, width: width, height: 50)
        subtitleLabel.frame = CGRect(x: 0, y: nameLabel.botton+10, width: width, height: 50)
        
        slider.frame = CGRect(x: 10, y: subtitleLabel.botton+20 , width: width-20 , height: 44 )
        
        let buttonSize: CGFloat = 60
        playPauseButton.frame = CGRect(
            x: (width-buttonSize)/2,
            y: slider.botton+30,
            width: buttonSize,
            height: buttonSize
        )
        
        backButton.frame = CGRect(
            x: playPauseButton.left-80-buttonSize,
            y: playPauseButton.top,
            width: buttonSize,
            height: buttonSize
        )
        
        nextButton.frame = CGRect(
            x: playPauseButton.right+80,
            y: playPauseButton.top,
            width: buttonSize,
            height: buttonSize
        )
    }
    
    // MARK: - Methods
    
    @objc func didtapBack() {
        delegate?.PlayerControlsViewDidtapBackwardButton(self)
    }
    
    @objc func didtapNext() {
        delegate?.PlayerControlsViewDidtapForwardButton(self)
    }
    
    @objc func didtapPlayPause() {
        self.isPlaying = !isPlaying //change value tu false
         delegate?.PlayerControlsViewDidtapPlayPauseButton(self)
        
        //update image
        
        let pause = UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        let play = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        playPauseButton.setImage(isPlaying ? pause : play , for: .normal)
    }
    
    @objc func updateVolumen(with slider: UISlider) {
        let value = slider.value
        delegate?.PlayerControlsView(self, didSlideSlider: value)
    }
    
    // MARK: - configure
    
    func configure(with viewModel: PlayerControlsViewViewModel ) {
        nameLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
    }
}
