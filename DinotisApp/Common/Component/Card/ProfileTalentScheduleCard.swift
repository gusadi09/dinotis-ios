//
//  ProfileTalentScheduleCard.swift
//  DinotisApp
//
//  Created by Gus Adi on 25/08/21.
//

import SwiftUI
import CurrencyFormatter
import DinotisDesignSystem

struct ProfileTalentScheduleCard: View {
	@State var isShowMenu = false
	
	@Binding var items: Meeting
	@Binding var currentUserId: String

	let isFromBundleDetail: Bool
	
	var onTapButton: () -> Void
	
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
							.font(.robotoRegular(size: 12))
							.foregroundColor(.black)
							.padding(.vertical, 3)
							.padding(.horizontal, 8)
							.background(Color(.systemGray5))
							.clipShape(Capsule())
					}
				}
				
				Text(items.title.orEmpty())
					.font(.robotoBold(size: 14))
					.foregroundColor(.black)
				
				Text(items.meetingDescription.orEmpty())
					.font(.robotoRegular(size: 12))
					.foregroundColor(.black)
					.padding(.bottom, 10)
				
				HStack(spacing: 10) {
					Image("ic-calendar")
						.resizable()
						.scaledToFit()
						.frame(height: 18)
					
					if let dateStart = items.startAt {
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
					
					if let timeStart = items.startAt,
						 let timeEnd = items.endAt {
						Text("\(DateUtils.dateFormatter(timeStart, forFormat: .HHmm)) - \(DateUtils.dateFormatter(timeEnd, forFormat: .HHmm))")
							.font(.robotoRegular(size: 12))
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
							.font(.robotoRegular(size: 12))
							.foregroundColor(.black)
						
						if items.slots.orZero() > 1 && !(items.isLiveStreaming ?? false) {
							Text(NSLocalizedString("group", comment: ""))
								.font(.robotoRegular(size: 12))
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
								.font(.robotoRegular(size: 12))
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
								.font(.robotoRegular(size: 12))
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
							.font(.robotoBold(size: 14))
							.foregroundColor(.DinotisDefault.primary)
					} else {
						VStack(alignment: .leading) {
							Text("\(Int.init(items.price.orEmpty()) ?? 0)")
								.font(.robotoBold(size: 14))
								.foregroundColor(.DinotisDefault.primary)
						}
					}

					Spacer()

					if !isFromBundleDetail {
						Button(action: {
							onTapButton()
						}, label: {
							if items.endedAt != nil || items.slots.orZero() == items.participants.orZero() || !isStillShowing(date: items.endAt.orCurrentDate()) && !(items.isAlreadyBooked ?? false)  {
								Text(NSLocalizedString("schedule_not_available", comment: ""))
									.font(.robotoMedium(size: 12))
									.foregroundColor(.black.opacity(0.6))
									.padding()
									.padding(.horizontal, 10)
									.background(
										Color(.lightGray).opacity(0.4)
									)
									.cornerRadius(8)
								
							} else if items.userID == currentUserId {
								EmptyView()
								
							} else if items.isAlreadyBooked ?? false  {
								Text(NSLocalizedString("view_details", comment: ""))
									.font(.robotoMedium(size: 12))
									.foregroundColor(Color("btn-stroke-1"))
									.padding()
									.padding(.horizontal, 10)
									.background(Color("btn-color-1"))
									.cornerRadius(8)
									.overlay(
										RoundedRectangle(cornerRadius: 8)
											.stroke(Color("btn-stroke-1"), lineWidth: 1.0)
									)
								
                            } else if items.slots == items.participants.orZero() && items.isAlreadyBooked ?? false {
								Text(NSLocalizedString("full_room", comment: ""))
									.font(.robotoMedium(size: 12))
									.foregroundColor(.black.opacity(0.6))
									.padding()
									.padding(.horizontal, 10)
									.background(
										Color(.lightGray).opacity(0.4)
									)
									.cornerRadius(8)
								
							} else {
								Text(NSLocalizedString("booking", comment: ""))
                                    .font(.robotoMedium(size: 12))
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
							 items.slots == items.participants.orZero() ||
							 !isStillShowing(date: items.endAt.orCurrentDate())) && !(items.isAlreadyBooked ?? false)
						)
					}
				}
				.padding(.top, 10)
			}
		}
		.padding(.horizontal)
		.padding(.vertical, 25)
		.background(Color.white)
		.cornerRadius(12)
		.shadow(color: Color("dinotis-shadow-1").opacity(0.06), radius: 8, x: 0.0, y: 0.0)
	}
	
	private func participantCount() -> Int {
		(
			items.participants
		).orZero()
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
