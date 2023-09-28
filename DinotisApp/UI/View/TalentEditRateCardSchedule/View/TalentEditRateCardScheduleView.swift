//
//  TalentEditRateCardScheduleView.swift
//  DinotisApp
//
//  Created by Gus Adi on 06/10/22.
//

import DinotisDesignSystem
import SwiftUI

struct TalentEditRateCardScheduleView: View {
    
    @ObservedObject var viewModel: TalentEditRateCardScheduleViewModel
    
    var body: some View {
        ZStack {
            Color.secondaryBackground.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                HeaderView(viewModel: viewModel)
                    .onChange(of: viewModel.timeStart, perform: { newValue in
                        viewModel.timeEnd = newValue.addingTimeInterval(TimeInterval(viewModel.duration*60))
                    })
                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 15) {
                        TitleDescriptionCardView(viewModel: viewModel)
                        
                        SetDateTimeCardView(viewModel: viewModel)
                    }
                    .padding()
                }
                
                BottomAction(viewModel: viewModel)
            }
            .onAppear {
                Task {
                    await viewModel.getMeetingDetail()
                }
            }
            
            DinotisLoadingView(.fullscreen, hide: !viewModel.isLoading)
        }
        .dinotisAlert(
            isPresent: $viewModel.isShowAlert,
            title: viewModel.alert.title,
            isError: viewModel.alert.isError,
            message: viewModel.alert.message,
            primaryButton: viewModel.alert.primaryButton,
            secondaryButton: viewModel.alert.secondaryButton
        )
        .navigationBarHidden(true)
        .navigationBarTitle("")
        .sheet(item: $viewModel.sheetType) { item in
            switch item {
            case .date:
                if #available(iOS 16.0, *) {
                    DateSheet(viewModel: viewModel, isTime: false)
                        .padding()
                        .presentationDetents([.medium, .large])
                        .dynamicTypeSize(.large)
                } else {
                    DateSheet(viewModel: viewModel, isTime: false)
                        .dynamicTypeSize(.large)
                }
            case .startTime:
                if #available(iOS 16.0, *) {
                    DateSheet(viewModel: viewModel, isTime: true)
                        .padding()
                        .presentationDetents([.medium, .large])
                        .dynamicTypeSize(.large)
                } else {
                    DateSheet(viewModel: viewModel, isTime: true)
                        .dynamicTypeSize(.large)
                }
            case .endTime:
                if #available(iOS 16.0, *) {
                    TimeEndSheet(viewModel: viewModel)
                        .padding()
                        .presentationDetents([.medium, .large])
                        .dynamicTypeSize(.large)
                } else {
                    TimeEndSheet(viewModel: viewModel)
                        .dynamicTypeSize(.large)
                }
            }
        }
    }
}

struct TalentEditRateCardScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        TalentEditRateCardScheduleView(viewModel: TalentEditRateCardScheduleViewModel(meetingID: "", backToHome: {}))
    }
}

extension TalentEditRateCardScheduleView {
    struct HeaderView: View {
        @Environment(\.dismiss) var dismiss
        
        @ObservedObject var viewModel: TalentEditRateCardScheduleViewModel
        
        var body: some View {
            ZStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image.Dinotis.arrowBackIcon
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                    })
                    .padding()
                    
