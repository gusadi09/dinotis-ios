//
//  SwiftUIView.swift
//  
//
//  Created by Irham Naufal on 15/08/23.
//

import SwiftUI

public struct ChipContainerView: View {
    
    @State var chips: [ChipModel]
    
    @State private var containerHeight: CGFloat = 0
    
    public init(chips: [ChipModel]) {
        self.chips = chips
    }
    
    public var body: some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        return GeometryReader { geo in
            ZStack(alignment: .topLeading, content: {
                ForEach($chips, id: \.id) { data in
                    ChipView(chip: data)
                        .padding(.all, 5)
                        .alignmentGuide(.leading) { dimension in
                            if (abs(width - dimension.width) > geo.size.width) {
                                width = 0
                                height -= dimension.height
                            }
                            let result = width
                            if data.id == chips.last!.id {
                                width = 0
                            } else {
                                width -= dimension.width
                            }
                            return result
                        }
                        .alignmentGuide(.top) { dimension in
                            let result = height
                            if data.id == chips.last!.id {
                                height = 0
                            }
                            return result
                        }
                }
            })
        }
    }
}

struct ChipContainerView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack {
                ChipContainerView(
                    chips: [
                        .init(isSelected: false, text: "Tidak Ada Suara"),
                        .init(isSelected: false, text: "Video Tidak Terlihat"),
                        .init(isSelected: false, text: "Suara Putus-Putus"),
                        .init(isSelected: false, text: "Kualitas Video Buram"),
                        .init(isSelected: false, text: "Kuota Boros"),
                        .init(isSelected: false, text: "Hape menjadi panas"),
                        .init(isSelected: false, text: "Kamera & mic tidak menyala")
                    ]
                )
                
                Text("bangsss")
            }
            Text("Asu")
        }
    }
}
