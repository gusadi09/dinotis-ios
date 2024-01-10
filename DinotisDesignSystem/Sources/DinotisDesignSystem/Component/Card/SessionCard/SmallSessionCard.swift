//
//  SwiftUIView.swift
//  
//
//  Created by Irham Naufal on 03/01/24.
//

import SwiftUI

public struct SmallSessionCard: View {
    
    private let imageURL: String
    private let name: String
    private let title: String
    private let isGroupSession: Bool
    private let date: Date
    
    public init(imageURL: String, name: String, title: String, isGroupSession: Bool, date: Date) {
        self.imageURL = imageURL
        self.name = name
        self.title = title
        self.isGroupSession = isGroupSession
        self.date = date
    }
    
    public var body: some View {
        HStack {
            DinotisImageLoader(urlString: imageURL)
                .scaledToFill()
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.robotoBold(size: 12))
                    .foregroundColor(.DinotisDefault.black3)
                
                Text(title)
                    .font(.robotoBold(size: 12))
                    .foregroundColor(.DinotisDefault.black1)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .frame(maxHeight: .infinity, alignment: .top)
                
                HStack(spacing: 6) {
                    Text(isGroupSession ? LocalizableText.groupVideoCallLabel : LocalizableText.privateVideoCallLabel)
                    
                    Circle()
                        .frame(width: 4, height: 4)
                    
                    Text(date.toStringFormat(with: .ddMMMyyyy))
                }
                .font(.robotoRegular(size: 12))
                .foregroundColor(.DinotisDefault.black3)
            }
        }
        .padding(8)
        .frame(maxWidth: 302, maxHeight: 88, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 2, y: 2)
    }
}

#Preview {
    SmallSessionCard(
        imageURL: "https://api.duniagames.co.id/api/content/upload/file/6013685931683276029.jpg",
        name: "Freya Jkt48",
        title: "Ngobrolin tentang Skincare yang cocok untukmu dan banyak hal lainnya",
        isGroupSession: true,
        date: Date()
    )
}
