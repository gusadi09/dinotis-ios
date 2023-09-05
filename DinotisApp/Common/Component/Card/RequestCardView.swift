//
//  RequestCardView.swift
//  DinotisApp
//
//  Created by Garry on 07/10/22.
//

import SwiftUI
import DinotisData
import DinotisDesignSystem

struct RequestCardView: View {
    
	let user: UserResponse?
    let item: MeetingRequestData?
    
    var onTapDecline: () -> Void
    var onTapAccept: () -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            ProfileImageContainer(
				profilePhoto: .constant((user?.profilePhoto).orEmpty()),
				name: .constant((user?.name).orEmpty()),
                width: 46,
                height: 46
            )
            
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text((user?.name).orEmpty())
                            .foregroundColor(.DinotisDefault.black1)
                            .font(.robotoBold(size: 12))
                        
                        Spacer()
                        
                        Text(countHourTime(time: (item?.createdAt).orCurrentDate()))
                            .foregroundColor(.DinotisDefault.black1)
                            .font(.robotoRegular(size: 10))
                    }
                    .padding(.bottom, 4)
                    
                    Text((item?.rateCard?.title).orEmpty())
                        .foregroundColor(.DinotisDefault.black2)
                        .font(.robotoMedium(size: 12))
                    
                    Text((item?.message).orEmpty())
                        .lineLimit(3)
                        .foregroundColor(.DinotisDefault.black1)
                        .font(.robotoRegular(size: 10))
                    
                    HStack(spacing: 8) {
                        Text((item?.rateCard?.price).orEmpty().toCurrency())
                            .foregroundColor(.DinotisDefault.black2)
                            .font(.robotoBold(size: 10))
                        
                        Circle()
                            .foregroundColor(.DinotisDefault.black2)
                            .frame(width: 3, height: 3)
                        
                        Text(LocaleText.durationNMinutes((item?.rateCard?.duration).orZero()))
                            .foregroundColor(.DinotisDefault.black2)
                            .font(.robotoBold(size: 10))
                    }
                }

				if item?.isAccepted == nil {
					HStack {
						Button {
							onTapDecline()
						} label: {
							HStack {
								Spacer()
								Text(LocaleText.decline)
									.foregroundColor(.black)
									.font(.robotoMedium(size: 10))
								Spacer()
							}
							.padding(10)
							.background(
								RoundedRectangle(cornerRadius: 7)
									.foregroundColor(.secondaryViolet)
							)
							.overlay(
								RoundedRectangle(cornerRadius: 7)
									.stroke(Color.DinotisDefault.primary, lineWidth: 0.8)
							)
						}
						
						Button {
							onTapAccept()
						} label: {
							HStack {
								Spacer()
								Text(LocaleText.accept)
									.foregroundColor(.white)
									.font(.robotoMedium(size: 10))
								Spacer()
							}
							.padding(10)
							.background(
								RoundedRectangle(cornerRadius: 7)
									.foregroundColor(.DinotisDefault.primary)
							)
						}
					}
				}
            }
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .inset(by: 0.25)
                .stroke(Color(red: 0.87, green: 0.87, blue: 0.87), lineWidth: 0.5)
        )
        .background(
            RoundedRectangle(cornerRadius: 7)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.1), radius: 1.5, x: 0, y: 2)
        )
    }
    
    private func countHourTime(time: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = Locale.current
        return formatter.localizedString(for: time, relativeTo: Date())
    }
}

struct DummyRequestSession {
    let title: String = "Ngobrol bareng aku yuk!"
    let desc: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Et, tellus porta commodo at sed."
    let requestedAt: String = "2022-10-08T16:10:00.000Z"
    let duration: Int = 60
    let price: Double = 300000
}
