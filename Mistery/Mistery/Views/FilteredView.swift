// FilteredView.swift (VERSÃO CORRIGIDA)

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct FilteredView<Content: View>: View {
    @State private var context = CIContext()
    @State private var filter = CIFilter.bumpDistortion()

    let content: Content

    var body: some View {
        GeometryReader { geometry in
            // Usar .drawingGroup() pode melhorar a performance da renderização
            let viewToRender = content
                .frame(width: geometry.size.width, height: geometry.size.height)
                .drawingGroup()
            
            if let image = render(content: viewToRender) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                // Mostra o conteúdo original se a renderização falhar
                content
            }
        }
    }

    private func render(content: some View) -> UIImage? {
        let renderer = ImageRenderer(content: content)

        // ✅ A CORREÇÃO ESTÁ AQUI:
        // Primeiro, pegamos a UIImage.
        guard let uiImage = renderer.uiImage,
              // DEPOIS, criamos a CIImage a partir da UIImage.
              let sourceImage = CIImage(image: uiImage) else {
            return nil
        }

        filter.inputImage = sourceImage
        
        let viewSize = sourceImage.extent.size
        let halfWidth = viewSize.width / 6.0
        let halfHeight = viewSize.height / 2.0
        let amplitude = viewSize.width / 3.0
        
        let distortionCenterX = halfWidth + 0.74 * amplitude
        let distortionCenterY = halfHeight
        
        filter.center = CGPoint(x: distortionCenterX, y: distortionCenterY)
        filter.radius = Float(viewSize.width / 3.0)
        filter.scale = 1

        guard let outputImage = filter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}

#Preview {
    ViewController()
}
