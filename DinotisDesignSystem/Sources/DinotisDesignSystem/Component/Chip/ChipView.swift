//
//  SwiftUIView.swift
//  
//
//  Created by Irham Naufal on 15/08/23.
//

import SwiftUI

public struct ChipModel: Identifiable {
    public let id = UUID()
    public var isSelected: Bool? = nil
    public var text: String
    public var action: (() -> Void)?
    
    public init(isSelected: Bool? = nil, text: String, action: ( () -> Void)? = nil) {
        self.isSelected = isSelected
        self.text = text
        self.action = action
    }
}

public struct ChipView: View {
    
    @Binding private var chip: ChipModel
    var withNumber: Bool = false
    
    public init(
        chip: Binding<ChipModel>,
        withNumber: Bool = false
    ) {
//        FontInjector.registerFonts()
        self._chip = chip
        self.withNumber = withNumber
    }
    
    public var body: some View {
        Button {
            withAnimation {
                guard chip.isSelected != nil else { return }
                chip.isSelected?.toggle()
            }
            (chip.action ?? {})()
            
        } label: {
            Text(withNumber ? chip.text.toDecimal() : chip.text)
                .font(.robotoBold(size: 12))
                .foregroundColor(
                    chip.isSelected.orFalse() ?
                        .DinotisDefault.white : .DinotisDefault.black1
                )
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(
                    chip.isSelected.orFalse() ?
                        Color.DinotisDefault.primary : Color.DinotisDefault.smokeWhite
                )
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .inset(by: -0.5)
                        .stroke(Color.DinotisDefault.black3, lineWidth: chip.isSelected.orFalse() ? 0 : 1)
                )
        }        
    }
}

struct DummyChipView: View {
    
    @State var chip: ChipModel = .init(isSelected: nil, text: "Suara Tidak Terdengar")
    
    var body: some View {
        ChipView(chip: $chip)
    }
}

struct ChipView_Previews: PreviewProvider {
    static var previews: some View {
        DummyChipView()
    }
}
