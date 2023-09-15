//
//  TalentScheduleCardView.swift
//  DinotisApp
//
//  Created by Garry on 01/10/22.
//

import SwiftUI
import CurrencyFormatter
import DinotisDesignSystem
import DinotisData

enum CreatorSessionStatus {
    case ready
    case waitingNewSchedule
    case unconfirmed
    case canceled
    case completed
}

struct TalentScheduleCardView: View {
    @State var isShowMenu = false
    @Binding var data: MeetingDetailResponse
    @State var status: CreatorSessionStatus = .ready
    @State var isShowCollabList = false

	let isBundle: Bool
    
    var onTapButton: (() -> Void)
    
    var onTapEdit: (() -> Void)
    
    var onTapDelete: (() -> Void)
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    switch status {
                    case .ready:
                        Image("ic-video-conf")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 32)
                    default:
                        Text(statusText())
                            .font(.robotoMedium(size: 12))
                            .foregroundColor(statusColor())
                            .padding(.vertical, 6)
                            .padding(.horizontal, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 60)
                                    .fill(statusColor().opacity(0.1))
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 60)
                                    .inset(by: 0.5)
                                    .stroke(statusColor(), lineWidth: 1)
                            }
                    }
                    
                    Spacer()
                    
                    switch status {
                    case .canceled:
                        EmptyView()
                    case .completed:
                        EmptyView()
                    default:
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
                                Image(systemName: "ellipsis")
                                    .foregroundColor(.DinotisDefault.primary)
                                    .imageScale(.large)
                                    .padding()
                            }

                        }
                    }
                    
                }
                
                Text(data.title.orEmpty())
                    .font(.robotoBold(size: 14))
                    .foregroundColor(.black)
                
                Text(data.description.orEmpty())
                    .font(.robotoRegular(size: 12))
                    .foregroundColor(.black)
                    .padding(.bottom, 3)
                
                Group {
                    if !(data.meetingCollaborations ?? []).isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("\(LocalizableText.withText):")
                                .font(.robotoMedium(size: 12))
                                .foregroundColor(.black)
                            
                            ForEach((data.meetingCollaborations ?? []).prefix(3), id: \.id) { item in
                                HStack(spacing: 10) {
                                    ImageLoader(url: (item.user?.profilePhoto).orEmpty(), width: 25, height: 25)
                                        .frame(width: 25, height: 25)
                                        .clipShape(Circle())
                                    
                                    HStack(spacing: 5) {
                                        Text((item.user?.name).orEmpty())
                                            .lineLimit(1)
                                            .font(.robotoBold(size: 12))
                                        
                                        if item.declinedAt != nil && item.approvedAt == nil {
                                            Text("(\(LocalizableText.rejectedText))")
                                                .font(.robotoBold(size: 12))
                                                .lineLimit(1)
                                                .foregroundColor(.red)
                                        } else if item.declinedAt == nil && item.approvedAt != nil {
                                            Text("(\(LocalizableText.acceptedCollab))")
                                                .font(.robotoBold(size: 12))
                                                .lineLimit(1)
                                                .foregroundColor(.DinotisDefault.green)
                                        } else {
                                            Text("(\(LocalizableText.waitingText))")
                                                .font(.robotoBold(size: 12))
                                                .lineLimit(1)
                                                .foregroundColor(.DinotisDefault.orange)
                                        }
                                    }
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
                }
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
                        
                        if !(data.isPrivate ?? false) && !(data.isLiveStreaming ?? false) {
                            Text(LocalizableText.groupSessionLabelWithEmoji)
                                .font(.robotoRegular(size: 12))
                                .fontWeight(.semibold)
                                .foregroundColor(.DinotisDefault.darkPrimary)
                                .padding(.vertical, 5)
                                .padding(.horizontal)
                                .background(Color.DinotisDefault.lightPrimary)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color.DinotisDefault.primary, lineWidth: 1.0)
                                )
                            
                        } else if data.isLiveStreaming ?? false {
                            Text(LocaleText.liveStreamText)
                                .font(.robotoRegular(size: 12))
                                .fontWeight(.semibold)
                                .foregroundColor(.DinotisDefault.darkPrimary)
                                .padding(.vertical, 5)
                                .padding(.horizontal)
                                .background(Color.DinotisDefault.lightPrimary)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color.DinotisDefault.primary, lineWidth: 1.0)
                                )
                        } else {
                            Text(LocalizableText.privateSessionLabelWithEmoji)
                                .font(.robotoRegular(size: 12))
                                .fontWeight(.semibold)
                                .foregroundColor(.DinotisDefault.darkPrimary)
                                .padding(.vertical, 5)
                                .padding(.horizontal)
                                .background(Color.DinotisDefault.lightPrimary)
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
                    Image.sessionCardCoinYellowPurpleIcon
                        .resizable()
                        .scaledToFit()
                        .frame(height: 15)
                    
                    if data.price == "0" {
                        Text(NSLocalizedString("free_text", comment: ""))
                            .font(.robotoBold(size: 14))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                    } else {
                        Text(data.price.orEmpty().toPriceFormat())
                            .font(.robotoBold(size: 14))
                            .foregroundColor(.black)
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
                            .background(Color.DinotisDefault.lightPrimary)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.DinotisDefault.primary, lineWidth: 1.0)
                            )
                            .multilineTextAlignment(.center)
                    })
                    
                    
                }
                .padding(.top, 10)
            }
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
        .buttonStyle(.plain)
        .padding(.horizontal)
        .padding(.vertical, 25)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color("dinotis-shadow-1").opacity(0.1), radius: 8, x: 0.0, y: 0.0)
        .onTapGesture(perform: {
            isShowMenu = false
        })
        .onDisappear {
            isShowMenu = false
        }
    }
    
    private func statusText() -> String {
        switch status {
        case .waitingNewSchedule:
            return LocalizableText.statusWaitingNewSession
        case .unconfirmed:
            return LocalizableText.statusUnconfirmedSession
        case .canceled:
            return LocalizableText.statusCanceledSession
        case .completed:
            return LocalizableText.statusCompletedSession
        default:
            return ""
        }
    }
    
    private func statusColor() -> Color {
        switch status {
        case .waitingNewSchedule:
            return .DinotisDefault.orange
        case .unconfirmed:
            return .DinotisDefault.primary
        case .canceled:
            return .DinotisDefault.red
        case .completed:
            return .DinotisDefault.black1
        default:
            return .DinotisDefault.primary
        }
    }
    
    private func countHourTime(time: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = Locale.current
        return formatter.localizedString(for: time, relativeTo: Date())
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