                    Spacer()
                }
                
                Text(LocaleText.editVideoCallScheduleTitle)
                    .font(.robotoBold(size: 14))
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: UIScreen.main.bounds.width - 120)
            }
            .background(
                Color.secondaryBackground
            )
        }
    }
    
    struct TitleDescriptionCardView: View {
        
        @ObservedObject var viewModel: TalentEditRateCardScheduleViewModel
        
        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image.Dinotis.videoCallFormIcon
                        .resizable()
                        .scaledToFit()
                        .frame(height: 12)
                    
                    Text(LocaleText.titleDescriptionFormTitle)
                        .font(.robotoMedium(size: 12))
                        .foregroundColor(.black)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    HStack {
                        Text(viewModel.title)
                            .font(.robotoBold(size: 15))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                }
                
                HStack(spacing: 10) {
                    VStack {
                        HStack {
                            Image.Dinotis.priceTagIcon
                                .resizable()
                                .scaledToFit()
                                .frame(height: 20)
                            
                            Text(LocaleText.priceOnlyGeneralText)
                                .font(.robotoBold(size: 12))
                                .foregroundColor(.black)
                            
                            Spacer()
                        }
                        
                        HStack {
                            Image.Dinotis.coinIcon
                                .resizable()
                                .scaledToFit()
                                .frame(height: 15)
                            
                            Text(viewModel.price.toCurrency())
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.black)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .foregroundColor(Color(.systemGray5))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6).stroke(Color(.systemGray6).opacity(0.5), lineWidth: 2.0)
                        )
                    }
                    
                    VStack {
                        HStack {
                            Image.Dinotis.clockIcon
                                .resizable()
                                .scaledToFit()
                                .frame(height: 20)
                            
                            Text(LocaleText.durationOnlyGeneralText)
                                .font(.robotoBold(size: 12))
                                .foregroundColor(.black)
                            
                            Spacer()
                        }
                        
                        HStack {
                            Text(LocaleText.minuteInDuration(viewModel.duration))
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.black)
                                .padding(.horizontal)
                                .padding(.vertical, 15)
                            
                            Spacer()
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .foregroundColor(Color(.systemGray5))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6).stroke(Color(.systemGray6).opacity(0.5), lineWidth: 2.0)
                        )
                    }
                }
            }
            .padding()
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(.white)
            )
        }
    }
    
    struct SetDateTimeCardView: View {
        
        @ObservedObject var viewModel: TalentEditRateCardScheduleViewModel
        
        var body: some View {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    HStack {
                        Image.Dinotis.calendarIcon
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)
                        
                        Text(LocaleText.selectDateText)
                            .font(.robotoMedium(size: 12))
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Text(DateUtils.dateFormatter(viewModel.timeStart, forFormat: .EEEEddMMMMyyyy))
                            .font(.robotoRegular(size: 12))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Image.Dinotis.chevronBottomIcon
                            .resizable()
                            .scaledToFit()
                            .frame(height: 15)
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .padding(.horizontal)
                    .padding(.vertical, 15)
                    .onTapGesture {
                        self.viewModel.sheetType = .date
                        UIApplication.shared.endEditing()
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                    )
                }
                
                VStack(spacing: 10) {
                    HStack {
                        Image.Dinotis.clockIcon
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)
                        
                        Text(LocaleText.selectTimeText)
                            .font(.robotoMedium(size: 12))
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    
                    HStack {
                        HStack {
                            Text(DateUtils.dateFormatter(viewModel.timeStart, forFormat: .HHmm))
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Image.Dinotis.chevronBottomIcon
                                .resizable()
                                .scaledToFit()
                                .frame(height: 15)
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .padding(.horizontal)
                        .padding(.vertical, 15)
                        .onTapGesture {
                            self.viewModel.sheetType = .startTime
                            UIApplication.shared.endEditing()
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                        )
                        
                        HStack {
                            Text(DateUtils.dateFormatter(viewModel.timeEnd, forFormat: .HHmm))
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Image.Dinotis.chevronBottomIcon
                                .resizable()
                                .scaledToFit()
                                .frame(height: 15)
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .padding(.horizontal)
                        .padding(.vertical, 15)
                        .onTapGesture {
                            self.viewModel.sheetType = .endTime
                            UIApplication.shared.endEditing()
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 6).stroke(Color(.lightGray).opacity(0.3), lineWidth: 1.0)
                        )
                    }
                    
                    HStack {
                        Text(LocaleText.totalDurationLabel)
                            .font(.robotoRegular(size: 10))
                            .foregroundColor(.black)
                        +
                        Text(LocaleText.minuteInDuration(viewModel.duration))
                            .font(.robotoMedium(size: 10))
                            .foregroundColor(.DinotisDefault.primary)
                        
                        Spacer()
                    }
                }
                
            }
            .padding()
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(.white)
            )
        }
    }
    
    struct DateSheet: View {
        @ObservedObject var viewModel: TalentEditRateCardScheduleViewModel
        @State var changedTimeStart: Date = Date()
        
        let isTime: Bool
        
        var body: some View {
            VStack {
                DatePicker("", selection: $changedTimeStart, in: Date()..., displayedComponents: isTime ? .hourAndMinute : .date)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                
                Button(action: {
                    viewModel.timeStart = changedTimeStart
                    viewModel.sheetType = nil
                }, label: {
                    HStack {
                        Spacer()
                        
                        Text(LocaleText.selectTextLabel)
                            .foregroundColor(.white)
                            .font(.robotoMedium(size: 14))
                        
                        Spacer()
                    }
                    .padding(.vertical)
                    .background(Color.DinotisDefault.primary)
                })
                .clipShape(RoundedRectangle(cornerRadius: 8.0))
            }
            .onAppear {
                changedTimeStart = viewModel.timeStart
            }
        }
    }
    
    struct TimeEndSheet: View {
        @ObservedObject var viewModel: TalentEditRateCardScheduleViewModel
        @State var changedTimeEnd: Date = Date().addingTimeInterval(3600)
        
        var body: some View {
            VStack {
                DatePicker("", selection: $changedTimeEnd, in: Date()..., displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                
                Button(action: {
                    viewModel.timeEnd = changedTimeEnd
                    viewModel.sheetType = nil
                }, label: {
                    HStack {
                        Spacer()
                        
                        Text(LocaleText.selectTextLabel)
                            .foregroundColor(.white)
                            .font(.robotoMedium(size: 14))
                        
                        Spacer()
                    }
                    .padding(.vertical)
                    .background(Color.DinotisDefault.primary)
                })
                .clipShape(RoundedRectangle(cornerRadius: 8.0))
            }
            .onAppear {
                changedTimeEnd = viewModel.timeEnd
            }
        }
    }
    
    struct BottomAction: View {
        
        @Environment(\.dismiss) var dismiss
        
        @ObservedObject var viewModel: TalentEditRateCardScheduleViewModel
        
        var body: some View {
            HStack(spacing: 15) {
                Button {
                    Task {
                        await viewModel.editMeeting(successAction: {
                            dismiss()
                        })
                    }
                } label: {
                    HStack {
                        
                        Spacer()
                        
                        Text(LocaleText.eventConfirmation)
                            .font(.robotoMedium(size: 12))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.DinotisDefault.primary)
                    )
                }
            }
            .padding()
            .background(
                Color.white.edgesIgnoringSafeArea(.bottom)
            )
        }
    }
}
