//
//  BundlingMiniCardView.swift
//  DinotisApp
//
//  Created by Garry on 27/09/22.
//

import SwiftUI
import CurrencyFormatter

struct BundlingMiniCardView: View {
    
    @State var isSelected = false
    @Binding var bundlingData: AvailableMeeting
    
    var body: some View {
        HStack {
            Button {
                isSelected.toggle()
            } label: {
                HStack {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.primaryViolet)
                        .frame(width: 30, height: 30)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text(bundlingData.title.orEmpty())
                                .font(.montserratBold(size: 12))
                                .foregroundColor(.black)
                            
                            HStack {
                                if let dateStart = dateISOFormatter.date(from: bundlingData.startAt.orEmpty()) {
                                    Text(dateFormatter.string(from: dateStart))
                                        .font(.montserratRegular(size: 10))
                                        .foregroundColor(.black)
                                }
                                
                                Circle()
                                    .frame(width: 3, height: 3)
                                    .foregroundColor(.black)
                                
                                if let timeStart =  bundlingData.startAt.orEmpty().toDate(format: .utcV2),
                                     let timeEnd = bundlingData.endAt.orEmpty().toDate(format: .utcV2) {
                                    Text("\(timeStart.toString(format: .HHmm)) - \(timeEnd.toString(format: .HHmm))")
                                        .font(.montserratRegular(size: 10))
                                        .foregroundColor(.black)
                                }
                            }
                            
                            HStack {
                                Image.Dinotis.priceTagIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                
                                Text("Rp\(bundlingData.price.orEmpty().toPriceFormat())")
                                    .font(.montserratBold(size: 12))
                                    .foregroundColor(.primaryViolet)
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
