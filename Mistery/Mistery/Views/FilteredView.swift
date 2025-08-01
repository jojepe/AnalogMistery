//
//  FilteredView.swift
//  Mistery
//
//  Created by Joje on 01/08/25.
//


import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: - FilteredView (Corrigida e Refatorada)

struct FilteredView<Content: View>: View {
    @State private var context = CIContext()
    @State private var filter = CIFilter.bumpDistortion()

    let content: Content

    var body: some View {
        // TimelineView é perfeito para isso. Ele nos dá o tempo atual em cada frame.
        TimelineView(.animation) { timeline in
            // Tentamos renderizar a imagem com o tempo atual fornecido pelo timeline
            if let renderedImage = render(at: timeline.date) {
                Image(uiImage: renderedImage)
            } else {
                // Se a renderização falhar, mostramos o conteúdo original
                content
            }
        }
    }

    /// Função que aplica o filtro e retorna uma UIImage.
    /// Ela agora recebe o tempo atual como parâmetro.
    private func render(at date: Date) -> UIImage? {
        // ✅ CORREÇÃO 1: Corrigindo o erro 'no member ciImage'
        // Primeiro, criamos o renderer.
        let renderer = ImageRenderer(content: content)

        // Depois, pegamos a UIImage e SÓ ENTÃO criamos a CIImage a partir dela.
        guard let uiImage = renderer.uiImage,
              let sourceImage = CIImage(image: uiImage) else {
            return nil
        }

        // Agora podemos configurar o filtro com a sourceImage correta.
        filter.inputImage = sourceImage
        
        // Usamos o tempo fornecido pelo TimelineView para animar.
        // Multiplicar por 2 torna a animação um pouco mais rápida.
        let elapsedTime = date.timeIntervalSinceReferenceDate * 2.0

        // ✅ CORREÇÃO 2: Quebrando os cálculos complexos
        // Isso evita o erro 'unable to type-check'.
        let viewSize = sourceImage.extent.size
        let halfWidth = viewSize.width / 2.0
        let halfHeight = viewSize.height / 2.0
        let amplitude = viewSize.width / 3.5 // O quão longe o centro da distorção se move

        let distortionCenterX = halfWidth + cos(elapsedTime) * amplitude
        let distortionCenterY = halfHeight + sin(elapsedTime) * amplitude
        
        // Aplicamos os valores ao filtro
        filter.center = CGPoint(x: distortionCenterX, y: distortionCenterY)
        filter.radius = Float(viewSize.width / 3.0)
        filter.scale = 0.5

        // Geramos a imagem final
        guard let outputImage = filter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}

// MARK: - ContentView (Onde a Mágica Acontece)

struct ContentView: View {
    var body: some View {
        ZStack {
            // Você pode manter um fundo se quiser
            // Color.black.ignoresSafeArea()
            
            VStack {
                Text("Distorção com Core Image")
                    .font(.title)
                    .padding()
                
                // ✅ CORREÇÃO PRINCIPAL:
                // Passe a sua imagem como o `content` a ser distorcido.
                FilteredView(content:
                    Image("tvTestDist") // Certifique-se que o nome "tvTestDist" está no seu Asset Catalog
                        .resizable()
                        .scaledToFill() // Garante que a imagem preencha o frame
                )
                
            }
        }
    }
}



#Preview{
    ContentView()
}
