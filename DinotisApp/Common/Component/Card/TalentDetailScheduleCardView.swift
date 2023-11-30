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
    @State var isTextComplete = false
    @ObservedObject var stateObservable = StateObservable.shared
    
    var onTapEdit: (() -> Void)
    
    var onTapDelete: (() -> Void)
    
    var onTapEnd: (() -> Void)
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 20) {
                if data.endedAt != nil {
                    Text(LocalizableText.stepSessionDone)
                        .multilineTextAlignment(.center)
                        .font(.robotoBold(size: 12))
                        .foregroundColor(.DinotisDefault.black2)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(
                            Capsule()
                                .foregroundColor(.DinotisDefault.black3.opacity(0.5))
                        )
                } else if data.meetingRequest != nil && !(data.meetingRequest?.isConfirmed ?? false) {
                    Text(LocalizableText.creatorNotSetScheduleStatus)
                        .multilineTextAlignment(.center)
                        .font(.robotoBold(size: 12))
                        .foregroundColor(.DinotisDefault.primary)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(
                            Capsule()
                                .foregroundColor(.DinotisDefault.lightPrimary)
                        )
                } else if data.meetingRequest != nil && (data.meetingRequest?.isConfirmed ?? false) && data.startAt == nil {
                    Text(LocalizableText.creatorNotSetScheduleStatus)
                        .multilineTextAlignment(.center)
                        .font(.robotoBold(size: 12))
                        .foregroundColor(.DinotisDefault.primary)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(
                            Capsule()
                                .foregroundColor(.DinotisDefault.lightPrimary)
                        )
                } else if data.startAt != nil {
                    Text(LocalizableText.creatorScheduledStatus)
                        .multilineTextAlignment(.center)
                        .font(.robotoBold(size: 12))
                        .foregroundColor(.DinotisDefault.primary)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(
                            Capsule()
                                .foregroundColor(.DinotisDefault.lightPrimary)
                        )
                } else if let cancelled = data.meetingRequest?.isAccepted, data.meetingRequest != nil && !cancelled {
                    Text(LocalizableText.creatorCancelledStatus)
                        .multilineTextAlignment(.center)
                        .font(.robotoBold(size: 12))
                        .foregroundColor(.DinotisDefault.red)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(
                            Capsule()
                                .foregroundColor(.DinotisDefault.lightRed)
                        )
                }
                
                VStack(alignment: .leading) {
                    
                    HStack(spacing: 15) {
                        DinotisImageLoader(urlString: (data.user?.profilePhoto).orEmpty())
                            .scaledToFill()
                            .frame(width: 48, height: 48)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        if data.user?.isVerified ?? false {
                            Text("\((data.user?.name).orEmpty()) \(Image.sessionCardVerifiedIcon)")
                                .font(.robotoBold(size: 14))
                                .foregroundColor(.black)
                        } else {
                            Text("\((data.user?.name).orEmpty())")
                                .font(.robotoBold(size: 14))
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                        
                        if data.endedAt == nil {
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
                                .isHidden(true, remove: true)
                            } else if data.meetingRequest != nil && data.startedAt != nil {
                                Button {
                                    onTapEnd()
                                } label: {
                                    HStack {
                                        Text(LocalizableText.videoCallEndSessionButton)
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
                    
                    VStack(alignment:.leading, spacing: 5) {
                        Text((data.title).orEmpty())
                            .font(.robotoBold(size: 16))
                            .foregroundColor(.black)
                        
                        VStack(alignment: .leading) {
                            Text((data.description).orEmpty())
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                                .lineLimit(isTextComplete ? nil : 3)
                            
                            HStack {
                                Button {
                                    withAnimation {
                                        isTextComplete.toggle()
                                    }
                                } label: {
                                    Text(isTextComplete ? LocalizableText.bookingRateCardHideFullText : LocalizableText.bookingRateCardShowFullText)
                                        .font(.robotoMedium(size: 12))
                                        .foregroundColor(.DinotisDefault.primary)
                                }
                                
                                Spacer()
                            }
                            .isHidden(
                                (data.description).orEmpty().count < 150,
                                remove: (data.description).orEmpty().count < 150
                            )
                        }
                    }
                    
                    Divider()
                        .padding(.top, 10)
                        .padding(.bottom, 5)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 10) {
                            Image.sessionCardDateIcon
                                .resizable()
                                .scaledToFit()
                                .frame(height: 20)
                            
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
                            Image.sessionCardTimeSolidIcon
                                .resizable()
                                .scaledToFit()
                                .frame(height: 18)
                            
                            if let timeStart = data.startAt,
                               let timeEnd = data.endAt {
                                Text("\(DateUtils.dateFormatter(timeStart, forFormat: .HHmm)) - \(DateUtils.dateFormatter(timeEnd, forFormat: .HHmm))")
                                    .font(.robotoRegular(size: 12))
                                    .foregroundColor(.black)
                            } else {
                                Text(LocalizableText.unconfirmedText)
                                    .font(.robotoRegular(size: 12))
                                    .foregroundColor(.black)
                            }
                        }
                        
                        HStack(spacing: 10) {
                            Image.sessionCardPersonSolidIcon
                                .resizable()
                                .scaledToFit()
                                .frame(height: 20)
                            
                            Text("\(String.init(data.participants.orZero()))/\(String.init((data.slots).orZero())) \(LocalizableText.participant)")
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.black)
                            
                            Text((!(data.isPrivate ?? false)) ? LocalizableText.groupSessionLabelWithEmoji : LocalizableText.privateSessionLabelWithEmoji)
                                .font(.robotoBold(size: 10))
                                .foregroundColor(.DinotisDefault.primary)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 5)
                                .background(Color.white)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color.DinotisDefault.primary, lineWidth: 1.0)
                                )
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
