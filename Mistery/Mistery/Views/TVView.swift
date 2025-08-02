// TVView.swift (VERSÃO FINAL COM PROCESSAMENTO MANUAL DE FRAMES)

import UIKit
import AVFoundation

final class TVView: UIView {
    
    // --- Propriedades para Processamento Manual ---
    private var player: AVPlayer?
    private var videoOutput: AVPlayerItemVideoOutput?
    private var displayLink: CADisplayLink?
    private var ciContext = CIContext()
    
    private var textAnimationTimer: Timer?
        private var fullTextToAnimate: String = ""
        private var currentCharIndex: Int = 0
    
    var onNextButtonTap: () -> Void = {}

    // --- Subviews ---
    private(set) lazy var tvImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "tvFinal")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // A UIImageView que mostrará o vídeo distorcido
    private(set) lazy var processedFrameImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true // Garante que a imagem não saia dos limites
        return imageView
    }()
    
    private(set) lazy var storyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .red
        label.font = UIFont(name: "MeltedMonster", size: 30)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.text = ""
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
        
        setupManualFrameProcessing()
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateStoryText(with text: String) {
            textAnimationTimer?.invalidate()
            
            storyLabel.text = ""
            fullTextToAnimate = text
            currentCharIndex = 0
            
            textAnimationTimer = Timer.scheduledTimer(timeInterval: 0.12, target: self, selector: #selector(animateNextCharacter), userInfo: nil, repeats: true)
        }
        
        @objc private func animateNextCharacter() {
            guard currentCharIndex < fullTextToAnimate.count else {
                textAnimationTimer?.invalidate()
                return
            }
            
            let currentTextIndex = fullTextToAnimate.index(fullTextToAnimate.startIndex, offsetBy: currentCharIndex)
            let partialText = String(fullTextToAnimate[...currentTextIndex])
            
            storyLabel.text = partialText
            
            currentCharIndex += 1
        }
    
    @objc private func didPressNextButton() {
        onNextButtonTap()
    }

    // MARK: - Setup
    private func setupManualFrameProcessing() {
        guard let videoURL = Bundle.main.url(forResource: "static-video", withExtension: "mov") else {
            print("Erro: Vídeo não encontrado")
            return
        }
        
        // 1. Configurar a "saída de vídeo" para pegarmos os frames
        let pixelBufferAttributes = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: pixelBufferAttributes)
        
        let playerItem = AVPlayerItem(url: videoURL)
        playerItem.add(videoOutput!)
        
        player = AVPlayer(playerItem: playerItem)
        
        // Configurar o loop do vídeo
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: .main) { [weak self] _ in
            self?.player?.seek(to: .zero)
            self?.player?.play()
        }
        
        // 2. Configurar o DisplayLink para chamar a função de atualização a cada frame da tela
        displayLink = CADisplayLink(target: self, selector: #selector(updateFrame))
        displayLink?.add(to: .main, forMode: .common)
        
        player?.play()
    }
    
    // 3. Esta função é chamada a 60fps (ou mais)
    @objc private func updateFrame() {
        let currentTime = player?.currentItem?.currentTime() ?? .zero
        
        // 4. Verificamos se há um novo frame de vídeo disponível
        guard let videoOutput = videoOutput, videoOutput.hasNewPixelBuffer(forItemTime: currentTime),
              let pixelBuffer = videoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil) else {
            return
        }
        
        // 5. Criamos uma CIImage a partir do frame do vídeo
        let sourceImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        // 6. APLICAMOS O SEU FILTRO DE DISTORÇÃO
        guard let bumpFilter = CIFilter(name: "CIBumpDistortion") else { return }
        
        bumpFilter.setValue(sourceImage, forKey: kCIInputImageKey)
        
        let viewSize = sourceImage.extent.size
        let halfWidth = viewSize.width / 6.0
        let halfHeight = viewSize.height / 2.0
        let amplitude = viewSize.width / 3.0
        
        let distortionCenterX = halfWidth + 0.88 * amplitude
        let distortionCenterY = halfHeight + 0.05 * amplitude
        
        bumpFilter.setValue(CIVector(cgPoint: CGPoint(x: distortionCenterX, y: distortionCenterY)), forKey: kCIInputCenterKey)
        bumpFilter.setValue(Float(viewSize.width / 3.0), forKey: kCIInputRadiusKey)
        bumpFilter.setValue(1, forKey: kCIInputScaleKey)
        
        // 7. Renderizamos a imagem final com o filtro
        guard let outputImage = bumpFilter.outputImage,
              let cgImage = ciContext.createCGImage(outputImage, from: sourceImage.extent) else {
            return
        }
        
        // 8. Exibimos a imagem processada na nossa UIImageView
        self.processedFrameImageView.image = UIImage(cgImage: cgImage)
    }
    
    private func addSubviews() {
        addSubview(processedFrameImageView) // A view que mostra o vídeo processado
        addSubview(storyLabel)
        addSubview(tvImageView)           // A moldura da TV por cima
                    // O texto por cima de tudo
        addSubview(nextButton)              // O botão por cima de tudo
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Constraints para a UIImageView que exibe o vídeo, para que fique dentro da TV
            processedFrameImageView.centerXAnchor.constraint(equalTo: tvImageView.centerXAnchor),
            processedFrameImageView.centerYAnchor.constraint(equalTo: tvImageView.centerYAnchor),
            processedFrameImageView.widthAnchor.constraint(equalTo: tvImageView.widthAnchor, multiplier: 0.89),
            processedFrameImageView.heightAnchor.constraint(equalTo: tvImageView.heightAnchor, multiplier: 0.65),

            // O resto das constraints
            tvImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            tvImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            tvImageView.widthAnchor.constraint(equalTo: widthAnchor),
            
            storyLabel.centerXAnchor.constraint(equalTo: tvImageView.centerXAnchor, constant: -50),
            storyLabel.centerYAnchor.constraint(equalTo: tvImageView.centerYAnchor, constant: -25),
            storyLabel.widthAnchor.constraint(equalTo: tvImageView.widthAnchor, multiplier: 0.35),
            storyLabel.heightAnchor.constraint(equalTo: tvImageView.heightAnchor, multiplier: 0.42),
            
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
