//
//  CreatorCard.swift
//  
//
//  Created by Gus Adi on 09/12/22.
//

import SwiftUI

public struct CreatorCardModel {
	let name: String
	let isVerified: Bool
	let professions: String
	let photo: String

	public init(name: String, isVerified: Bool, professions: String, photo: String) {
		self.name = name
		self.isVerified = isVerified
		self.professions = professions
		self.photo = photo
	}
}

public enum CreatorCardType {
    case simple
    case withDesc
}

public struct CreatorCard<BottomView: View>: View {

	private let data: CreatorCardModel
    private let type: CreatorCardType
    private let size: CGFloat?
    @ViewBuilder private var bottomView: BottomView

    public init(
        with data: CreatorCardModel,
        size: CGFloat? = nil,
        type: CreatorCardType = .simple,
        @ViewBuilder bottomView: () -> BottomView = {EmptyView()}
    ) {
		self.data = data
        self.size = size
        self.type = type
        self.bottomView = bottomView()
	}

	public var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                DinotisImageLoader(urlString: data.photo)
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        ZStack(alignment: .bottomLeading) {
                            LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                            
                            VStack(alignment: .leading) {
                                
                                HStack {
                                    Text(data.name)
                                        .font(.robotoMedium(size: 14))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                    
                                    if data.isVerified {
                                        Image.sessionCardVerifiedIcon
                                    }
                                }
                                
                                Text(data.professions)
                                    .font(.robotoMedium(size: 10))
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                            }
                            .padding(8)
                        }
                    )
                
            }
            .clipShape(
                RoundedRectangle(cornerRadius: 8)
            )
            
            bottomView
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(type == .withDesc ? .white : .clear)
                .shadow(color: type == .withDesc ? .black.opacity(0.1) : .clear, radius: 6)
        )
        .frame(width: size)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct CreatorCardPrev: View {
	var body: some View {
		GeometryReader { _ in
			ScrollView {
				LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]) {
					ForEach(0...6, id: \.self) { _ in
                        CreatorCard(with: CreatorCardModel(name: "Russel Mann", isVerified: false, professions: "Psikolog", photo: "https://cloudflare-ipfs.com/ipfs/Qmd3W5DuhgHirLHGVixi6V76LhCkZUz6pnFt5AJBiyvHye/avatar/547.jpg"), size: 160, type: .withDesc) {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("0")
                                        .font(.robotoBold(size: 12))
                                    
                                    Text("Sesi Selesai")
                                        .font(.robotoRegular(size: 12))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "star.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.orange)
                                        .frame(width: 13)
                                }
                            }
                        }
					}
				}
			}
		}
        .background(Color.DinotisDefault.baseBackground.ignoresSafeArea())
	}
}

struct CreatorCard_Previews: PreviewProvider {
    static var previews: some View {
		CreatorCardPrev()
			.padding()
    }
}
