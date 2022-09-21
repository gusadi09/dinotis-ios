//
//  UserScheduleCardView.swift
//  DinotisApp
//
//  Created by Gus Adi on 15/08/21.
//

import SwiftUI
import CurrencyFormatter

struct UserScheduleCardView: View {
	@Binding var user: User
	@Binding var meeting: UserMeeting
	@Binding var payment: UserBookingPayment
	@Binding var currentUserId: String
	
	var onTapButton: (() -> Void)
	var onTapProfile: () -> Void
	var onTapDetailPaymennt: (() -> Void)
	
	var body: some View {
		ZStack(alignment: .topTrailing) {
			VStack(alignment: .leading, spacing: 10) {
				Button(action: {
					onTapProfile()
				}, label: {
					HStack {
						ProfileImageContainer(profilePhoto: $user.profilePhoto, name: $user.name, width: 40, height: 40)
						
						if let name = user.name, let isVerif = user.isVerified {
							Text(name)
								.font(Font.custom(FontManager.Montserrat.bold, size: 14))
								.foregroundColor(.black)
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
				})
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
							if payment.paidAt == nil && payment.failedAt != nil {
								Text(NSLocalizedString("payment_failed_card_text", comment: ""))
									.foregroundColor(.red)
									.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
									.multilineTextAlignment(.center)
							} else if payment.paidAt == nil && payment.failedAt == nil {
								Text(NSLocalizedString("waiting_payment_card_text", comment: ""))
									.foregroundColor(Color("btn-stroke-1"))
									.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
									.multilineTextAlignment(.center)
							}

							if meeting.price == "0" {
								Text(NSLocalizedString("free_text", comment: ""))
									.font(.montserratBold(size: 14))
									.foregroundColor(.primaryViolet)
							} else {
								VStack(alignment: .leading) {
									Text("\(Int.init(meeting.price.orEmpty()) ?? 0)")
										.font(.montserratBold(size: 14))
										.foregroundColor(.primaryViolet)
								}
							}
							
							if payment.paidAt == nil && payment.failedAt != nil && !(meeting.isPrivate ?? false) {
								Button {
									onTapDetailPaymennt()
								} label: {
									Text(NSLocalizedString("payment_detail_text", comment: ""))
										.foregroundColor(.black)
										.underline()
										.font(Font.custom(FontManager.Montserrat.regular, size: 12))
										.multilineTextAlignment(.center)
								}
							}
						}
					
					Spacer()
					
					Button(action: {
						onTapButton()
					}, label: {
						if (meeting.bookings?.filter({ value in
							value.bookingPayment.paidAt != nil &&
							value.bookingPayment.failedAt == nil &&
							(value.user.id).orEmpty() != currentUserId
						}).count).orZero() == meeting.slots.orZero() {
							Text(NSLocalizedString("full_schedule", comment: ""))
								.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
								.foregroundColor(.black.opacity(0.5))
								.padding()
								.padding(.horizontal, 10)
								.background(Color(.systemGray5))
								.cornerRadius(8)
								.multilineTextAlignment(.center)
							
						} else if !isStillShowing(date: (meeting.endAt?.toDate(format: .utcV2)).orCurrentDate()) && (payment.paidAt == nil && payment.failedAt != nil) {
							Text(NSLocalizedString("schedule_not_available", comment: ""))
								.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
								.foregroundColor(.black.opacity(0.5))
								.padding()
								.padding(.horizontal, 10)
								.background(Color(.systemGray5))
								.cornerRadius(8)
								.multilineTextAlignment(.center)
							
						} else {
								if payment.paidAt == nil && payment.failedAt != nil {
										Text(NSLocalizedString("booking_again_text", comment: ""))
											.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
											.foregroundColor(.white)
											.padding()
											.padding(.horizontal, 10)
											.background(Color("btn-stroke-1"))
											.cornerRadius(8)
											.multilineTextAlignment(.center)
								} else if payment.paidAt == nil && payment.failedAt == nil {
									if meeting.slots == 1 {
										Text(NSLocalizedString("payment_detail_text", comment: ""))
											.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
											.foregroundColor(Color("color-green-stroke"))
											.padding()
											.padding(.horizontal, 10)
											.background(Color("color-green-complete"))
											.cornerRadius(8)
											.overlay(
												RoundedRectangle(cornerRadius: 8)
													.stroke(Color("color-green-stroke"), lineWidth: 1.0)
											)
											.multilineTextAlignment(.center)
									}
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
										.multilineTextAlignment(.center)
								}
						}
					})
					.disabled(
						(meeting.bookings?.filter({ value in
							value.bookingPayment.paidAt != nil &&
							value.bookingPayment.failedAt == nil &&
							(value.user.id).orEmpty() != currentUserId &&
							!isStillShowing(date: (meeting.endAt?.toDate(format: .utcV2)).orCurrentDate()) && (payment.paidAt == nil && payment.failedAt != nil)
						}).count).orZero() == meeting.slots.orZero()
					)
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
	
	private func isStillShowing(date: Date) -> Bool {
		let order = Calendar.current.compare(date, to: Date(), toGranularity: .minute)
		
		switch order {
		case .orderedSame:
			return true
		case .orderedDescending:
			return true
		default:
			return false
		}
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
