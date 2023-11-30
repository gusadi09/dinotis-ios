//
//  SubscriptionCard.swift
//
//
//  Created by Irham Naufal on 30/11/23.
//

import SwiftUI

public struct SubscriptionCard: View {
    
    private let name: String
    private let imgProfile: String
    private let isVerified: Bool
    private let professions: [String]
    private let endAt: Date?
    
    public init(name: String, imgProfile: String, isVerified: Bool, professions: [String], endAt: Date?) {
        self.name = name
        self.imgProfile = imgProfile
        self.isVerified = isVerified
        self.professions = professions
        self.endAt = endAt
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            Text(LocalizableText.subscriptionCardTitle)
                .foregroundColor(.white)
                .font(.robotoBold(size: 18))
                .multilineTextAlignment(.center)
            
            HStack(spacing: 8) {
                DinotisImageLoader(urlString: imgProfile)
                    .scaledToFill()
                    .frame(width: 84, height: 84)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(name)
                            .foregroundColor(.white)
                            .font(.robotoBold(size: 16))
                            .lineLimit(1)
                        
                        if isVerified {
                            Image.sessionCardVerifiedIcon
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16)
                        }
                    }
                    
                    Text(professionText)
                        .foregroundColor(.white)
                        .font(.robotoRegular(size: 12))
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
            
            HStack(spacing: 0) {
                if let dayCounter {
                    Text(LocalizableText.subscriptionExpiredRemaining(dayCount: dayCounter))
                        .font(.robotoBold(size: 12))
                    
                    Spacer()
                }
                
                Text(LocalizableText.subscriptionCancelDesc)
                    .font(.robotoRegular(size: 12))
            }
            .foregroundColor(.white)
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [(.init(hex: "810DF7") ?? .DinotisDefault.linearOrangeLeft), (.init(hex: "02A9CD") ?? .DinotisDefault.linearOrangeRight)],
                startPoint: .bottomLeading,
                endPoint: .topTrailing
            )
        )
        .cornerRadius(12)
        .shineEffect(color: .white.opacity(0.2))
    }
    
    private var professionText: String {
        professions.joined(separator: ", ")
    }
    
    private var dayCounter: Int? {
        if let endAt {
            return Calendar.current.dateComponents([.day], from: .now, to: endAt).day
        } else {
            return nil
        }
    }
}

#Preview {
    SubscriptionCard(name: "Kathryn Murphy", imgProfile: "https://i.mydramalist.com/rPL27_5c.jpg", isVerified: true, professions: ["Streamer", "Psikolog"], endAt: .now)
}
