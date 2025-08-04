// TVView.swift (VERSÃO COM ARQUITETURA FINAL E ROBUSTA)

import UIKit
import AVFoundation

final class TVView: UIView {
    
    // --- Propriedades ---
    private var player: AVPlayer?
    private var videoOutput: AVPlayerItemVideoOutput?
    private var displayLink: CADisplayLink?
    private var ciContext = CIContext()
    private var playerStatusObserver: NSKeyValueObservation?
    
    var onNextButtonTap: () -> Void = {}

    // --- Subviews ---
    private(set) lazy var tvImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "tvFinal")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // ALTERADO: Uma view dedicada apenas para o vídeo distorcido.
    private(set) lazy var distortedVideoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // NOVO: Uma view dedicada apenas para o texto distorcido.
    private(set) lazy var distortedTextImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit // Fit para não cortar o texto
        return imageView
    }()
    
    // O label continua sendo nosso molde invisível.
    private(set) lazy var storyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = UIFont(name: "MeltedMonster", size: 30)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = 450 // Essencial para quebra de linha
        return label
    }()
    
    private(set) lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didPressNextButton), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        setupVideoProcessing()
        addSubviews()
        setupConstraints()
    }
    
    deinit {
        playerStatusObserver?.invalidate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // ALTERADO: Esta função agora faz o pipeline completo para o TEXTO.
    public func updateStoryText(with text: String) {
        // 1. Prepara o label
        storyLabel.text = text
        storyLabel.sizeToFit()
        
        guard let text = storyLabel.text, !text.isEmpty else {
            self.distortedTextImageView.image = nil
            return
        }
        
        // 2. Renderiza o label para uma UIImage
        let renderer = UIGraphicsImageRenderer(bounds: storyLabel.bounds)
        let textImage = renderer.image { _ in
            storyLabel.drawHierarchy(in: storyLabel.bounds, afterScreenUpdates: true)
        }
        
        // 3. Converte para CIImage
        guard let textCIImage = CIImage(image: textImage) else { return }
        
        // 4. Aplica o filtro de distorção APENAS no texto
        var finalImage: CIImage? = textCIImage
        if let bumpFilter = CIFilter(name: "CIBumpDistortion") {
            bumpFilter.setValue(textCIImage, forKey: kCIInputImageKey)
            let viewSize = textCIImage.extent.size
            bumpFilter.setValue(CIVector(x: viewSize.width * 0.5, y: viewSize.height * 0.5), forKey: kCIInputCenterKey)
            bumpFilter.setValue(viewSize.width * 0.8, forKey: kCIInputRadiusKey) // Raio maior para textos
            bumpFilter.setValue(0.5, forKey: kCIInputScaleKey)
            
            if let distorted = bumpFilter.outputImage {
                finalImage = distorted
            }
        }
        
        // 5. Exibe a imagem final do texto na sua própria UIImageView
        if let finalImage = finalImage, let cgImage = ciContext.createCGImage(finalImage, from: finalImage.extent) {
            self.distortedTextImageView.image = UIImage(cgImage: cgImage)
        }
    }
    
    @objc private func didPressNextButton() {
        onNextButtonTap()
    }

    // MARK: - Setup
    // setupVideoProcessing e setupDisplayLink permanecem iguais
    private func setupVideoProcessing() {
        guard let videoURL = Bundle.main.url(forResource: "static-video", withExtension: "mov") else { return }
        let playerItem = AVPlayerItem(url: videoURL)
        let pixelBufferAttributes = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: pixelBufferAttributes)
        playerItem.add(videoOutput!)
        player = AVPlayer(playerItem: playerItem)
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: .main) { [weak self] _ in
            self?.player?.seek(to: .zero)
            self?.player?.play()
        }
        playerStatusObserver = player?.currentItem?.observe(\.status, options: [.new]) { [weak self] item, change in
            guard let self = self else { return }
            if item.status == .readyToPlay {
                self.setupDisplayLink()
                self.player?.play()
            }
        }
    }
    
    private func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateFrame))
        displayLink?.add(to: .main, forMode: .common)
    }

    // ALTERADO: Esta função agora faz o pipeline completo APENAS para o VÍDEO.
    @objc private func updateFrame() {
        guard let player = player, let videoOutput = videoOutput else { return }
        let currentTime = player.currentItem?.currentTime() ?? .zero
        guard videoOutput.hasNewPixelBuffer(forItemTime: currentTime),
              let pixelBuffer = videoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil) else {
            return
        }
        
        let videoCIImage = CIImage(cvPixelBuffer: pixelBuffer)
        var finalImage: CIImage? = videoCIImage
        
        if let bumpFilter = CIFilter(name: "CIBumpDistortion") {
            bumpFilter.setValue(videoCIImage, forKey: kCIInputImageKey)
            let viewSize = videoCIImage.extent.size
            bumpFilter.setValue(CIVector(x: viewSize.width * 0.5, y: viewSize.height * 0.5), forKey: kCIInputCenterKey)
            bumpFilter.setValue(viewSize.width * 0.4, forKey: kCIInputRadiusKey)
            bumpFilter.setValue(0.5, forKey: kCIInputScaleKey)
            if let distorted = bumpFilter.outputImage {
                finalImage = distorted
            }
        }
        
        if let finalImage = finalImage, let cgImage = ciContext.createCGImage(finalImage, from: finalImage.extent) {
            self.distortedVideoImageView.image = UIImage(cgImage: cgImage)
        }
    }
    
    private func addSubviews() {
        // A ordem de adição define a sobreposição (Z-index)
        addSubview(distortedVideoImageView) // Fundo
        addSubview(distortedTextImageView)  // Meio
        addSubview(tvImageView)              // Frente (moldura)
        addSubview(nextButton)               // Botão por cima de tudo
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Constraints para a view do VÍDEO
            distortedVideoImageView.centerXAnchor.constraint(equalTo: tvImageView.centerXAnchor),
            distortedVideoImageView.centerYAnchor.constraint(equalTo: tvImageView.centerYAnchor),
            distortedVideoImageView.widthAnchor.constraint(equalTo: tvImageView.widthAnchor, multiplier: 0.89),
            distortedVideoImageView.heightAnchor.constraint(equalTo: tvImageView.heightAnchor, multiplier: 0.65),
            
            // Constraints para a view do TEXTO (as que você forneceu!)
            distortedTextImageView.centerXAnchor.constraint(equalTo: tvImageView.centerXAnchor, constant: -50),
            distortedTextImageView.centerYAnchor.constraint(equalTo: tvImageView.centerYAnchor, constant: -25),
            distortedTextImageView.widthAnchor.constraint(equalTo: tvImageView.widthAnchor, multiplier: 0.35),
            distortedTextImageView.heightAnchor.constraint(equalTo: tvImageView.heightAnchor, multiplier: 0.42),

            // Constraints para a MOLDURA da TV
            tvImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            tvImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            tvImageView.widthAnchor.constraint(equalTo: widthAnchor),
            
            // Constraints para o BOTÃO
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

