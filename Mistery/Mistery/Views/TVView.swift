//
//  TVView.swift
//  Mistery
//
//  Created by Joje on 31/07/25.
//

import UIKit


final class TVView: UIView {
    
    private var story = StoryModel()
    
    private var currentTextIndex = 0
    
    var onNextButtonTap: () -> Void = {}
    
    // MARK: - Subviews
    
    // imagem da TV
    private(set) lazy var tvImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.image = UIImage(named: "tvTest")
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    // texto que passa dentro da TV
    private(set) lazy var storyLabel: UILabel = {
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.textColor = .red
        label.font = UIFont(name: "Courier", size: 20)
        label.textAlignment = .center
        label.numberOfLines = 3
        label.text = "Olha minha TV"
        
        return label
        
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .black
        
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Button actions
    
    @objc private func didPressButtonDown() {
        onNextButtonTap()
    }
    
    @objc private func didPressButtonUpInside() {
        print("Soltado!!!!")
    }
    
    // MARK: - Setup methods
    private func addSubviews() {
        self.addSubview(tvImageView)
    }
    
    private func setupConstraints() {
        //        tvImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        //        tvImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        //        tvImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.57).isActive = true
        
        NSLayoutConstraint.activate([
            
            // TV Image
            tvImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            tvImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
            tvImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.57),
            
            // TV Text
            storyLabel.centerXAnchor.constraint(equalTo: tvImageView.centerXAnchor)
        ])
    }
}

#Preview{
    ViewController()
}
