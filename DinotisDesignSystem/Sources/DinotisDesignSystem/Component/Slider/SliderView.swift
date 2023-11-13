//
//  SwiftUIView.swift
//  
//
//  Created by Gus Adi on 19/10/23.
//

import SwiftUI

public struct SliderView: View {
    
    @Binding public var value: Double
    @Binding public var label: String
    
    public var range: ClosedRange<Double> = 0...1
    
    @State private var pinSize: CGFloat = 38
    @State private var isDragging = false
    
    public init(
        value: Binding<Double>,
        label: Binding<String>,
        range: ClosedRange<Double> = 0...1
    ) {
        self._value = value
        self._label = label
        self.range = range
    }
    
    public var body: some View {
        GeometryReader { geo in
            
            let width = geo.size.width - pinSize
            let scale = width / CGFloat(range.upperBound)
            let sliderValue = CGFloat(value) * scale
            
            HStack {
                Capsule()
                    .foregroundColor(.white)
                    .frame(height: 4)
            }
            .padding(.horizontal)
            .frame(height: 48)
            .overlay(alignment: .leading) {
                Text("\(label)%")
                    .foregroundColor(.DinotisDefault.primary)
                    .font(.robotoRegular(size: 12))
                    .fontWeight(.semibold)
                    .frame(width: pinSize, height: pinSize)
                    .background(
                        Circle()
                            .foregroundColor(.white)
                    )
                    .overlay {
                        Circle()
                            .inset(by: 1)
                            .stroke(Color.DinotisDefault.primary, lineWidth: 3)
                    }
                    .offset(x: sliderValue, y: 0)
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                withAnimation(.spring(response: 0.2)) {
                                    let dragValue = max(0, min(value.location.x, width))
                                    let stepSize = scale
                                    let step = Double((dragValue + 0.0 * stepSize) / stepSize) + range.lowerBound
                                    self.value = min(max(step, range.lowerBound), range.upperBound)
                                    
                                    self.label = "\(Int(self.value * 100))"
                                    isDragging = true
                                }
                            })
                            .onEnded { value in
                                withAnimation(.spring(response: 0.2)) {
                                    let dragValue = max(0, min(value.location.x, width))
                                    let stepSize = scale
                                    let step = Double((dragValue + 0.0 * stepSize) / stepSize) + range.lowerBound
                                    self.value = min(max(step, range.lowerBound), range.upperBound)
                                    self.label = "\(Int(self.value * 100))"
                                    isDragging = false
                                }
                            }
                    )
            }
            .onChange(of: value) { _ in
                addHaptic()
            }
        }
        .padding(.horizontal, 5)
        .frame(height: 48)
        .background(
            Color.DinotisDefault.primary
                .clipShape(.capsule)
        )
    }
    
    private func addHaptic() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
