//
//  UserScheduleCardView.swift
//  DinotisApp
//
//  Created by Gus Adi on 15/08/21.
//

import SwiftUI
import CurrencyFormatter
import DinotisDesignSystem

struct UserScheduleCardView: View {
	@Binding var user: User
	@Binding var meeting: UserMeeting?
	@Binding var item: UserBooking?
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
						
						if let name = user.name {
							Text(name)
								.font(.robotoBold(size: 14))
								.foregroundColor(.black)
								.minimumScaleFactor(0.01)
								.lineLimit(1)
							
							if user.isVerified ?? false {
								Image.Dinotis.accountVerifiedIcon
									.resizable()
									.scaledToFit()
									.frame(height: 16)
							}
						}
						
						Spacer()
						
						if meeting?.endedAt != nil {
							Text(LocaleText.endedMeetingCardLabel)
								.font(.robotoRegular(size: 12))
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
					Image.Dinotis.calendarIcon
						.resizable()
						.scaledToFit()
						.frame(height: 18)
					if let dateStart = meeting?.startAt {
                        Text(DateUtils.dateFormatter(dateStart, forFormat: .EEEEddMMMMyyyy))
							.font(.robotoRegular(size: 12))
							.foregroundColor(.black)
					} else {
						Text(LocaleText.unconfirmedText)
							.font(.robotoRegular(size: 12))
							.foregroundColor(.black)
					}
				}
				
				HStack(spacing: 10) {
					Image.Dinotis.clockIcon
						.resizable()
						.scaledToFit()
						.frame(height: 18)
					
					if let timeStart = meeting?.startAt,
					   let timeEnd = meeting?.endAt {
                        Text("\(DateUtils.dateFormatter(timeStart, forFormat: .HHmm)) - \(DateUtils.dateFormatter(timeEnd, forFormat: .HHmm))")
							.font(.robotoRegular(size: 12))
							.foregroundColor(.black)
					} else {
						Text(LocaleText.unconfirmedText)
							.font(.robotoRegular(size: 12))
							.foregroundColor(.black)
					}
				}
				
				VStack(alignment: .leading, spacing: 20) {
					HStack(spacing: 10) {
						Image.Dinotis.peopleCircleIcon
							.resizable()
							.scaledToFit()
							.frame(height: 18)
						
						Text("\((meeting?.participants).orZero())/\(String.init((meeting?.slots).orZero())) \(LocaleText.generalParticipant)")
                            .font(.robotoRegular(size: 12))
							.foregroundColor(.black)
						
						if !(meeting?.isPrivate ?? false) && !(meeting?.isLiveStreaming ?? false) {
							Text(LocaleText.groupText)
								.font(.robotoRegular(size: 12))
								.foregroundColor(.black)
								.padding(.vertical, 5)
								.padding(.horizontal)
								.background(Color.secondaryViolet)
								.clipShape(Capsule())
								.overlay(
									Capsule()
										.stroke(Color.DinotisDefault.primary, lineWidth: 1.0)
								)
							
						} else {
							Text(LocaleText.privateText)
								.font(.robotoRegular(size: 12))
								.foregroundColor(.black)
								.padding(.vertical, 5)
								.padding(.horizontal)
								.background(Color.secondaryViolet)
								.clipShape(Capsule())
								.overlay(
									Capsule()
										.stroke(Color.DinotisDefault.primary, lineWidth: 1.0)
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
							if item?.isFailed ?? false {
								Text(NSLocalizedString("payment_failed_card_text", comment: ""))
									.foregroundColor(.red)
									.font(.robotoMedium(size: 12))
									.multilineTextAlignment(.center)
							} else if item?.isFailed == nil {
								Text(NSLocalizedString("waiting_payment_card_text", comment: ""))
									.foregroundColor(Color.DinotisDefault.primary)
									.font(.robotoMedium(size: 12))
									.multilineTextAlignment(.center)
							}

							if (meeting?.price).orEmpty() == "0" {
								Text(NSLocalizedString("free_text", comment: ""))
									.font(.robotoBold(size: 14))
									.foregroundColor(.DinotisDefault.primary)
							} else {
								VStack(alignment: .leading) {
									Text("\(Int.init((meeting?.price).orEmpty()) ?? 0)")
										.font(.robotoBold(size: 14))
										.foregroundColor(.DinotisDefault.primary)
								}
							}
							
							if (item?.isFailed ?? false) || item?.isFailed == nil {
								Button {
									onTapDetailPaymennt()
								} label: {
									Text(NSLocalizedString("payment_detail_text", comment: ""))
										.foregroundColor(.black)
										.underline()
                                        .font(.robotoRegular(size: 12))
										.multilineTextAlignment(.center)
								}
							}
						}
					
					Spacer()
					
					Button(action: {
						onTapButton()
					}, label: {
						if !isStillShowing(date: (meeting?.endAt).orCurrentDate()) && (item?.isFailed ?? false) {
							Text(NSLocalizedString("schedule_not_available", comment: ""))
								.font(.robotoMedium(size: 12))
								.foregroundColor(.black.opacity(0.5))
								.padding()
								.padding(.horizontal, 10)
								.background(Color(.systemGray5))
								.cornerRadius(8)
								.multilineTextAlignment(.center)
							
						} else {
							if (item?.isFailed ?? false) {
								Text(NSLocalizedString("booking_again_text", comment: ""))
									.font(.robotoMedium(size: 12))
									.foregroundColor(.white)
									.padding()
									.padding(.horizontal, 10)
									.background(Color("btn-stroke-1"))
									.cornerRadius(8)
									.multilineTextAlignment(.center)
							} else if item?.isFailed == nil {
								Text(LocaleText.detailPaymentText)
									.font(.robotoMedium(size: 12))
									.foregroundColor(Color.completeGreen)
									.padding()
									.padding(.horizontal, 10)
									.background(Color.primaryGreen)
									.cornerRadius(8)
									.overlay(
										RoundedRectangle(cornerRadius: 8)
											.stroke(Color.completeGreen, lineWidth: 1.0)
									)
									.multilineTextAlignment(.center)
							} else if !(item?.isFailed ?? false) || meeting?.meetingRequest != nil {
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
									.multilineTextAlignment(.center)
							}
						}
					})
					.disabled(
						!isStillShowing(date: (meeting?.endAt).orCurrentDate()) && (item?.isFailed ?? false)
					)
				}
				.padding(.top, 10)

			}
		}
		.padding(.horizontal)
		.padding(.vertical, 25)
		.background(Color.white)
		.cornerRadius(12)
		.shadow(color: .dinotisShadow.opacity(0.15), radius: 10, x: 0.0, y: 0.0)
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
