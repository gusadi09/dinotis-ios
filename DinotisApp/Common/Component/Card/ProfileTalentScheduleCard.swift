//
//  ProfileTalentScheduleCard.swift
//  DinotisApp
//
//  Created by Gus Adi on 25/08/21.
//

import SwiftUI
import CurrencyFormatter
import SwiftKeychainWrapper

struct ProfileTalentScheduleCard: View {
	@State var isShowMenu = false
	
	@Binding var items: Meeting
	@Binding var currentUserId: String
	
	var onTapButton: () -> Void
	
	@ObservedObject var detailMeetingVM = DetailMeetingViewModel.shared
	
	var body: some View {
		ZStack(alignment: .topTrailing) {
			VStack(alignment: .leading, spacing: 10) {
				HStack {
					Image("ic-video-conf")
						.resizable()
						.scaledToFit()
						.frame(height: 32)
					
					Spacer()
					
					if items.endedAt != nil {
						Text(NSLocalizedString("ended_meeting_card_label", comment: ""))
							.font(.custom(FontManager.Montserrat.regular, size: 12))
							.foregroundColor(.black)
							.padding(.vertical, 3)
							.padding(.horizontal, 8)
							.background(Color(.systemGray5))
							.clipShape(Capsule())
					}
				}
				
				Text(items.title.orEmpty())
					.font(Font.custom(FontManager.Montserrat.bold, size: 14))
					.foregroundColor(.black)
				
				Text(items.meetingDescription.orEmpty())
					.font(Font.custom(FontManager.Montserrat.regular, size: 12))
					.foregroundColor(.black)
					.padding(.bottom, 10)
				
				HStack(spacing: 10) {
					Image("ic-calendar")
						.resizable()
						.scaledToFit()
						.frame(height: 18)
					
					if let dateStart = dateISOFormatter.date(from: items.startAt.orEmpty()) {
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
					
					if let timeStart = dateISOFormatter.date(from: items.startAt.orEmpty()),
						 let timeEnd = dateISOFormatter.date(from: items.endAt.orEmpty()) {
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
						
						Text("\(String.init(participantCount()))/\(String.init(items.slots.orZero())) \(NSLocalizedString("participant", comment: ""))")
							.font(Font.custom(FontManager.Montserrat.regular, size: 12))
							.foregroundColor(.black)
						
						if items.slots.orZero() > 1 && !(items.isLiveStreaming ?? false) {
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
							
						} else if items.isLiveStreaming ?? false {
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

					if items.price == "0" {
						Text(NSLocalizedString("free_text", comment: ""))
							.font(.montserratBold(size: 14))
							.foregroundColor(.primaryViolet)
					} else {
						VStack(alignment: .leading) {
							Text("\(Int.init(items.price.orEmpty()) ?? 0)")
								.font(.montserratBold(size: 14))
								.foregroundColor(.primaryViolet)
						}
					}

					Spacer()

					Button(action: {
						onTapButton()
					}, label: {
						if items.endedAt != nil || items.slots.orZero() == items.bookings.filter({ items in
							items.bookingPayment?.paidAt == nil &&
							items.bookingPayment?.failedAt == nil
						}).count || !isStillShowing(date: dateISOFormatter.date(from: items.endAt.orEmpty()) ?? Date()) && !isHaveMeeting() {
							Text(NSLocalizedString("schedule_not_available", comment: ""))
								.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
								.foregroundColor(.black.opacity(0.6))
								.padding()
								.padding(.horizontal, 10)
								.background(
									Color(.lightGray).opacity(0.4)
								)
								.cornerRadius(8)

						} else if items.userID == currentUserId {
							EmptyView()

						} else if isHaveMeeting() {
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

						} else if items.slots == items.bookings.filter({ items in
							items.bookingPayment?.paidAt != nil
						}).count && !isHaveMeeting() {
							Text(NSLocalizedString("full_room", comment: ""))
								.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
								.foregroundColor(.black.opacity(0.6))
								.padding()
								.padding(.horizontal, 10)
								.background(
									Color(.lightGray).opacity(0.4)
								)
								.cornerRadius(8)

						} else {
							Text(NSLocalizedString("booking", comment: ""))
								.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
								.foregroundColor(.white)
								.padding()
								.padding(.horizontal, 10)
								.background(
									Color("btn-stroke-1")
								)
								.cornerRadius(8)
						}
					})
					.buttonStyle(.plain)
					.disabled(
						(items.endedAt != nil ||
						 items.slots == items.bookings.filter({ items in
							 items.bookingPayment?.paidAt == nil &&
							 items.bookingPayment?.failedAt == nil
						 }).count ||
						 !isStillShowing(date: dateISOFormatter.date(from: items.endAt.orEmpty()).orCurrentDate()) ||
						 items.slots == items.bookings.filter({ items in
							 items.bookingPayment?.paidAt != nil
						 }).count) && !isHaveMeeting()
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
		.onAppear {
			detailMeetingVM.getDetailMeeting(id: items.id.orEmpty())
		}
	}
	
	private func participantCount() -> Int {
		items.bookings.filter({ items in items.bookingPayment?.paidAt != nil && items.bookingPayment?.failedAt == nil }).count
	}
	
	private func isStillShowing(date: Date) -> Bool {
		let order = Calendar.current.compare( date, to: Date(), toGranularity: .minute)
		
		switch order {
		case .orderedSame:
			return true
		case .orderedDescending:
			return true
		default:
			return false
		}
	}
	
	private func isHaveMeeting() -> Bool {
		var isUser = false
		
		for itemsOfBook in items.bookings.filter({ value in
			value.userID == currentUserId && value.bookingPayment?.paidAt != nil
		}) where currentUserId == itemsOfBook.userID {
			isUser = true
		}
		
		return isUser
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
