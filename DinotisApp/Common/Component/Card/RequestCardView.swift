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
            
            VStack(alignment: .leading) {
                HStack {
					Text((user?.name).orEmpty())
                        .foregroundColor(.black)
                        .font(.robotoMedium(size: 12))
                    
                    Spacer()
                    
					Text(countHourTime(time: (item?.createdAt).orCurrentDate()))
                        .foregroundColor(.black)
                        .font(.robotoRegular(size: 10))
                }
                .padding(.bottom, 4)
                
				Text((item?.rateCard?.title).orEmpty())
                    .foregroundColor(.black)
                    .font(.robotoMedium(size: 12))
                    .opacity(0.7)
                    .padding(.bottom, 4)
                
				Text((item?.message).orEmpty())
                    .lineLimit(3)
                    .foregroundColor(.black)
                    .font(.robotoRegular(size: 10))
                    .opacity(0.8)
                
                HStack(spacing: 8) {
					Text((item?.rateCard?.price).orEmpty().toCurrency())
                        .foregroundColor(.black)
                        .font(.robotoMedium(size: 10))
                        .opacity(0.6)
                    
                    Circle()
                        .foregroundColor(.black)
                        .opacity(0.6)
                        .frame(width: 3, height: 3)
                    
					Text(LocaleText.durationNMinutes((item?.rateCard?.duration).orZero()))
                        .foregroundColor(.black)
                        .font(.robotoMedium(size: 10))
                        .opacity(0.6)
                }
                .padding(.top, -2)

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
        .background(
            RoundedRectangle(cornerRadius: 7)
                .foregroundColor(.white)
        )
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
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
