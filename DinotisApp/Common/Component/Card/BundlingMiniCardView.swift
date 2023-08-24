//
//  BundlingMiniCardView.swift
//  DinotisApp
//
//  Created by Garry on 27/09/22.
//

import SwiftUI
import CurrencyFormatter
import DinotisDesignSystem
import DinotisData

struct BundlingMiniCardView: View {
    
    @Binding var meeting: MeetingDetailResponse
    @Binding var meetingIdArray: [String]
    var onTap: (() -> Void)
    
    var body: some View {
        HStack {
            Button {
                onTap()
            } label: {
                HStack {
                    Image(systemName: isSelected(arrayOfId: meetingIdArray, itemId: meeting.id.orEmpty()) ? "checkmark.circle.fill" : "circle")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.DinotisDefault.primary)
                        .frame(width: 30, height: 30)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text(meeting.title.orEmpty())
                                .font(.robotoBold(size: 12))
                                .foregroundColor(.black)
                            
                            HStack {
                                if let dateStart = meeting.startAt {
									Text(DateUtils.dateFormatter(dateStart, forFormat: .EEEEddMMMMyyyy))
                                        .font(.robotoRegular(size: 10))
                                        .foregroundColor(.black)
                                }
                                
                                Circle()
                                    .frame(width: 3, height: 3)
                                    .foregroundColor(.black)
                                
                                if let timeStart =  meeting.startAt,
                                     let timeEnd = meeting.endAt {
                                    Text("\(DateUtils.dateFormatter(timeStart, forFormat: .HHmm)) - \(DateUtils.dateFormatter(timeEnd, forFormat: .HHmm))")
                                        .font(.robotoRegular(size: 10))
                                        .foregroundColor(.black)
                                }
                            }
                            
                            HStack {
                                Image.Dinotis.priceTagIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                
                                Text("Rp\(meeting.price.orEmpty().toPriceFormat())")
                                    .font(.robotoBold(size: 12))
                                    .foregroundColor(.DinotisDefault.primary)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)

                }
            }
        }
    }
    
    private func isSelected(arrayOfId: [String], itemId: String) -> Bool {
        arrayOfId.contains {
            $0 == itemId
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
