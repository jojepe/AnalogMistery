// TVView.swift (VERSÃO COM VÍDEO E DISTORÇÃO)

import UIKit
import SwiftUI
import AVFoundation

final class TVView: UIView {
    
    // --- Controles ---
    // Recriamos o player que será passado para o SwiftUI
    private let player: AVQueuePlayer
    private var playerLooper: AVPlayerLooper?
    
    var onNextButtonTap: () -> Void = {}
    
    // --- Subviews do UIKit ---
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
        button.addTarget(self, action: #selector(didPressNextButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        // Inicializamos o player
        guard let videoURL = Bundle.main.url(forResource: "static-video", withExtension: "mov") else {
            fatalError("Erro fatal: Vídeo static-video.mov não encontrado.")
        }
        let playerItem = AVPlayerItem(url: videoURL)
        self.player = AVQueuePlayer(playerItem: playerItem)
        
        super.init(frame: frame)
        
        // O looper precisa ser uma propriedade da classe para se manter vivo
        self.playerLooper = AVPlayerLooper(player: self.player, templateItem: playerItem)

        backgroundColor = .black
        
        setupSwiftUIView() // Renomeamos a função de setup
        
        addSubview(tvImageView)
        addSubview(nextButton)
        setupConstraints()
        
        self.player.play()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didPressNextButton() {
        onNextButtonTap()
    }
    
    // MARK: - Setup
    
    private func setupSwiftUIView() {
        // 1. CRIAMOS O CONTEÚDO: a nossa ponte para o player de vídeo
        let videoContentView = VideoPlayerUIView(player: self.player)
        
        // 2. PASSAMOS A VIEW DE VÍDEO PARA A FILTEREDVIEW
        let filteredVideoView = FilteredView(content: videoContentView)
        
        // 3. HOSPEDAMOS TUDO
        let hostingController = UIHostingController(rootView: filteredVideoView)
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // 4. ADICIONAMOS À VIEW E POSICIONAMOS
        addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: -50),
            hostingController.view.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -25),
            hostingController.view.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.35),
            hostingController.view.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.42)
        ])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tvImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            tvImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            tvImageView.widthAnchor.constraint(equalTo: widthAnchor),
            
            nextButton.topAnchor.constraint(equalTo: tvImageView.centerYAnchor, constant: -25),
            nextButton.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 190),
            nextButton.widthAnchor.constraint(equalToConstant: 100),
            nextButton.heightAnchor.constraint(equalToConstant: 160)
        ])
    }
}

// ===================================================================
// MARK: - PONTES PARA O SWIFTUI (COLOQUE NO FINAL DO ARQUIVO)
// ===================================================================

/// Ponte para exibir o AVPlayer no SwiftUI
struct VideoPlayerUIView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerUIView {
        return PlayerUIView(player: player)
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {}
}

/// Uma UIView customizada que hospeda corretamente uma AVPlayerLayer
class PlayerUIView: UIView {
    // ... e substitua todo o seu conteúdo por este:

    // 1. Dizemos ao UIKit que a camada principal desta view é uma AVPlayerLayer.
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    // 2. Criamos uma propriedade para acessar a layer com o tipo correto.
    var playerLayer: AVPlayerLayer {
        return self.layer as! AVPlayerLayer
    }
    
    // 3. O inicializador fica mais simples.
    init(player: AVPlayer) {
        super.init(frame: .zero)
        
        // Apenas definimos o player e a gravidade do vídeo.
        // Não precisamos adicionar sublayer nem nos preocupar com o frame.
        self.playerLayer.player = player
        self.playerLayer.videoGravity = .resizeAspectFill
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Não precisamos mais do 'layoutSubviews' aqui, pois o UIKit
    // gerencia o tamanho da camada principal da view automaticamente.
}

#Preview {
    ViewController()
}
