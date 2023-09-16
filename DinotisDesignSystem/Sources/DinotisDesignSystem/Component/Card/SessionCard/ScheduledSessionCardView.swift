//
//  SwiftUIView.swift
//  
//
//  Created by Irham Naufal on 06/02/23.
//

import SwiftUI

public struct ScheduledSessionCardView: View {
    
    private var data: SessionCardModel
    private var buttonLabel: String
    private let action: () -> Void
    private let visitProfile: () -> Void
    private let color: Color
    
    public init(
        data: SessionCardModel,
        buttonLabel: String,
        color: Color = .DinotisDefault.primary,
        _ action: @escaping () -> Void,
        visitProfile: @escaping () -> Void
    ) {
        self.data = data
        self.buttonLabel = buttonLabel
        self.color = color
        self.action = action
        self.visitProfile = visitProfile
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image.sessionCardPricetagIcon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24)
                
                VStack(alignment: .leading) {
                    Text(data.invoiceId)
                        .font(.robotoBold(size: 10))
                        .foregroundColor(.DinotisDefault.black2)
                    
                    Text(data.date)
                        .font(.robotoRegular(size: 10))
                        .foregroundColor(.DinotisDefault.black2)
                }
                
                Spacer()
                
                Text(data.status)
                    .font(.robotoMedium(size: 10))
                    .foregroundColor(color)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(color.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(color, lineWidth: 1)
                    )
            }
            
            Rectangle()
                .foregroundColor(.DinotisDefault.lightPrimary)
                .frame(height: 1)
            
            HStack(spacing: 14) {
                ZStack(alignment: .topTrailing) {
                    DinotisImageLoader(
                        urlString: data.photo
                    )
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
                    .onTapGesture {
                        visitProfile()
                    }
                    
                    if data.type == .bundling {
                        Text("\(data.session)")
                            .font(.robotoBold(size: 10))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.DinotisDefault.secondary.opacity(0.7))
                            .overlay(
                                Circle()
                                    .stroke(.white, lineWidth: 4)
                            )
                            .clipShape(Circle())
                            .padding(-8)
                    }
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(data.name)
                            .font(.robotoMedium(size: 10))
                            .foregroundColor(.DinotisDefault.black3)
                            .lineLimit(1)
                        
                        if data.isVerified {
                            Image.sessionCardVerifiedIcon
                                .resizable()
                                .scaledToFit()
                                .frame(height: 12)
                        }
                    }
                    
                    Text(data.title)
                        .font(.robotoBold(size: 12))
                        .foregroundColor(.DinotisDefault.black2)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            
          HStack {
            VStack(alignment: .leading, spacing: 4) {
              Text(LocalizableText.totalPriceLabel)
                .font(.robotoMedium(size: 10))
                .foregroundColor(.DinotisDefault.black2)
              
              Text(data.price)
                .font(.robotoBold(size: 14))
                .foregroundColor(.DinotisDefault.primary)
            }
            
            Spacer()
              
              Button(action: action) {
                  Text(buttonLabel)
                      .font(.robotoBold(size: 14))
                      .foregroundColor(.white)
                      .padding(10)
                      .frame(width: 130)
                      .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.DinotisDefault.primary)
                      )
              }
              .buttonStyle(.plain)
              
          }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        )
    }
}

struct ScheduledSessionCardView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            ForEach(0...5, id: \.self) { _ in
                ScheduledSessionCardView(data: SessionCardModel(
                    title: "Cara memahami emosional yang tidak stabil dalam menghadapi masalah di dunia tipu-tipu, kubisa rasa nyaman denganmu",
                    date: "16 Sept 2022",
                    isVerified: false,
                    photo: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQHXbffIPSvVpJ8Lyu-0MlD3YZCMIYBA5wstAiQlSZN&s",
                    name: "Sarah Widjaja",
                    color: [""],
                    session: 8,
                    price: "Rp250.000",
                    participantsImgUrl: [], isActive: true,
                    type: .bundling,
                    invoiceId: "DINO0123456789",
                    status: "Akan Datang", isAlreadyBooked: true), buttonLabel: "Bayar Sekarang", {}, visitProfile: {}
                )
            }
            .padding()
        }
    }
}
