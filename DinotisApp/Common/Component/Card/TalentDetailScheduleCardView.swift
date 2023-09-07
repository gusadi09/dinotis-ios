//
//  TalentDetailScheduleCardView.swift
//  DinotisApp
//
//  Created by Gus Adi on 20/08/21.
//

import SwiftUI
import DinotisData
import CurrencyFormatter
import DinotisDesignSystem

struct TalentDetailScheduleCardView: View {
	@Binding var data: MeetingDetailResponse
	
	@State var isShowMenu = false
    @State var isShowCollabList = false
	
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
							.font(.robotoRegular(size: 12))
							.foregroundColor(.black)
							.padding(.vertical, 3)
							.padding(.horizontal, 8)
							.background(Color(.systemGray5))
							.clipShape(Capsule())
					} else {
						if data.meetingRequest != nil && data.startedAt == nil {
                            Button {
                                onTapEdit()
                            } label: {
                                HStack {
                                    Text(LocaleText.edit)
                                        .font(.robotoMedium(size: 12))
                                        .foregroundColor(.DinotisDefault.primary)
                                        
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal)
                                .background(Color.secondaryViolet)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.DinotisDefault.primary, lineWidth: 1)
                                )
                            }
						} else if data.meetingRequest != nil && data.startedAt != nil {
							Button {
								onTapEnd()
							} label: {
								HStack {
									Text(NSLocalizedString("finish_video_call_detail", comment: ""))
										.font(.robotoMedium(size: 12))
										.foregroundColor(.DinotisDefault.primary)

								}
								.padding(.vertical, 8)
								.padding(.horizontal)
								.background(Color.secondaryViolet)
								.cornerRadius(8)
								.overlay(
									RoundedRectangle(cornerRadius: 8)
										.stroke(Color.DinotisDefault.primary, lineWidth: 1)
								)
							}
						} else if data.meetingRequest == nil {
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
                                                .font(.robotoMedium(size: 12))
                                                .foregroundColor(.black)
                                        }
                                    })
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .foregroundColor(.DinotisDefault.primary)
                                    .font(.system(size: 26))
                                    .padding(6)
                            }
                        }
					}
				}
				.padding(.bottom, 10)
				
				VStack(alignment: .leading, spacing: 5) {
					Text(data.title ?? "")
                        .font(.robotoBold(size: 14))
						.foregroundColor(.black)
                    
                    Text(data.description ?? "")
                        .font(.robotoRegular(size: 12))
                        .foregroundColor(.black)
                        .padding(.bottom, 10)
                }
                
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
					
					if let timeStart = data.startAt,
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
                        
                        Text("\(String.init((data.participants).orZero()))/\(data.slots.orZero()) \(NSLocalizedString("participant", comment: ""))")
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
                }
                
                if !(data.meetingCollaborations ?? []).isEmpty {
                    VStack(alignment: .center, spacing: 15) {
                        Capsule()
                            .frame(height: 1)
                            .foregroundColor(.gray)
                            .opacity(0.2)
                        
                        HStack {
                            Text(NSLocalizedString("detail_participant_label", comment: ""))
                                .font(.robotoBold(size: 12))
                                .foregroundColor(.black)
                            
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach((data.meetingCollaborations ?? []).prefix(3), id: \.id) { item in
                                HStack(spacing: 10) {
                                    ImageLoader(url: (item.user?.profilePhoto).orEmpty(), width: 40, height: 40)
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                    
                                    HStack(spacing: 5) {
                                        Text((item.user?.name).orEmpty())
                                            .lineLimit(1)
                                            .font(.robotoBold(size: 14))
                                        
                                        if item.declinedAt != nil && item.approvedAt == nil {
                                            Text("(\(LocalizableText.rejectedText))")
                                                .font(.robotoBold(size: 14))
                                                .lineLimit(1)
                                                .foregroundColor(.red)
                                        } else if item.declinedAt == nil && item.approvedAt != nil {
                                            Text("(\(LocalizableText.acceptedCollab))")
                                                .font(.robotoBold(size: 14))
                                                .lineLimit(1)
                                                .foregroundColor(.DinotisDefault.green)
                                        } else {
                                            Text("(\(LocalizableText.waitingText))")
                                                .font(.robotoBold(size: 14))
                                                .lineLimit(1)
                                                .foregroundColor(.DinotisDefault.orange)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                            }
                            
                            if (data.meetingCollaborations ?? []).count > 3 {
                                Button {
                                    isShowCollabList.toggle()
                                } label: {
                                    Text(LocalizableText.searchSeeAllLabel)
                                        .font(.robotoBold(size: 12))
                                        .foregroundColor(.DinotisDefault.primary)
                                        .underline()
                                }
                            }
                        }
                    }
                    .padding(.top, 8)
                }
				
				VStack(alignment: .center, spacing: 15) {
					Capsule()
						.frame(height: 1)
						.foregroundColor(.gray)
						.opacity(0.2)
					
					if data.participants.orZero() == 0 {
						HStack {
							Text(NSLocalizedString("empty_participant", comment: ""))
                                .font(.robotoRegular(size: 12))
								.foregroundColor(.black)
						}
					} else {
						HStack {
                            Text(LocalizableText.participant)
								.font(.robotoBold(size: 12))
								.foregroundColor(.black)
							
							Spacer()
						}

                        ForEach((data.participantDetails ?? []).prefix(4), id: \.id) { item in
                            VStack {
                                HStack {
                                    ProfileImageContainer(profilePhoto: .constant(item.profilePhoto), name: .constant(item.name), width: 40, height: 40)
                                    
                                    Text(item.name.orEmpty())
                                        .font(.robotoMedium(size: 14))
                                        .foregroundColor(.black)
                                    
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
                        }
                        
                        if data.participants.orZero() > 4 {
                            Text(LocaleText.andMoreParticipant(data.participants.orZero()-4))
                                .font(.robotoBold(size: 12))
                                .foregroundColor(.black)
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
        .sheet(isPresented: $isShowCollabList, content: {
            if #available(iOS 16.0, *) {
                SelectedCollabCreatorView(isEdit: false, arrUsername: .constant((data.meetingCollaborations ?? []).compactMap({
                    $0.username
                })), arrTalent: .constant(data.meetingCollaborations ?? [])) {
                    isShowCollabList = false
                }
                .presentationDetents([.medium, .large])
                .dynamicTypeSize(.large)
            } else {
                SelectedCollabCreatorView(isEdit: false, arrUsername: .constant((data.meetingCollaborations ?? []).compactMap({
                    $0.username
                })), arrTalent: .constant(data.meetingCollaborations ?? [])) {
                    isShowCollabList = false
                }
                .dynamicTypeSize(.large)
            }
        })
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
