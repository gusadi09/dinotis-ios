//
//  RequestCardView.swift
//  DinotisApp
//
//  Created by Garry on 07/10/22.
//

import SwiftUI
import DinotisData
import DinotisDesignSystem

struct RequestCardView: View {
    
	let user: UserResponse?
    let item: MeetingRequestData?
    
    var onTapDecline: () -> Void
    var onTapAccept: () -> Void
    
    @State private var isShowMore = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(LocalizableText.ratecardRequestedTime)
                    .font(.robotoRegular(size: 12))
                
                Spacer()
                
                if let date = item?.requestAt {
                    Text(formattedDate(date: date))
                        .font(.robotoBold(size: 12))
                } else {
                    Text(LocalizableText.anytimeLabel)
                        .font(.robotoBold(size: 12))
                }
            }
            .foregroundColor(.DinotisDefault.darkPrimary)
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                    DinotisImageLoader(urlString: (user?.profilePhoto).orEmpty())
                        .frame(width: 48, height: 48)
                        .cornerRadius(12)
                    
                    VStack(alignment: .leading) {
                        Text((user?.name).orEmpty())
                            .font(.robotoBold(size: 14))
                            .lineLimit(2)
                            .foregroundColor(.DinotisDefault.black1)
                        
                        Text(countHourTime(time: (item?.createdAt).orCurrentDate()))
                            .font(.robotoRegular(size: 10))
                            .foregroundColor(.DinotisDefault.black2)
                    }
                    .multilineTextAlignment(.leading)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(LocalizableText.tabSession)
                            .font(.robotoMedium(size: 10))
                            .foregroundColor(.DinotisDefault.black3)
                            .multilineTextAlignment(.leading)
                        
                        Text((item?.rateCard?.title).orEmpty())
                            .multilineTextAlignment(.leading)
                            .font(.robotoBold(size: 14))
                            .foregroundColor(.DinotisDefault.black2)
                    }
                    
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(LocalizableText.noteForCreatorTitle)
                                .font(.robotoMedium(size: 10))
                                .foregroundColor(.DinotisDefault.black3)
                                .multilineTextAlignment(.leading)
                            
                            Text((item?.message).orEmpty())
                                .multilineTextAlignment(.leading)
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.DinotisDefault.black2)
                                .lineLimit(isShowMore ? nil : 3)
                        }
                        
                        Button {
                            withAnimation {
                                isShowMore.toggle()
                            }
                        } label: {
                            Text(isShowMore ?
                                 LocalizableText.bookingRateCardHideFullText : LocalizableText.bookingRateCardShowFullText
                            )
                            .multilineTextAlignment(.leading)
                            .font(.robotoBold(size: 12))
                            .foregroundColor(.DinotisDefault.primary)
                        }
                        .isHidden((item?.message).orEmpty().count < 150, remove: (item?.message).orEmpty().count < 150)
                    }
                }
                
                HStack(spacing: 8) {
                    Image.sessionCardTimeSolidIcon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                    
                    Text(LocalizableText.minuteInDuration((item?.rateCard?.duration).orZero()))
                        .multilineTextAlignment(.leading)
                        .font(.robotoRegular(size: 12))
                        .foregroundColor(.DinotisDefault.black2)
                    
                    Circle()
                        .frame(width: 3, height: 3)
                        .foregroundColor(.DinotisDefault.black2)
                    
                    Image.sessionCardCoinYellowPurpleIcon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                    
                    Text((item?.rateCard?.price?.toDecimal()).orEmpty())
                        .multilineTextAlignment(.leading)
                        .font(.robotoRegular(size: 12))
                        .foregroundColor(.DinotisDefault.black2)
                }
                
                if item?.isAccepted == nil {
                    HStack(spacing: 8) {
                        Button {
                            onTapDecline()
                        } label: {
                            HStack {
                                Spacer()
                                Text(LocalizableText.decline)
                                    .foregroundColor(.DinotisDefault.black2)
                                    .font(.robotoBold(size: 12))
                                Spacer()
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 7)
                                    .foregroundColor(.DinotisDefault.brightPrimary)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 7)
                                    .stroke(Color.DinotisDefault.primary, lineWidth: 0.8)
                            )
                        }

                        Button {
                            onTapAccept()
                        } label: {
                            HStack {
                                Spacer()
                                Text(LocalizableText.accept)
                                    .foregroundColor(.white)
                                    .font(.robotoBold(size: 12))
                                Spacer()
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 7)
                                    .foregroundColor(.DinotisDefault.primary)
                            )
                        }
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white)
            .cornerRadius(16)
        }
        .background(
            Color.DinotisDefault.lightPrimary
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .inset(by: 0.5)
                .stroke(Color(red: 0.95, green: 0.89, blue: 1), lineWidth: 1)
        )
    }
    
    private func formattedDate(date: Date) -> String {
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMMM yyyy | HH:mm"
            return formatter
        }()
        
        return dateFormatter.string(from: date)
    }
    
    private func countHourTime(time: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = Locale.current
        return formatter.localizedString(for: time, relativeTo: Date())
    }
}

struct DummyRequestSession {
    let title: String = "Ngobrol bareng aku yuk!"
    let desc: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Et, tellus porta commodo at sed."
    let requestedAt: String = "2022-10-08T16:10:00.000Z"
    let duration: Int = 60
    let price: Double = 300000
}
