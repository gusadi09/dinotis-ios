//
//  TalentDetailScheduleCardView.swift
//  DinotisApp
//
//  Created by Gus Adi on 20/08/21.
//

import SwiftUI
import CurrencyFormatter

struct TalentDetailScheduleCardView: View {
	@Binding var data: DetailMeeting
	
	@State var isShowMenu = false
	
	var onTapEdit: (() -> Void)
	
	var onTapDelete: (() -> Void)
	
	var onTapEnd: (() -> Void)
	
	var body: some View {
		ZStack(alignment: .topTrailing) {
			VStack(alignment: .leading) {
				HStack(spacing: 15) {
					Image("ic-video-conf")
						.resizable()
						.scaledToFit()
						.frame(height: 32)
					
					Spacer()
					
					if data.endedAt != nil {
						Text(NSLocalizedString("ended_meeting_card_label", comment: ""))
							.font(.custom(FontManager.Montserrat.regular, size: 12))
							.foregroundColor(.black)
							.padding(.vertical, 3)
							.padding(.horizontal, 8)
							.background(Color(.systemGray5))
							.clipShape(Capsule())
					} else {
						Menu {
							Button(action: {
								onTapEdit()
							}, label: {
								HStack {
									Image("ic-menu-edit")
										.renderingMode(.template)
										.resizable()
										.scaledToFit()
										.foregroundColor(.white)
										.frame(height: 15)

									Text(NSLocalizedString("edit_schedule", comment: ""))
										.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
										.foregroundColor(.black)
								}
							})

							if data.startedAt == nil {
								Button(action: {
									onTapDelete()
								}, label: {
									HStack {
										Image("ic-menu-delete")
											.renderingMode(.template)
											.resizable()
											.scaledToFit()
											.foregroundColor(.white)
											.frame(height: 15)

										Text(NSLocalizedString("delete_schedule", comment: ""))
											.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
											.foregroundColor(.black)
									}
								})
							} else {
								Button(action: {
									onTapEnd()
								}, label: {
									HStack {
										Image(systemName: "checkmark.circle")
											.renderingMode(.template)
											.resizable()
											.scaledToFit()
											.foregroundColor(.white)
											.frame(height: 15)

										Text(NSLocalizedString("finish_video_call_detail", comment: ""))
											.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
											.foregroundColor(.black)
									}
								})
							}
						} label: {
							HStack(spacing: 5) {
								Circle()
									.scaledToFit()
									.frame(height: 5)
								Circle()
									.scaledToFit()
									.frame(height: 5)
								Circle()
									.scaledToFit()
									.frame(height: 5)
							}
							.foregroundColor(Color("btn-stroke-1"))
						}
					}
				}
				.padding(.bottom, 10)
				
				VStack(alignment: .leading, spacing: 5) {
					Text(data.title ?? "")
						.font(Font.custom(FontManager.Montserrat.bold, size: 14))
						.foregroundColor(.black)
					
					Text(data.description ?? "")
						.font(Font.custom(FontManager.Montserrat.regular, size: 12))
						.foregroundColor(.black)
						.padding(.bottom, 10)
				}
				
				HStack(spacing: 10) {
					Image("ic-calendar")
						.resizable()
						.scaledToFit()
						.frame(height: 18)
					
					if let dateStart = dateISOFormatter.date(from: data.startAt ?? "") {
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
					
					if let timeStart = dateISOFormatter.date(from: data.startAt ?? ""),
						 let timeEnd = dateISOFormatter.date(from: data.endAt ?? "") {
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
						
						Text("\(String.init((data.bookings?.filter({ items in items.bookingPayment?.paidAt != nil }) ?? []).count))/\(data.slots.orZero()) \(NSLocalizedString("participant", comment: ""))")
							.font(Font.custom(FontManager.Montserrat.regular, size: 12))
							.foregroundColor(.black)
						
						if data.slots.orZero() > 1 && !(data.isLiveStreaming ?? false) {
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
							
						} else if data.isLiveStreaming ?? false {
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
				}
				
				VStack(alignment: .center, spacing: 15) {
					Capsule()
						.frame(height: 1)
						.foregroundColor(.gray)
						.opacity(0.2)
					
					if (data.bookings?.filter({ item in
						item.bookingPayment?.paidAt != nil
					}) ?? []).isEmpty {
						HStack {
							Text(NSLocalizedString("empty_participant", comment: ""))
								.font(Font.custom(FontManager.Montserrat.regular, size: 12))
								.foregroundColor(.black)
						}
					} else {
						HStack {
							Text(NSLocalizedString("detail_participant_label", comment: ""))
								.font(.montserratBold(size: 12))
								.foregroundColor(.black)
							
							Spacer()
						}

						if let datas = data.bookings?.filter({ item in
							item.bookingPayment?.paidAt != nil
						}) {
							ForEach(datas.prefix(4), id: \.id) { item in
								VStack {
									VStack {
										HStack {
											if let data = item.user {
												ProfileImageContainer(profilePhoto: .constant(data.profilePhoto), name: .constant(data.name), width: 40, height: 40)

												Text(data.name)
													.font(Font.custom(FontManager.Montserrat.semibold, size: 14))
													.foregroundColor(.black)
											}

											Spacer()

											// MARK: - Hidden
											if data.startedAt == nil {
												Button(action: {

												}, label: {
													Image("ic-menu-delete")
														.resizable()
														.scaledToFit()
														.frame(height: 20)
												})
												.isHidden(true, remove: true)
											}
										}
									}

									if item.id != data.bookings?.last?.id {
										Capsule()
											.frame(height: 1)
											.foregroundColor(.gray)
											.opacity(0.2)
									}
								}
							}

							if datas.count > 4 {
								Text(LocaleText.andMoreParticipant(datas.count-4))
									.font(.montserratBold(size: 12))
									.foregroundColor(.black)
							}
						}
					}
				}
				.padding(.vertical, 8)
				
			}
			.padding()
			.background(Color.white)
			.cornerRadius(12)
			.shadow(color: Color("dinotis-shadow-1").opacity(0.08), radius: 10, x: 0, y: 0)
			.padding()

		}
		.onTapGesture {
			isShowMenu = false
		}
		.onDisappear {
			isShowMenu = false
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
