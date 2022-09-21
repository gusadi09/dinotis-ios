//
//  HistoryCard.swift
//  DinotisApp
//
//  Created by Gus Adi on 27/10/21.
//

import SwiftUI
import CurrencyFormatter

struct HistoryCard: View {
	@Binding var user: User
	@Binding var meeting: UserMeeting
	@Binding var payment: UserBookingPayment
	
	var onTapDetail: () -> Void
	
	var body: some View {
		ZStack(alignment: .topTrailing) {
			VStack(alignment: .leading, spacing: 10) {
				HStack {
					ProfileImageContainer(profilePhoto: $user.profilePhoto, name: $user.name, width: 40, height: 40)
					
					if let name = user.name, let isVerif = user.isVerified {
						Text(name)
							.font(Font.custom(FontManager.Montserrat.bold, size: 14))
							.minimumScaleFactor(0.01)
							.lineLimit(1)
						
						if isVerif {
							Image("ic-verif-acc")
								.resizable()
								.scaledToFit()
								.frame(height: 16)
						}
					}
					
					Spacer()
					
					if meeting.endedAt != nil {
						Text(NSLocalizedString("ended_meeting_card_label", comment: ""))
							.font(.custom(FontManager.Montserrat.regular, size: 12))
							.foregroundColor(.black)
							.padding(.vertical, 3)
							.padding(.horizontal, 8)
							.background(Color(.systemGray5))
							.clipShape(Capsule())
					}
				}
				.padding(.bottom, 10)
				
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
					HStack(spacing: 10) {
						Image("ic-people-circle")
							.resizable()
							.scaledToFit()
							.frame(height: 18)
						
						Text("\(String.init((meeting.bookings?.filter({ items in items.bookingPayment.paidAt != nil }).count).orZero()))/\(String.init(meeting.slots.orZero())) \(NSLocalizedString("participant", comment: ""))")
							.font(Font.custom(FontManager.Montserrat.regular, size: 12))
							.foregroundColor(.black)
						
						if meeting.slots.orZero() > 1 && !(meeting.isLiveStreaming ?? false) {
							Text(NSLocalizedString("group", comment: ""))
								.font(Font.custom(FontManager.Montserrat.regular, size: 12))
								.foregroundColor(.black)
								.padding(.vertical, 5)
								.padding(.horizontal)
								.background(Color("btn-color-1"))
								.clipShape(Capsule())
								.overlay(
									Capsule()
										.stroke(Color("btn-stroke-1"), lineWidth: 1.0)
								)
							
						} else if meeting.isLiveStreaming ?? false {
							Text(LocaleText.liveStreamText)
								.font(Font.custom(FontManager.Montserrat.regular, size: 12))
								.foregroundColor(.black)
								.padding(.vertical, 5)
								.padding(.horizontal)
								.background(Color("btn-color-1"))
								.clipShape(Capsule())
								.overlay(
									Capsule()
										.stroke(Color("btn-stroke-1"), lineWidth: 1.0)
								)
						} else {
							Text(NSLocalizedString("private", comment: ""))
								.font(Font.custom(FontManager.Montserrat.regular, size: 12))
								.foregroundColor(.black)
								.padding(.vertical, 5)
								.padding(.horizontal)
								.background(Color("btn-color-1"))
								.clipShape(Capsule())
								.overlay(
									Capsule()
										.stroke(Color("btn-stroke-1"), lineWidth: 1.0)
								)
						}
					}
					
					Capsule()
						.frame(height: 1)
						.foregroundColor(.gray)
						.opacity(0.2)
				}
				
				HStack(spacing: 10) {
					Image.Dinotis.coinIcon
							.resizable()
							.scaledToFit()
							.frame(height: 15)

						VStack(alignment: .leading, spacing: 5) {
							if meeting.price == "0" {
								Text("free_text")
									.font(.montserratBold(size: 14))
									.foregroundColor(.primaryViolet)
							} else {
								Text(meeting.price.orEmpty().toPriceFormat())
									.font(.montserratBold(size: 14))
									.foregroundColor(.primaryViolet)
							}
						}

						Spacer()
					
					Button(action: {
						if !(payment.paidAt == nil && payment.failedAt != nil) {
							onTapDetail()
						}
					}, label: {
						if payment.paidAt == nil && payment.failedAt != nil {

								Text(NSLocalizedString("fail", comment: ""))
									.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
									.foregroundColor(Color(.red))
									.padding()
									.padding(.horizontal, 10)
									.background(Color(.red).opacity(0.3))
									.cornerRadius(8)
									.overlay(
										RoundedRectangle(cornerRadius: 8)
											.stroke(Color(.red), lineWidth: 1.0)
									)
						} else {

								Text(NSLocalizedString("view_details", comment: ""))
									.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
									.foregroundColor(Color("btn-stroke-1"))
									.padding()
									.padding(.horizontal, 10)
									.background(Color("btn-color-1"))
									.cornerRadius(8)
									.overlay(
										RoundedRectangle(cornerRadius: 8)
											.stroke(Color("btn-stroke-1"), lineWidth: 1.0)
									)

						}
					}).disabled(payment.paidAt == nil && payment.failedAt != nil)
				}
				.padding(.top, 10)
			}
		}
		.padding(.horizontal)
		.padding(.vertical, 25)
		.background(Color.white)
		.cornerRadius(12)
		.shadow(color: Color("dinotis-shadow-1").opacity(0.15), radius: 10, x: 0.0, y: 0.0)
		.padding(.horizontal)
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

private let currencyFormatter: CurrencyFormatter = {
	let fm = CurrencyFormatter()
	
	fm.currency = .rupiah
	fm.locale = CurrencyLocale.indonesian
	fm.decimalDigits = 0
	
	return fm
}()
