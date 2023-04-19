//
//  TalentScheduleCardView.swift
//  DinotisApp
//
//  Created by Garry on 01/10/22.
//

import SwiftUI
import CurrencyFormatter
import DinotisDesignSystem

struct TalentScheduleCardView: View {
    @State var isShowMenu = false
    @Binding var data: Meeting

	let isBundle: Bool
    
    var onTapButton: (() -> Void)
    
    var onTapEdit: (() -> Void)
    
    var onTapDelete: (() -> Void)
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image("ic-video-conf")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 32)
                    
                    Spacer()
                    
                    if data.endedAt != nil {
                        Text(NSLocalizedString("ended_meeting_card_label", comment: ""))
                            .font(.robotoRegular(size: 12))
                            .foregroundColor(.black)
                            .padding(.vertical, 3)
                            .padding(.horizontal, 8)
                            .background(Color(.systemGray5))
                            .clipShape(Capsule())
					} else if data.meetingRequest == nil && data.endedAt == nil {
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
                                        .font(.robotoMedium(size: 12))
                                        .foregroundColor(.black)
                                }
                            })

                            if data.startedAt == nil {

								if !isBundle {
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
                                                .font(.robotoMedium(size: 12))
												.foregroundColor(.black)
										}
									})
								}
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
                            .contentShape(Rectangle())
                        }

                    }
                }
                
                Text(data.title.orEmpty())
                    .font(.robotoBold(size: 14))
                    .foregroundColor(.black)
                
                Text(data.meetingDescription.orEmpty())
                    .font(.robotoRegular(size: 12))
                    .foregroundColor(.black)
                    .padding(.bottom, 10)
                
                HStack(spacing: 10) {
                    Image("ic-calendar")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 18)
                    
                    if let dateStart = data.startAt {
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
                    Image("ic-clock")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 18)
                    
                    if let timeStart =  data.startAt,
                         let timeEnd = data.endAt {
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
                        Image("ic-people-circle")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 18)
                        
						Text("\(data.participants.orZero())/\(String.init(data.slots.orZero())) \(NSLocalizedString("participant", comment: ""))")
                            .font(.robotoRegular(size: 12))
                            .foregroundColor(.black)
                        
                        if data.slots.orZero() > 1 && !(data.isLiveStreaming ?? false) {
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
                            
                        } else if data.isLiveStreaming ?? false {
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
                    
                    if data.price == "0" {
                        Text(NSLocalizedString("free_text", comment: ""))
                            .font(.robotoBold(size: 14))
                            .foregroundColor(.DinotisDefault.primary)
                            .multilineTextAlignment(.center)
                    } else {
                        Text(data.price.orEmpty().toCurrency())
                            .font(.robotoBold(size: 14))
                            .foregroundColor(.DinotisDefault.primary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        onTapButton()
                    }, label: {
                        Text(NSLocalizedString("view_details", comment: ""))
                            .font(.robotoMedium(size: 12))
                            .foregroundColor(.black)
                            .padding()
                            .padding(.horizontal, 10)
                            .background(Color("btn-color-1"))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color("btn-stroke-1"), lineWidth: 1.0)
                            )
                            .multilineTextAlignment(.center)
                    })
                    
                    
                }
                .padding(.top, 10)

				if data.endedAt != nil {
					HStack {
						Spacer()
						
						Text(LocaleText.sessionHasEnded)
							.font(.robotoRegular(size: 10))
							.foregroundColor(.white)
						
						Spacer()
					}
					.padding(.vertical, 5)
					.background(
						Capsule()
							.foregroundColor(.attentionPink)
					)
					.padding(.top, 6)
				} else if let request = data.meetingRequest, request.isConfirmed == nil {
					HStack {
						Spacer()

						Text(LocaleText.sessionNeedConfirmationText)
							.font(.robotoRegular(size: 10))
							.foregroundColor(.white)

						Spacer()
					}
					.padding(.vertical, 5)
					.background(
						Capsule()
							.foregroundColor(.softYellowDinotis)
					)
					.padding(.top, 6)
				} else if let request = data.meetingRequest, !(request.isConfirmed ?? false) {
					HStack {
						Spacer()

						Text(LocaleText.sessionCancelledText)
							.font(.robotoRegular(size: 10))
							.foregroundColor(.white)

						Spacer()
					}
					.padding(.vertical, 5)
					.background(
						Capsule()
							.foregroundColor(.attentionPink)
					)
					.padding(.top, 6)
				}
                
            }
            
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
        .padding(.vertical, 25)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color("dinotis-shadow-1").opacity(0.15), radius: 10, x: 0.0, y: 0.0)
        .onTapGesture(perform: {
            isShowMenu = false
        })
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

