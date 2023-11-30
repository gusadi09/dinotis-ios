//
//  SwiftUIView.swift
//  
//
//  Created by Irham Naufal on 08/11/23.
//

import SwiftUI

public struct SubscribeCard: View {
    
    private let price: String
    private let colors: [String]
    private let withButton: Bool
    private let action: (() -> Void)?
    
    public init(
        price: String,
        colors: [String] = ["810DF7", "02A9CD"],
        withButton: Bool,
        action: (() -> Void)?
    ) {
        self.price = price
        self.colors = colors
        self.withButton = withButton
        self.action = action
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text(LocalizableText.subscirbeCardTitle)
                    .font(.robotoBold(size: 18))
                
                Text(LocalizableText.subscirbeCardDesc)
                    .font(.robotoRegular(size: 14))
            }
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            
            HStack(alignment: .top, spacing: 8) {
                Image.talentProfileBalanceWhiteIcon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 19)
                    .padding(.vertical, 4)
                
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(price.isEmpty || price == "0" ? LocalizableText.freeText : price.toDecimal())
                            .font(.robotoBold(size: 18))
                        
                        Text(LocalizableText.adaptiveSubscribtionLabel)
                            .font(.robotoRegular(size: 10))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if withButton {
                        DinotisCapsuleButton(
                            text: LocalizableText.subscribeNowLabel,
                            textColor: .DinotisDefault.primary,
                            bgColor: .white)
                        {
                            (action ?? {})()
                        }
                    } else {
                        Text(LocalizableText.forOneMonthLabel.uppercased())
                            .font(.robotoRegular(size: 12))
                    }
                }
                .foregroundColor(.white)
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [.white.opacity(0.1), .white.opacity(0.2), .white.opacity(0.1)],
                    startPoint: .bottomLeading,
                    endPoint: .topTrailing
                )
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .inset(by: 0.5)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.1), .white.opacity(0.3), .white.opacity(0.5), .white.opacity(0.7), .white.opacity(0.3), .white.opacity(0.1)],
                            startPoint: .bottomLeading,
                            endPoint: .topTrailing
                        ), lineWidth: 1
                    )
                
            )
            .shineEffect(color: .white.opacity(0.8))
            
            Text(LocalizableText.subscirbeCancelDesc)
                .font(.robotoRegular(size: 10))
                .foregroundColor(.white)
                .isHidden(true, remove: true)
//                .isHidden(withButton, remove: true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(LinearGradient(colors: [(.init(hex: colors[0]) ?? .DinotisDefault.linearOrangeLeft), (.init(hex: colors[1]) ?? .DinotisDefault.linearOrangeRight)], startPoint: .bottomLeading, endPoint: .bottomTrailing))
        .cornerRadius(12)
    }
}

#Preview {
    SubscribeCard(price: "170000", withButton: false) {
        
    }
    .padding()
}
