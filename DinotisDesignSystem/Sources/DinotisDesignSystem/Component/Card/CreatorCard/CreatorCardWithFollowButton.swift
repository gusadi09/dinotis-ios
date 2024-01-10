//
//  SwiftUIView.swift
//  
//
//  Created by Irham Naufal on 03/01/24.
//

import SwiftUI

public struct CreatorCardWithFollowButton: View {
    
    private let imageURL: String
    private let name: String
    private let isVerified: Bool
    private let professions: String
    @Binding private var isFollowed: Bool
    @Binding private var isLoading: Bool
    private let followAction: () -> Void
    
    public init(
        imageURL: String,
        name: String,
        isVerified: Bool,
        professions: String,
        isFollowed: Binding<Bool>,
        isLoading: Binding<Bool>,
        followAction: @escaping () -> Void
    ) {
        self.imageURL = imageURL
        self.name = name
        self.isVerified = isVerified
        self.professions = professions
        self._isFollowed = isFollowed
        self._isLoading = isLoading
        self.followAction = followAction
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            DinotisImageLoader(urlString: imageURL)
            
            VStack(alignment: .leading, spacing: 6) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 3) {
                        Text(name)
                            .font(.robotoBold(size: 12))
                            .foregroundColor(.DinotisDefault.black1)
                        
                        if isVerified {
                            Image.sessionCardVerifiedIcon
                                .resizable()
                                .scaledToFit()
                                .frame(height: 12)
                        }
                    }
                    
                    Text(professions)
                        .font(.robotoRegular(size: 10))
                        .foregroundColor(.DinotisDefault.black3)
                }
                .lineLimit(1)
                
                Button {
                    followAction()
                } label: {
                    Group {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(isFollowed ? .DinotisDefault.black1 : .white)
                        } else {
                            Text(isFollowed ? LocalizableText.unfollowLabel : LocalizableText.followLabel)
                                .font(.robotoBold(size: 10))
                                .foregroundColor(isFollowed ? .DinotisDefault.black2 : .white)
                        }
                    }
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity, maxHeight: 36)
                    .background(isFollowed ? Color.DinotisDefault.grayDinotis : Color.DinotisDefault.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 7)
        }
        .frame(width: 154, height: 242)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: Color(red: 0.22, green: 0.29, blue: 0.41).opacity(0.11), radius: 8.4)
    }
}

fileprivate struct CardPreview: View {
    @State var isFollowed: Bool = false
    var body: some View {
        CreatorCardWithFollowButton(
            imageURL: "https://api.duniagames.co.id/api/content/upload/file/6013685931683276029.jpg",
            name: "Freya JKT48",
            isVerified: true,
            professions: "Singer, Idol",
            isFollowed: $isFollowed,
            isLoading: .constant(false)
        ) {
            self.isFollowed.toggle()
        }
    }
}

#Preview {
    CardPreview()
}
