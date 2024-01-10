//
//  SwiftUIView.swift
//  
//
//  Created by Irham Naufal on 03/01/24.
//

import SwiftUI

public struct PrivateCallCard: View {
    
    private let imageURL: String
    private let title: String
    private let name: String
    private let isVerified: Bool
    private let price: Int
    
    public init(imageURL: String, title: String, name: String, isVerified: Bool, price: Int) {
        self.imageURL = imageURL
        self.title = title
        self.name = name
        self.isVerified = isVerified
        self.price = price
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            DinotisImageLoader(urlString: imageURL)
                .scaledToFill()
                .frame(width: 174, height: 174)
                .clipShape(Rectangle())
            
            Group {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.robotoBold(size: 12))
                        .foregroundColor(.DinotisDefault.black1)
                        .lineLimit(2)
                    
                    HStack(spacing: 3) {
                        Text(name)
                            .font(.robotoRegular(size: 12))
                            .foregroundColor(.DinotisDefault.black3)
                            .lineLimit(1)
                        
                        if isVerified {
                            Image.sessionCardVerifiedIcon
                                .resizable()
                                .scaledToFit()
                                .frame(width: 12, height: 12)
                        }
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, 4)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizableText.startFromLabel)
                        .font(.robotoRegular(size: 12))
                        .foregroundColor(.DinotisDefault.black1)
                    
                    Group {
                        if price == 0 {
                            Text(LocalizableText.freeText)
                        } else {
                            Text("Rp\(price.toDecimal())")
                        }
                    }
                    .font(.robotoBold(size: 16))
                    .foregroundColor(.DinotisDefault.primary)
                    .lineLimit(2)
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 12)
            }
            .padding(.horizontal, 8)
        }
        .frame(width: 174, height: 305, alignment: .top)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color(red: 0.22, green: 0.29, blue: 0.41).opacity(0.2), radius: 10)
    }
}

#Preview {
    ZStack {
        Color.DinotisDefault.primary.ignoresSafeArea()
        
        PrivateCallCard(
            imageURL: "https://api.duniagames.co.id/api/content/upload/file/6013685931683276029.jpg",
            title: "Ngobrolin tentang Skincare yang cocok untukmu dan banyak hal lainnya",
            name: "Freya Jkt48",
            isVerified: true,
            price: 150000
        )
    }
}
