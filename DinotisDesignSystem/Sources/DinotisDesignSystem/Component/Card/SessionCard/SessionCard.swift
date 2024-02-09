//
//  SwiftUIView.swift
//  
//
//  Created by Garry on 28/01/23.
//

import SwiftUI

public struct SessionCardModel {
    let title: String
    let date: String
    let startAt: String
    let endAt: String
    let isPrivate: Bool
    let isVerified: Bool
    let photo: String
    let name: String
    let color: [String]?
    let description: String
	let session: Int
    let price: String
    let participants: Int
    let participantsImgUrl: [String]
	let isActive: Bool
	let type: SessionType
    let invoiceId: String
    let status: String
    let collaborationCount: Int
    let collaborationName: String
    let isOnBundling: Bool
    let isAlreadyBooked: Bool

    public init(
        title: String,
        date: String,
        startAt: String = "",
        endAt: String = "",
        isPrivate: Bool = false,
        isVerified: Bool,
        photo: String,
        name: String,
        color: [String]?,
        description: String = "",
		session: Int = 0,
        price: String = "",
        participants: Int = 0,
        participantsImgUrl: [String],
		isActive: Bool,
		type: SessionType = .session,
        invoiceId: String = "",
        status: String = "",
        collaborationCount: Int = 0,
        collaborationName: String = "",
        isOnBundling: Bool = false,
        isAlreadyBooked: Bool
    ) {
        self.title = title
        self.date = date
        self.startAt = startAt
        self.endAt = endAt
        self.isPrivate = isPrivate
        self.isVerified = isVerified
        self.photo = photo
        self.name = name
        self.color = color
        self.description = description
        self.price = price
        self.participants = participants
        self.participantsImgUrl = participantsImgUrl
		self.isActive = isActive
		self.type = type
		self.session = session
        self.invoiceId = invoiceId
        self.status = status
        self.collaborationCount = collaborationCount
        self.collaborationName = collaborationName
        self.isOnBundling = isOnBundling
        self.isAlreadyBooked = isAlreadyBooked
    }
}

public enum SessionType {
	case bundling
	case session
}

public struct SessionCard: View {
    
    private let data: SessionCardModel
    private let action: () -> Void
    private let visitProfile: () -> Void
    
    public init(
        with data: SessionCardModel,
        _ action: @escaping () -> Void,
        visitProfile: @escaping () -> Void
    ) {
        self.data = data
        self.action = action
        self.visitProfile = visitProfile
    }
    
