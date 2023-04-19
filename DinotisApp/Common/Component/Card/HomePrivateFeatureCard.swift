//
//  HomePrivateFeatureCard.swift
//  DinotisApp
//
//  Created by Gus Adi on 17/04/22.
//

import SwiftUI
import DinotisDesignSystem
import DinotisData

struct HomePrivateFeatureCard: View {
	@Binding var user: UserResponse
	@Binding var meeting: UserMeetingData
	
	var onTapProfile: () -> Void
	
	var body: some View {
		ZStack(alignment: .topTrailing) {
			VStack(alignment: .leading, spacing: 10) {
				Button(action: {
					onTapProfile()
				}, label: {
					HStack {
                        ProfileImageContainer(profilePhoto: .constant(user.profilePhoto), name: .constant(user.name), width: 40, height: 40)
						
						if let name = user.name, let isVerif = user.isVerified {
							VStack(alignment: .leading) {
								Text(name)
									.font(.robotoMedium(size: 14))
									.foregroundColor(.black)
									.lineLimit(2)
								
								if isVerif {
									HStack {
										Image("ic-verif-acc")
											.resizable()
											.scaledToFit()
											.frame(height: 13)
										
										Text(LocaleText.homeScreenVerified)
											.font(.robotoMedium(size: 12))
											.foregroundColor(.black)
										
										Spacer()
									}
								}
							}
						}
						
						Spacer()
					}
				})
				.padding(.bottom, 10)
				
				Text(meeting.title.orEmpty())
					.font(.robotoBold(size: 14))
					.foregroundColor(.black)
				
				HStack(spacing: 10) {
					Image("ic-calendar")
						.resizable()
						.scaledToFit()
						.frame(height: 18)
					if let dateStart = meeting.startAt {
						Text(DateUtils.dateFormatter(dateStart, forFormat: .EEEEddMMMMyyyy))
                            .font(.robotoRegular(size: 12))
							.foregroundColor(.black)
					}
				}
				
				HStack(spacing: 10) {
					Image("ic-clock")
						.resizable()
						.scaledToFit()
						.frame(height: 18)
					
					if let timeStart = meeting.startAt,
						 let timeEnd = meeting.endAt {
						Text("\(DateUtils.dateFormatter(timeStart, forFormat: .HHmm)) - \(DateUtils.dateFormatter(timeEnd, forFormat: .HHmm))")
                            .font(.robotoRegular(size: 12))
							.foregroundColor(.black)
					}
				}
				
				VStack(alignment: .leading, spacing: 20) {
					Capsule()
						.frame(height: 1)
						.foregroundColor(.gray)
						.opacity(0.2)
				}
				
				HStack(spacing: 10) {
					Button(
						action: {
							onTapProfile()
						}, label: {
							HStack {
								Spacer()
								
								Text(LocaleText.homeScreenSeeSchedule)
									.font(.robotoMedium(size: 12))
									.foregroundColor(.white)
								
								Spacer()
							}
							.padding(13)
							.background(
								RoundedRectangle(cornerRadius: 12)
									.foregroundColor(.DinotisDefault.primary)
							)
						}
					)
				}
				.padding(.top, 10)
			}
		}
		.padding(.horizontal)
		.padding(.vertical, 25)
		.frame(width: 290)
		.background(Color.white)
		.cornerRadius(12)
		.shadow(color: Color("dinotis-shadow-1").opacity(0.1), radius: 8, x: 0.0, y: 0.0)
	}
}
