//
//  SwiftUIView.swift
//  
//
//  Created by Irham Naufal on 07/11/23.
//

import SwiftUI

public struct ShinyModifier: ViewModifier {
    
    @State private var show: Bool = false
    private var color: Color = .white.opacity(0.3)
    private var speed: Double
    private var delay: Double
    
    public init(color: Color = .white.opacity(0.3), speed: Double = 4, delay: Double = 3) {
        self.color = color
        self.speed = speed
        self.delay = delay
    }
    
    public func body(content: Content) -> some View {
        content
            .overlay {
                Capsule()
                    .fill(LinearGradient(colors: [.clear, color, .clear], startPoint: .top, endPoint: .bottom))
                    .frame(height: 80)
                    .rotationEffect(.degrees(80))
                    .offset(x: show ? 500 : -500)
                    .mask(content)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: speed).delay(delay).repeatForever(autoreverses: false)) {
                    self.show.toggle()
                }
            }
    }
}

public extension View {
    func shineEffect(color: Color = .white.opacity(0.3), speed: Double = 5, delay: Double = 3) -> some View {
        return modifier(ShinyModifier(color: color, speed: speed, delay: delay))
    }
}

fileprivate struct ShinyPreview: View {
    var body: some View {
        
        ZStack {
//            Color.black.ignoresSafeArea()
            
            VStack {
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                    .shineEffect(color: .white.opacity(0.7), speed: 5, delay: 1)
                
                HStack {
                    DinotisPrimaryButton(text: "Testing", type: .adaptiveScreen, textColor: .white, bgColor: .DinotisDefault.primary, {})
                        .shineEffect()
                    
                    DinotisPrimaryButton(text: "Testing", type: .adaptiveScreen, textColor: .DinotisDefault.black1, bgColor: .DinotisDefault.black3.opacity(0.5), {})
                }
            }
            .padding()
        }
    }
}

#Preview {
    ShinyPreview()
}
