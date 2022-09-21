//
//  HomePrivateFeatureCard.swift
//  DinotisApp
//
//  Created by Gus Adi on 17/04/22.
//

import SwiftUI

struct HomePrivateFeatureCard: View {
	@Binding var user: User
	@Binding var meeting: UserMeeting
	
	var onTapProfile: () -> Void
	
	var body: some View {
		ZStack(alignment: .topTrailing) {
			VStack(alignment: .leading, spacing: 10) {
				Button(action: {
					onTapProfile()
				}, label: {
					HStack {
						ProfileImageContainer(profilePhoto: $user.profilePhoto, name: $user.name, width: 40, height: 40)
						
						if let name = user.name, let isVerif = user.isVerified {
							VStack(alignment: .leading) {
								Text(name)
									.font(.montserratSemiBold(size: 14))
									.foregroundColor(.black)
									.lineLimit(2)
								
								if isVerif {
									HStack {
										Image("ic-verif-acc")
											.resizable()
											.scaledToFit()
											.frame(height: 13)
										
										Text(LocaleText.homeScreenVerified)
											.font(.montserratSemiBold(size: 12))
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
					.font(.montserratBold(size: 14))
					.foregroundColor(.black)
				
				HStack(spacing: 10) {
					Image("ic-calendar")
						.resizable()
						.scaledToFit()
						.frame(height: 18)
					if let dateStart = dateISOFormatter.date(from: meeting.startAt.orEmpty()) {
						Text(dateFormatter.string(from: dateStart))
							.font(Font.custom(FontManager.Montserrat.regular, size: 12))
							.foregroundColor(.black)
					}
				}
				
				HStack(spacing: 10) {
					Image("ic-clock")
						.resizable()
						.scaledToFit()
						.frame(height: 18)
					
					if let timeStart = dateISOFormatter.date(from: meeting.startAt.orEmpty()),
						 let timeEnd = dateISOFormatter.date(from: meeting.endAt.orEmpty()) {
						Text("\(timeFormatter.string(from: timeStart)) - \(timeFormatter.string(from: timeEnd))")
							.font(Font.custom(FontManager.Montserrat.regular, size: 12))
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
									.font(.montserratSemiBold(size: 12))
									.foregroundColor(.white)
								
								Spacer()
							}
							.padding(13)
							.background(
								RoundedRectangle(cornerRadius: 12)
									.foregroundColor(.primaryViolet)
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
		.shadow(color: Color("dinotis-shadow-1").opacity(0.15), radius: 10, x: 0.0, y: 0.0)
	}
}

private let dateFormatter: DateFormatter = {
	let formatter = DateFormatter()
	formatter.dateStyle = .short
	formatter.locale = Locale.current
	formatter.dateFormat = "EEEE, dd MMMM yyyy"
	return formatter
}()

private let dateISOFormatter: DateFormatter = {
	let dateFormatter = DateFormatter()
	dateFormatter.locale = Locale.current
	dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
	return dateFormatter
}()

private let timeFormatter: DateFormatter = {
	let formatter = DateFormatter()
	formatter.dateStyle = .short
	formatter.locale = Locale.current
	formatter.dateFormat = "HH.mm"
	return formatter
}()
