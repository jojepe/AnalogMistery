//
//  TVView.swift
//  Mistery
//
//  Created by Joje on 31/07/25.
//

import UIKit
import AVFoundation
import SwiftUI

final class TVView: UIView {
    
    // propriedades animacao texto
    private var textAnimationTimer: Timer?
    private var fullTextToAnimate: String = ""
    private var currentCharIndex: Int = 0
    
    // propriedades video estatica
    private let player: AVQueuePlayer
    private let viewModel = TVContentViewModel()
    
    var onNextButtonTap: () -> Void = {}
    
    // hosting controller
    private var distortionHostingController: UIHostingController<FilteredView<Image>>?
    // MARK: - Subviews
    
    // imagem da TV
    private(set) lazy var tvImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.image = UIImage(named: "tvFinal")
        imageView.contentMode = .scaleAspectFit
        
        return imageView
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
        
        guard let videoURL = Bundle.main.url(forResource: "static-video", withExtension: "mov") else {
            fatalError("Erro: Não foi possível encontrar o arquivo de vídeo static-video.mov")
        }
        let playerItem = AVPlayerItem(url: videoURL)
        self.player = AVQueuePlayer(playerItem: playerItem)
        
        super.init(frame: frame)
        
        let playerLooper = AVPlayerLooper(player: self.player, templateItem: playerItem)
        _ = playerLooper
        
        backgroundColor = .black
        
        setupHostingController()
        addSubviews()
        setupConstraints()
        
        self.player.play()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Button actions
    
    @objc private func didPressNextButton() {
        onNextButtonTap()
    }
    
    @objc private func animateNextCharacter() {
        
        guard currentCharIndex < fullTextToAnimate.count else {
            textAnimationTimer?.invalidate()
            return
        }
        
        let currentTextIndex = fullTextToAnimate.index(fullTextToAnimate.startIndex, offsetBy: currentCharIndex)
        viewModel.displayText = String(fullTextToAnimate[...currentTextIndex])
        
        currentCharIndex += 1
    }
    
    public func updateStoryText(with text: String) {
        textAnimationTimer?.invalidate()
        
        viewModel.displayText = ""
        fullTextToAnimate = text
        currentCharIndex = 0
        
        textAnimationTimer = Timer.scheduledTimer(timeInterval: 0.12, target: self, selector: #selector(animateNextCharacter), userInfo: nil, repeats: true)
    }
    
    
    // MARK: - Setup methods
    
    private func setupHostingController() {
        
        let combinedView = CombinedContentView(player: self.player, viewModel: self.viewModel)
        
        // 2. Passamos a view combinada para a FilteredView, que aplicará a distorção
        let filteredContent = FilteredView(content: combinedView)
        
        // 3. Hospedamos tudo em um UIHostingController
        let hostingController = UIHostingController(rootView: filteredContent)
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Adicionamos a view do controller como filha
        self.addSubview(hostingController.view)
        
        // Adicionamos as constraints para posicionar a tela distorcida
        NSLayoutConstraint.activate([
            hostingController.view.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: -50),
            hostingController.view.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -25),
            hostingController.view.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.35),
            hostingController.view.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.42)
        ])
    }
    
    private func addSubviews() {
        
        self.addSubview(tvImageView)
        self.addSubview(nextButton)
        
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            
            // TV Image
            tvImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            tvImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            tvImageView.widthAnchor.constraint(equalTo: widthAnchor),
            
            
            
            //TV Button
            nextButton.topAnchor.constraint(equalTo: tvImageView.centerYAnchor, constant: -25),
            nextButton.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 190),
            nextButton.widthAnchor.constraint(equalToConstant: 100),
            nextButton.heightAnchor.constraint(equalToConstant: 160)
            
            
        ])
    }
}

// video estatica
struct VideoPlayerUIView: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> UIView{
        let view = UIView()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = view.bounds
        view.layer.addSublayer(playerLayer)
        
        //        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //        playerLayer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Nenhuma atualização necessária aqui por enquanto
    }
}

// texto que passa dentro da TV
struct LabelUIView: UIViewRepresentable {
    @ObservedObject var viewModel: TVContentViewModel
    
    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.textColor = .red
        label.font = UIFont(name: "MeltedMonster", size: 30)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        // Atualiza o texto do UILabel sempre que o viewModel mudar
        uiView.text = viewModel.displayText
    }
}

struct CombinedContentView: View {
    let player: AVPlayer
    @ObservedObject var viewModel: TVContentViewModel
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Camada de vídeo no fundo
            VideoPlayerUIView(player: player)
            
            // Camada de texto na frente
            // O padding ajusta a posição para simular suas constraints originais
            LabelUIView(viewModel: viewModel)
                .padding(.leading, 20)
                .padding(.top, 15)
        }
    }
}

#Preview{
    ViewController()
}