    public var body: some View {
		ZStack(alignment: .topTrailing) {
			VStack(alignment: .leading, spacing: 12) {
				HStack(spacing: 5) {
                    Image.sessionCardDateIcon
						.resizable()
						.scaledToFit()
						.frame(width: 20)

					if data.type == .bundling {
						Text(LocalizableText.sessionValueText(with: data.session))
							.font(.robotoMedium(size: 10))
							.foregroundColor(.white)
					} else {
						Text(data.date)
							.font(.robotoMedium(size: 10))
							.foregroundColor(.white)

						Circle()
							.frame(width: 3, height: 3)

						Text("\(data.startAt) – \(data.endAt)")
							.font(.robotoMedium(size: 10))
					}

					Spacer()
				}
				.foregroundColor(data.color == nil ? .DinotisDefault.primary : .white)

				Text(data.title)
					.font(.robotoBold(size: 14))
					.lineLimit(2)
					.foregroundColor(data.color == nil ? .DinotisDefault.black1 : .white)
					.padding(.bottom, data.type == .session ? 0 : 15)
                
                Spacer()

				if data.type == .session {
                    HStack(spacing: 0) {
                        if !data.participantsImgUrl.isEmpty {
                            HStack(spacing: -10) {
                                ForEach(data.participantsImgUrl.prefix(4), id: \.self) {
                                    item in
                                    
                                    DinotisImageLoader(
                                        urlString: item,
                                        width: 25,
                                        height: 25
                                    )
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 1)
                                            .frame(width: 25, height: 25)
                                    )
                                }
                                
                                if data.participantsImgUrl.count > 4 {
                                    HStack(spacing: 2) {
                                        Circle()
                                            .scaledToFit()
                                            .frame(height: 3)
                                            .foregroundColor(.white)
                                        
                                        Circle()
                                            .scaledToFit()
                                            .frame(height: 3)
                                            .foregroundColor(.white)
                                        
                                        Circle()
                                            .scaledToFit()
                                            .frame(height: 3)
                                            .foregroundColor(.white)
                                    }
                                    .frame(width: 25, height: 25)
                                    .background(
                                        Circle()
                                            .frame(width: 25, height: 25)
                                            .foregroundColor(Color(hex: "#CD2DAD")?.opacity(0.75))
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: 1)
                                                    .frame(width: 25, height: 25)
                                            )
                                    )
                                }
                            }
                        }
                        
                        Text(data.isPrivate ? LocalizableText.privateSessionLabelWithEmoji : LocalizableText.groupSessionLabelWithEmoji)
                            .font(.robotoMedium(size: 10))
                            .foregroundColor(.DinotisDefault.primary)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 8)
                            .background(
                                Capsule()
                                    .foregroundColor(.white)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(data.color == nil ? Color.DinotisDefault.primary : .clear, lineWidth: 1)
                            )
                            .padding(.horizontal, data.participantsImgUrl.isEmpty ? 0 : 6)
                    }
				}
                
				HStack(spacing: 5) {
					Button {
                        if data.collaborationCount <= 0 {
                            visitProfile()
                        }
					} label: {
                        HStack(spacing: data.collaborationCount > 0 ? 12 : 8) {
                            HStack(spacing: -8) {
                                DinotisImageLoader(
                                    urlString: data.photo,
                                    width: 30,
                                    height: 30
                                )
                                .clipShape(Circle())
                                
                                if data.collaborationCount > 0 {
                                    Text("+\(data.collaborationCount)")
                                        .font(.robotoMedium(size: 16))
                                        .foregroundColor(.white)
                                        .background(
                                            Circle()
                                                .frame(width: 30, height: 30)
                                                .foregroundColor(Color(hex: "#CD2DAD")?.opacity(0.75))
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.white, lineWidth: 2)
                                                        .frame(width: 30, height: 30)
                                                )
                                        )
                                }
                            }

                            VStack(alignment: .leading) {
                                if data.isVerified {
                                    Text("\(data.name) \(Image.sessionCardVerifiedIcon)")
                                        .font(.robotoBold(size: 12))
                                        .foregroundColor(data.color == nil ? .DinotisDefault.primary : .white)
                                        .lineLimit(1)
                                        .multilineTextAlignment(.leading)
                                } else {
                                    Text("\(data.name)")
                                        .font(.robotoBold(size: 12))
                                        .foregroundColor(data.color == nil ? .DinotisDefault.primary : .white)
                                        .lineLimit(1)
                                        .multilineTextAlignment(.leading)
                                }
                                
                                if !data.collaborationName.isEmpty {
                                    Text(data.collaborationName)
                                        .font(.robotoRegular(size: 10))
                                        .multilineTextAlignment(.leading)
                                        .foregroundColor(.white)
                                        .lineLimit(2)
                                }
                            }
                            
						}
					}

					Spacer()

                    if data.isActive {
						DinotisCapsuleButton(
							text: data.type == .bundling ? LocalizableText.seeBundling : LocalizableText.seeText,
							textColor: .DinotisDefault.primary,
							bgColor: .white) {
								action()
							}
                            .isHidden(data.isOnBundling, remove: data.isOnBundling)
					}
				}
				.padding()
				.background(
					RoundedRectangle(cornerRadius: 22)
						.foregroundColor(.white.opacity(0.3))
				)
				.overlay(
					RoundedRectangle(cornerRadius: 22)
						.stroke(data.color == nil ? Color.DinotisDefault.primary : .clear, lineWidth: 0.5)
				)
			}
			.padding()

			if data.type == .bundling {
				Text(LocalizableText.bundlingSession)
					.font(.robotoBold(size: 12))
					.foregroundColor(.white)
					.padding(.vertical, 10)
					.padding(.horizontal, 15)
					.background(
						RoundedShape(radius: 25, corners: [.bottomLeft])
							.overlay(
								LinearGradient(colors: [.DinotisDefault.linearOrangeLeft, .DinotisDefault.linearOrangeRight], startPoint: .bottomLeading, endPoint: .topTrailing)
							)
							.clipShape(RoundedShape(radius: 25, corners: [.bottomLeft]))
					)
            } else if data.isAlreadyBooked {
                Text(LocalizableText.sessionCardBooked)
                    .font(.robotoBold(size: 12))
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                    .background(
                        RoundedShape(radius: 25, corners: [.bottomLeft])
                            .foregroundColor(.black.opacity(0.3))
                            .clipShape(RoundedShape(radius: 25, corners: [.bottomLeft]))
                    )
            }
		}
		.background(
			LinearGradient(colors: data.color?.compactMap({
				Color(hex: $0)
			}) ?? [], startPoint: .bottomLeading, endPoint: .topTrailing)
		)
		.clipShape(RoundedRectangle(cornerRadius: 12))
        .background(
            RoundedRectangle(cornerRadius: 12)
				.foregroundColor(.clear)
                .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
        )
    }
}

struct PreviewSessionCard: View {
    
    var body: some View {
        ZStack {
            Color.DinotisDefault.baseBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack {
                    ForEach(0...5, id: \.self) { item in
                        SessionCard(with: SessionCardModel(
                            title: "Cara memahami emosional yang tidak stabil dalam menghadapi masalah di dunia tipu-tipu, kubisa rasa nyaman denganmu",
                            date: "23 Jan 2023",
                            startAt: "18:00",
                            endAt: "19:00",
                            isPrivate: false,
                            isVerified: false,
                            photo: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQHXbffIPSvVpJ8Lyu-0MlD3YZCMIYBA5wstAiQlSZN&s",
                            name: "Habilia Aprilia Sukmajati Simatupang Mandasari",
                            color: [""],
                            participantsImgUrl: ["https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQHXbffIPSvVpJ8Lyu-0MlD3YZCMIYBA5wstAiQlSZN&s"],
                            isActive: true,
                            isAlreadyBooked: true
                        ), {}, visitProfile: {}
                        )
                    }
                }
                .padding()
            }
        }
    }
}

struct SessionCard_Previews: PreviewProvider {
    static var previews: some View {
        PreviewSessionCard()
    }
}
