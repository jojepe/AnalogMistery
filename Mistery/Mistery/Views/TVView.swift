//
//  TVView.swift
//  Mistery
//
//  Created by Joje on 31/07/25.
//

import UIKit
import AVFoundation


final class TVView: UIView {
    
    private var player: AVQueuePlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerLooper: AVPlayerLooper?
    
    var onNextButtonTap: () -> Void = {}
    
    // MARK: - Subviews
    
    // imagem da TV
    private(set) lazy var tvImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.image = UIImage(named: "tvFinal")
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    // texto que passa dentro da TV
    private(set) lazy var storyLabel: UILabel = {
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.textColor = .red
        label.font = UIFont(name: "Courier", size: 36)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Olha minha TV"
        
        return label
        
    }()
    
    private(set) lazy var nextButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        //button.backgroundColor = .darkGray
        
        button.addTarget(self, action: #selector(didPressNextButton), for: .touchUpInside)
        
        return button
        
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .black
        
        setupVideoPlayer()
        
        addSubviews()
        setupConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        playerLayer?.frame = tvImageView.frame.insetBy(dx: tvImageView.frame.width * 0.05, dy: tvImageView.frame.height * 0.18)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Button actions
    
    @objc private func didPressNextButton() {
        onNextButtonTap()
    }
    
    
    // MARK: - Setup methods
    
    private func setupVideoPlayer() {
        
        guard let videoURL = Bundle.main.url(forResource: "static-video", withExtension: "mov") else {
            print("Erro: Não foi possível encontrar o arquivo de vídeo static-video.mov")
            return
        }
        let playerItem = AVPlayerItem(url: videoURL)
        
        player = AVQueuePlayer(playerItem: playerItem)
        // LINHA COM POSSIVEL ERRO
        playerLooper = AVPlayerLooper(player: player!, templateItem: playerItem)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
    
        if let layer = playerLayer {
            self.layer.addSublayer(layer)
        }
        
        player?.play()
    }
    
    private func addSubviews() {
        
        self.addSubview(tvImageView)
        self.addSubview(storyLabel)
        self.addSubview(nextButton)
        
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            
            // TV Image
            tvImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            tvImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            tvImageView.widthAnchor.constraint(equalTo: widthAnchor),
            
            // TV Text
            storyLabel.centerXAnchor.constraint(equalTo: tvImageView.centerXAnchor, constant: -50),
            storyLabel.centerYAnchor.constraint(equalTo: tvImageView.centerYAnchor, constant: -20),
            storyLabel.widthAnchor.constraint(equalTo: tvImageView.widthAnchor, constant: -100),
            storyLabel.heightAnchor.constraint(equalToConstant: 200),
            
            //TV Button
            nextButton.topAnchor.constraint(equalTo: tvImageView.centerYAnchor, constant: -25),
            nextButton.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 190),
            nextButton.widthAnchor.constraint(equalToConstant: 100),
            nextButton.heightAnchor.constraint(equalToConstant: 160)
            
            
        ])
    }
}

#Preview{
    ViewController()
}
