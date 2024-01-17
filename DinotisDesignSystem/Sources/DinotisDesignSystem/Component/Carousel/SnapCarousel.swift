//
//  File.swift
//  
//
//  Created by Irham Naufal on 02/01/24.
//

import SwiftUI

public struct SnapCarousel<Content: View, T: Identifiable>: View {
    
    var content: (T) -> Content
    @Binding var list: [T]
    
    var spacing: CGFloat
    var trailingSpace: CGFloat
    @Binding var index: Int
    
    public init(spacing: CGFloat = 16, trailingSpace: CGFloat = 40, index: Binding<Int>, items: Binding<[T]>, @ViewBuilder content: @escaping (T)->Content) {
        
        self._list = items
        self.spacing = spacing
        self.trailingSpace = trailingSpace
        self._index = index
        self.content = content
    }
    
    @GestureState var offset: CGFloat = 0
    @State var currentIndex: Int = 0
    
    public var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width - ( trailingSpace - spacing )
            let adjustmentWidth = (trailingSpace / 2) - spacing
            
            HStack (spacing: spacing) {
                ForEach(list) { item in
                    content(item)
                        .frame(width: proxy.size.width - trailingSpace)
                }

            }
            .padding(.horizontal, spacing)
            .offset(x: (CGFloat(currentIndex) * -width) + ( currentIndex != 0 ? adjustmentWidth : 0 ) + offset)
            .gesture(
                DragGesture()
                    .updating($offset, body: { value, out, _ in
                        out = value.translation.width
                    })
                    .onEnded({ value in
                        let offsetX = value.translation.width
                        
                        let progress = -offsetX / width
                        let roundIndex = progress.rounded()
                    
                        currentIndex = max(min(currentIndex + Int(roundIndex), list.count - 1), 0)
                        currentIndex = index
                    })
                    .onChanged({ value in
                        let offsetX = value.translation.width
                        
                        let progress = -offsetX / width
                        let roundIndex = progress.rounded()
                    
                        index = max(min(currentIndex + Int(roundIndex), list.count - 1), 0)
                    
                    })
            )
            
        }
        .animation(.easeInOut, value: offset == 0)
        
    }
}

fileprivate struct DummyItem: Identifiable {
    var id: UUID = .init()
    var title: String = "This is Title"
    var desc: String = "This is Description"
}

fileprivate struct SnapCarouselPreview: View {
    
    @State var index = 0
    @State var items: [DummyItem] = [.init(), .init(), .init(), .init()]
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Test")
                SnapCarousel(spacing: 10, index: $index, items: $items) { item in
                    VStack(alignment: .leading) {
                        Text(item.title)
                            .font(.title3)
                        
                        Text(item.desc)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(.purple)
                    )
                }
                .frame(height: 100)
                Text("Test")
            }
        }
    }
}

#Preview(body: {
    SnapCarouselPreview()
})
