//
//  FilteredView.swift
//  Mistery
//
//  Created by Joje on 01/08/25.
//


import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: - FilteredView

struct FilteredView<Content: View>: View {
    @State private var context = CIContext()
    @State private var filter = CIFilter.bumpDistortion()

    let content: Content

    var body: some View {
        TimelineView(.animation) { timeline in
            if let renderedImage = render(at: timeline.date) {
                Image(uiImage: renderedImage)
            } else {
                content
            }
        }
    }


    private func render(at date: Date) -> UIImage? {
        
        let renderer = ImageRenderer(content: content)

        guard let uiImage = renderer.uiImage,
              let sourceImage = CIImage(image: uiImage) else {
            return nil
        }

        filter.inputImage = sourceImage
        

        let viewSize = sourceImage.extent.size
        let halfWidth = viewSize.width / 6.0
        let halfHeight = viewSize.height / 2.0
        let amplitude = viewSize.width / 3 // O quão longe o centro da distorção se move
        
        let distortionCenterX = halfWidth + 0.74 * amplitude
        let distortionCenterY = halfHeight + 0 * amplitude
        
        // valores do filtro
        filter.center = CGPoint(x: distortionCenterX, y: distortionCenterY)
        filter.radius = Float(viewSize.width / 3.0)
        filter.scale = 0.1

        // imagem final
        guard let outputImage = filter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}

// MARK: - ContentView

struct ContentView: View {
    var body: some View {
        ZStack {
            
            
            VStack {
                Text("Distorção com Core Image")
                    .font(.title)
                    .padding()
                
               
                FilteredView(content:
                    Image("tvTestDist")
                        .resizable()
                        .scaledToFill() 
                )
                
            }
        }
    }
}



#Preview{
    ContentView()
}
