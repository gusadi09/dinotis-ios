//
//  TalentProfileDetailView+Component.swift
//  DinotisApp
//
//  Created by hilmy ghozy on 19/04/22.
//

import Foundation
import SwiftUINavigation
import SwiftUI
import QGrid
import StoreKit
import DinotisDesignSystem
import DinotisData

extension TalentProfileDetailView {
    
    struct SectionHeader: View {
        
        @ObservedObject var viewModel: TalentProfileDetailViewModel
        
        var body: some View {
            Group {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    ScrollViewReader { reader in
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 0) {
                                Button {
                                    withAnimation {
                                        viewModel.tabNumb = 0
                                        reader.scrollTo(0)
                                    }
                                    
                                } label: {
                                    VStack(spacing: 25) {
                                        HStack(alignment: .center) {
                                            Text(LocalizableText.talentDetailInformation)
                                                .font(viewModel.tabNumb == 0 ? .robotoBold(size: 14) : .robotoRegular(size: 14))
                                                .foregroundColor(.black)
                                        }
                                        .background(Color.clear)
                                        .padding(.horizontal)
                                        .padding([.bottom], -5)
                                        
                                        Rectangle()
                                            .frame(height: 1.5, alignment: .center)
                                            .foregroundColor(viewModel.tabNumb == 0 ? .DinotisDefault.primary : Color(.purple).opacity(0.1))
                                            .padding([.leading], 5)
                                        
                                    }
                                    .frame(width: 120)
                                }
                                .id(0)
                                
                                Button {
                                    withAnimation {
                                        viewModel.tabNumb = 1
                                        reader.scrollTo(1)
                                    }
                                } label: {
                                    VStack(spacing: 25) {
                                        HStack(alignment: .center) {
                                            Text(viewModel.talentData?.management != nil ? LocalizableText.creatorTitle : LocalizableText.talentDetailSession)
                                                .font(viewModel.tabNumb == 1 ? .robotoBold(size: 14) : .robotoRegular(size: 14))
                                                .foregroundColor(.black)
                                        }
                                        .background(Color.clear)
                                        .padding(.horizontal)
                                        .padding([.bottom], -5)
                                        
                                        Rectangle()
                                            .frame(height: 1.5, alignment: .center)
                                            .foregroundColor(viewModel.tabNumb == 1 ? .DinotisDefault.primary : Color(.purple).opacity(0.1))
                                    }
                                    .frame(width: 120)
                                }
                                .id(1)
                                
                                Button {
                                    withAnimation {
                                        viewModel.tabNumb = 2
                                        reader.scrollTo(2)
                                    }
                                } label: {
                                    VStack(spacing: 25) {
                                        HStack(alignment: .center) {
                                            Text(viewModel.talentData?.management == nil ? LocalizableText.talentDetailServices : LocalizableText.talentDetailSession)
                                                .font(viewModel.tabNumb == 2 ? .robotoBold(size: 14) : .robotoRegular(size: 14))
                                                .foregroundColor(.black)
                                        }
                                        .background(Color.clear)
                                        .padding(.horizontal)
                                        .padding([.bottom], -5)
                                        
                                        Rectangle()
                                            .frame(height: 1.5, alignment: .center)
                                            .foregroundColor(viewModel.tabNumb == 2 ? .DinotisDefault.primary : Color(.purple).opacity(0.1))
                                        
                                    }
                                    .frame(width: 120)
                                }
                                .id(2)
                                
                                if viewModel.talentData?.management == nil {
                                    Button {
                                        withAnimation {
                                            viewModel.tabNumb = 3
                                            reader.scrollTo(3)
                                        }
                                    } label: {
                                        VStack(spacing: 25) {
                                            HStack(alignment: .center) {
                                                Text(LocalizableText.talentDetailReviews)
                                                    .font(viewModel.tabNumb == 3 ? .robotoBold(size: 14) : .robotoRegular(size: 14))
                                                    .foregroundColor(.black)
                                            }
                                            .background(Color.clear)
                                            .padding(.horizontal)
                                            .padding([.bottom], -5)
                                            
                                            Rectangle()
                                                .frame(height: 1.5, alignment: .center)
                                                .foregroundColor(viewModel.tabNumb == 3 ? .DinotisDefault.primary : Color(.purple).opacity(0.1))
                                                .padding([.trailing], 4)
                                            
                                        }
                                        .frame(width: 120)
                                    }
                                    .id(3)
                                }
                            }
                            .padding([.leading, .trailing, .top])
                        }
                        .multilineTextAlignment(.center)
                    }
                } else {
                    HStack(spacing: 0) {
                        Button {
                            withAnimation {
                                viewModel.tabNumb = 0
                            }
                            
                        } label: {
                            VStack(spacing: 25) {
                                HStack(alignment: .center) {
                                    
                                    Spacer()
                                    
                                    Text(LocalizableText.talentDetailInformation)
                                        .font(viewModel.tabNumb == 0 ? .robotoBold(size: 14) : .robotoRegular(size: 14))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                }
                                .background(Color.clear)
                                .padding(.horizontal)
                                .padding([.bottom], -5)
                                
                                Rectangle()
                                    .frame(height: 1.5, alignment: .center)
                                    .foregroundColor(viewModel.tabNumb == 0 ? .DinotisDefault.primary : Color(.purple).opacity(0.1))
                                    .padding([.leading], 5)
                                
                            }
                        }
                        .id(0)
                        
                        Button {
                            withAnimation {
                                viewModel.tabNumb = 1
                            }
                        } label: {
                            VStack(spacing: 25) {
                                HStack(alignment: .center) {
                                    
                                    Spacer()
                                    
                                    Text(viewModel.talentData?.management == nil ? LocalizableText.talentDetailSession : LocalizableText.creatorTitle)
                                        .font(viewModel.tabNumb == 1 ? .robotoBold(size: 14) : .robotoRegular(size: 14))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                }
                                .background(Color.clear)
                                .padding(.horizontal)
                                .padding([.bottom], -5)
                                
                                Rectangle()
                                    .frame(height: 1.5, alignment: .center)
                                    .foregroundColor(viewModel.tabNumb == 1 ? .DinotisDefault.primary : Color(.purple).opacity(0.1))
                                
                            }
                        }
                        .id(1)
                        
                        Button {
                            withAnimation {
                                viewModel.tabNumb = 2
                            }
                        } label: {
                            VStack(spacing: 25) {
                                HStack(alignment: .center) {
                                    
                                    Spacer()
                                    
                                    Text(viewModel.talentData?.management == nil ? LocalizableText.talentDetailServices : LocalizableText.talentDetailSession)
                                        .font(viewModel.tabNumb == 2 ? .robotoBold(size: 14) : .robotoRegular(size: 14))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                }
                                .background(Color.clear)
                                .padding(.horizontal)
                                .padding([.bottom], -5)
                                
                                Rectangle()
                                    .frame(height: 1.5, alignment: .center)
                                    .foregroundColor(viewModel.tabNumb == 2 ? .DinotisDefault.primary : Color(.purple).opacity(0.1))
                                
                            }
                        }
                        .id(2)
                        
                        if viewModel.talentData?.management == nil {
                            Button {
                                withAnimation {
                                    viewModel.tabNumb = 3
                                }
                            } label: {
                                VStack(spacing: 25) {
                                    HStack(alignment: .center) {
                                        
                                        Spacer()
                                        
                                        Text(LocalizableText.talentDetailReviews)
                                            .font(viewModel.tabNumb == 3 ? .robotoBold(size: 14) : .robotoRegular(size: 14))
                                            .foregroundColor(.black)
                                        
                                        Spacer()
                                        
                                    }
                                    .background(Color.clear)
                                    .padding(.horizontal)
                                    .padding([.bottom], -5)
                                    
                                    Rectangle()
                                        .frame(height: 1.5, alignment: .center)
                                        .foregroundColor(viewModel.tabNumb == 3 ? .DinotisDefault.primary : Color(.purple).opacity(0.1))
                                        .padding([.trailing], 5)
                                    
                                }
                            }
                            .id(3)
                        }
                    }
                    .multilineTextAlignment(.center)
                    .padding([.leading, .trailing, .top])
                }
            }
            .padding(.top, 5)
            .padding(.bottom, 10)
            .background(
                RoundedCorner(radius: 20, corners: [.topLeft, .topRight])
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.01), radius: 2, x: 0, y: -5)
            )
        }
    }
    
    struct EmptyScheduleTalentProfile: View {
        
        @ObservedObject var viewModel: TalentProfileDetailViewModel
        
        var body: some View {
            HStack {
                Spacer()
                VStack(spacing: 30) {
                    VStack(spacing: 18) {
                        Image.talentProfileComingSoonImage
                            .resizable()
                            .scaledToFit()
                            .frame(
                                height: 198,
                                alignment: .center
                            )
                        
                        VStack(spacing: 10) {
                            Text(LocaleText.noScheduleLabel)
                                .font(.robotoBold(size: 14))
                                .foregroundColor(.black)
                            
                            Text(LocaleText.talentDetailEmptySchedule)
                                .font(.robotoRegular(size: 12))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black)
                        }
                    }
                    
                    DinotisPrimaryButton(
                        text: LocalizableText.requestSession,
                        type: .adaptiveScreen,
                        textColor: .white,
                        bgColor: .DinotisDefault.primary
                    ) {
                        viewModel.showingRequest.toggle()
                    }
                }
                Spacer()
            }
            .padding()
            .padding(.top, 30)
        }
        
    }
    
    struct ScheduleTalent: View {
        
        @ObservedObject var viewModel: TalentProfileDetailViewModel
        @State var isLoading = false
        
        @Binding var tabValue: TabRoute
        
        var body: some View {
            
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 15)
                    .foregroundColor(.DinotisDefault.primary)
                
                Text(LocaleText.generalFilterSchedule)
                    .font(.robotoMedium(size: 12))
                    .foregroundColor(.DinotisDefault.primary)
                
                Spacer()
                
                Menu {
                    Picker(selection: $viewModel.filterSelection) {
                        ForEach(viewModel.filterOption, id: \.id) { item in
                            Text(item.label.orEmpty())
                                .tag(item.label.orEmpty())
                        }
                    } label: {
                        EmptyView()
                    }
                } label: {
                    HStack(spacing: 10) {
                        Text(viewModel.filterSelection)
                            .font(.robotoRegular(size: 12))
                            .foregroundColor(.black)
                        
                        Image(systemName: "chevron.down")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 5)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.secondaryViolet)
                    )
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.DinotisDefault.primary, lineWidth: 1))
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            
            if viewModel.meetingData.unique().isEmpty && viewModel.bundlingData.unique().isEmpty {
                TalentProfileDetailView.EmptyScheduleTalentProfile(viewModel: viewModel)
            } else {
                if !viewModel.bundlingData.unique().isEmpty {
                    Text(LocalizableText.bundlingText)
                        .font(.robotoBold(size: 18))
                        .padding(.horizontal)
                }
                
                ForEach(viewModel.bundlingData.unique(), id: \.id) { item in
                    SessionCard(
                        with: SessionCardModel(
                            title: item.title.orEmpty(),
                            date: "",
                            startAt: "",
                            endAt: "",
                            isPrivate: false,
                            isVerified: (item.user?.isVerified) ?? false,
                            photo: (item.user?.profilePhoto).orEmpty(),
                            name: (item.user?.name).orEmpty(),
                            color: item.background,
                            description: item.description.orEmpty(),
                            session: item.session.orZero(),
                            price: item.price.orEmpty(),
                            participants: 0,
                            isActive: item.isActive.orFalse(),
                            type: .bundling,
                            isAlreadyBooked: item.isAlreadyBooked ?? false
                        )
                    ) {
                        if item.isAlreadyBooked ?? false {
                            viewModel.backToHome()
                            tabValue = .agenda
                        } else {
                            viewModel.routeToBundlingDetail(bundleId: item.id.orEmpty(), meetingArray: item.meetings ?? [], isActive: item.isActive.orFalse())
                        }
                    } visitProfile: {
                        
                    }
                    .grayscale(item.isActive.orFalse() ? 0 : 1)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    .buttonStyle(.plain)
                }
                
                if !viewModel.meetingData.unique().isEmpty {
                    Text(viewModel.filterSelection)
                        .font(.robotoBold(size: 18))
                        .padding(.horizontal)
                }
                
                ForEach(viewModel.meetingData.unique(), id: \.id) { items in
                    SessionCard(
                        with: SessionCardModel(
                            title: items.title.orEmpty(),
                            date: DateUtils.dateFormatter(items.startAt.orCurrentDate(), forFormat: .ddMMMMyyyy),
                            startAt: DateUtils.dateFormatter(items.startAt.orCurrentDate(), forFormat: .HHmm),
                            endAt: DateUtils.dateFormatter(items.endAt.orCurrentDate(), forFormat: .HHmm),
                            isPrivate: items.isPrivate ?? false,
                            isVerified: (items.user?.isVerified) ?? false,
                            photo: (items.user?.profilePhoto).orEmpty(),
                            name: (items.user?.name).orEmpty(),
                            color: items.background,
                            isActive: items.endAt.orCurrentDate() > Date(),
                            collaborationCount: (items.meetingCollaborations ?? []).count,
                            collaborationName: (items.meetingCollaborations ?? []).compactMap({
                                (
                                    $0.user?.name
                                ).orEmpty()
                            }).joined(separator: ", "),
                            isAlreadyBooked: items.isAlreadyBooked ?? false
                        )
                    ) {
                        if items.isAlreadyBooked ?? false {
                            viewModel.bookingId = (items.booking?.id).orEmpty()
                            
                            viewModel.routeToUserScheduleDetail()
                        } else if !(items.isAlreadyBooked ?? false) && items.booking != nil {
                            viewModel.routeToInvoice(id: (items.booking?.id).orEmpty())
                        } else {
                            viewModel.isPresent.toggle()
                            viewModel.selectedMeeting = items
                            viewModel.meetingId = items.id.orEmpty()
                        }
                    } visitProfile: {
                        
                    }
                    .grayscale(items.endAt.orCurrentDate() < Date() ? 1 : 0)
                    .onAppear {
                        if viewModel.meetingData.unique().last?.id == items.id && viewModel.nextCursorMeeting != nil {
                            viewModel.meetingParam.skip = viewModel.meetingParam.take
                            viewModel.meetingParam.take += 15
                            viewModel.getTalentMeeting(by: (viewModel.talentData?.id).orEmpty(), isMore: true)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 2)
                    .padding(.horizontal)
                    
                }
            }
            
            if viewModel.isLoadingMore {
                HStack {
                    Spacer()
                    
                    ProgressView()
                        .progressViewStyle(.circular)
                    
                    Spacer()
                }
                .padding()
            }
        }
    }
    
  struct ListCreator: View {
    @StateObject var viewModel: TalentProfileDetailViewModel
    var geo: GeometryProxy
    
    var body: some View {
      LazyVGrid(
        columns: Array(
          repeating: GridItem(.flexible(), spacing: 10),
          count: UIDevice.current.userInterfaceIdiom == .pad ? 4 : 2
        )
      ) {
        if let data = viewModel.talentData?.management?.managementTalents {
          ForEach(data, id: \.id) { item in
            Button {
              viewModel.routeToMyTalent(talent: (item.user?.username).orEmpty())
            } label: {
              CreatorCard(
                with: CreatorCardModel(
                  name: (item.user?.name).orEmpty(),
                  isVerified: item.user?.isVerified ?? false,
                  professions: (item.user?.stringProfessions ?? []).first.orEmpty(),
                  photo: (item.user?.profilePhoto).orEmpty()
                ),
                size: UIDevice.current.userInterfaceIdiom == .pad ? geo.size.width/4 - 22 : geo.size.width/2 - 22
              )
            }
            .buttonStyle(.plain)
          }
        }
      }
      .padding()
    }
    }
    
    struct CoinBuySucceed: View {
        
        let geo: GeometryProxy
        
        var body: some View {
            HStack {
                
                Spacer()
                
                VStack(spacing: 15) {
                    Image.Dinotis.paymentSuccessImage
                        .resizable()
                        .scaledToFit()
                        .frame(height: geo.size.width/2)
                    
                    Text(LocaleText.homeScreenCoinSuccess)
                        .font(.robotoBold(size: 16))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
            }
            .padding(.vertical)
        }
    }
    
    struct CoinPaymentSheetView: View {
        
        @ObservedObject var viewModel: TalentProfileDetailViewModel
        
        var body: some View {
            VStack(spacing: 15) {
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(LocaleText.homeScreenYourCoin)
                            .font(.robotoMedium(size: 12))
                            .foregroundColor(.black)
                        
                        HStack(alignment: .top) {
                            Image.Dinotis.coinIcon
                                .resizable()
                                .scaledToFit()
                                .frame(height: 15)
                            
                            Text("\((viewModel.userData?.coinBalance?.current).orEmpty().toPriceFormat())")
                                .font(.robotoBold(size: 14))
                                .foregroundColor((Int(viewModel.userData?.coinBalance?.current ?? "0") ?? 0) >= viewModel.totalPayment ? .DinotisDefault.primary : .red)
                        }
                    }
                    
                    Spacer()
                    
                    if (Int(viewModel.userData?.coinBalance?.current ?? "0").orZero()) < viewModel.totalPayment {
                        Button {
                            DispatchQueue.main.async {
                                viewModel.isShowCoinPayment.toggle()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                viewModel.showAddCoin.toggle()
                            }
                        } label: {
                            Text(LocaleText.homeScreenAddCoin)
                                .font(.robotoMedium(size: 12))
                                .foregroundColor(.DinotisDefault.primary)
                                .padding(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.DinotisDefault.primary, lineWidth: 1)
                                )
                        }
                        
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).foregroundColor(.secondaryViolet))
                
                VStack(alignment: .leading) {
                    Text(LocaleText.paymentScreenPromoCodeTitle)
                        .font(.robotoMedium(size: 12))
                        .foregroundColor(.black)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            
                            Group {
                                if viewModel.promoCodeSuccess {
                                    HStack {
                                        Text(viewModel.promoCode)
                                            .font(.robotoRegular(size: 12))
                                            .foregroundColor(viewModel.promoCodeSuccess ? Color(.systemGray) : .black)
                                        
                                        Spacer()
                                    }
                                } else {
                                    TextField(LocaleText.paymentScreenPromoCodePlaceholder, text: $viewModel.promoCode)
                                        .font(.robotoRegular(size: 12))
                                        .autocapitalization(.allCharacters)
                                        .disableAutocorrection(true)
                                }
                            }
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.dinotisStrokeSecondary, lineWidth: 1)
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(viewModel.promoCodeSuccess ? Color(.systemGray5) : .white)
                            )
                            
                            Button {
                                Task {
                                    if viewModel.promoCodeData != nil {
                                        viewModel.resetStateCode()
                                    } else {
                                        await viewModel.checkPromoCode()
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(viewModel.promoCodeSuccess ? LocaleText.changeVoucherText : LocaleText.applyText)
                                        .font(.robotoMedium(size: 12))
                                        .foregroundColor(viewModel.promoCode.isEmpty ? Color(.systemGray2) : .white)
                                }
                                .padding()
                                .padding(.horizontal, 5)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .foregroundColor(viewModel.promoCodeSuccess ? .red : (viewModel.promoCode.isEmpty ? Color(.systemGray5) : .DinotisDefault.primary))
                                )
                                
                            }
                            .disabled(viewModel.promoCode.isEmpty)
                            
                        }
                        
                        if viewModel.promoCodeError {
                            HStack {
                                Image.Dinotis.exclamationCircleIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 10)
                                    .foregroundColor(.red)
                                Text(LocaleText.paymentScreenPromoNotFound)
                                    .font(.robotoRegular(size: 10))
                                    .foregroundColor(.red)
                                
                                Spacer()
                            }
                        }
                        
                        if !viewModel.promoCodeTextArray.isEmpty {
                            ForEach(viewModel.promoCodeTextArray, id: \.self) { item in
                                Text(item)
                                    .font(.robotoMedium(size: 10))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).foregroundColor(.secondaryViolet))
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    HStack {
                        Text(LocaleText.paymentText)
                            .font(.robotoMedium(size: 12))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Text(LocaleText.coinSingleText)
                            .font(.robotoMedium(size: 12))
                            .foregroundColor(.black)
                    }
                    
                    HStack {
                        Text(LocaleText.subtotalText)
                            .font(.robotoMedium(size: 12))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Text("\(Int((viewModel.selectedMeeting?.price).orEmpty()).orZero())")
                            .font(.robotoMedium(size: 12))
                            .foregroundColor(.black)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(LocaleText.applicationFeeText)
                                .font(.robotoMedium(size: 12))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Text("\(viewModel.extraFee)")
                                .font(.robotoMedium(size: 12))
                                .foregroundColor(.black)
                        }
                        
                        if (viewModel.promoCodeData?.discountTotal).orZero() != 0 {
                            HStack {
                                Text(LocaleText.discountText)
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Text("-\((viewModel.promoCodeData?.discountTotal).orZero())")
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.red)
                            }
                        } else if (viewModel.promoCodeData?.amount).orZero() != 0 && (viewModel.promoCodeData?.discountTotal).orZero() == 0 {
                            HStack {
                                Text(LocaleText.discountText)
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Text("-\((viewModel.promoCodeData?.amount).orZero())")
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.bottom, 30)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 1.5)
                        .foregroundColor(.DinotisDefault.primary)
                    
                    HStack {
                        Text(LocaleText.totalPaymentText)
                            .font(.robotoBold(size: 12))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Text("\(viewModel.totalPayment)")
                            .font(.robotoBold(size: 12))
                            .foregroundColor(.black)
                    }
                    
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).foregroundColor(.secondaryViolet))
                
                Spacer()
                
                Button {
                    Task {
                        await viewModel.coinPayment()
                    }
                } label: {
                    HStack {
                        Spacer()
                        
                        if viewModel.isLoadingCoinPay {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(LocaleText.payNowText)
                                .font(.robotoMedium(size: 12))
                                .foregroundColor((Int(viewModel.userData?.coinBalance?.current ?? "0") ?? 0) < viewModel.totalPayment ? Color(.systemGray) : .white)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor((Int(viewModel.userData?.coinBalance?.current ?? "0") ?? 0) < viewModel.totalPayment ? Color(.systemGray4) : .DinotisDefault.primary)
                    )
                }
                .disabled((Int(viewModel.userData?.coinBalance?.current ?? "0") ?? 0) < viewModel.totalPayment || viewModel.isLoadingCoinPay)
                
            }
        }
    }
    
    struct AddCoinSheetView: View {
        
        @ObservedObject var viewModel: TalentProfileDetailViewModel
        let geo: GeometryProxy
        
        var body: some View {
            VStack(spacing: 20) {
                
                VStack {
                    Text(LocaleText.homeScreenYourCoin)
                        .font(.robotoRegular(size: 12))
                        .foregroundColor(.black)
                    
                    HStack(alignment: .top) {
                        Image.Dinotis.coinIcon
                            .resizable()
                            .scaledToFit()
                            .frame(height: geo.size.width/28)
                        
                        Text("\((viewModel.userData?.coinBalance?.current).orEmpty().toPriceFormat())")
                            .font(.robotoBold(size: 14))
                            .foregroundColor(.DinotisDefault.primary)
                    }
                    .multilineTextAlignment(.center)
                    
                    Text(LocaleText.homeScreenCoinDetail)
                        .font(.robotoRegular(size: 10))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                }
                
                Group {
                    if viewModel.isLoadingTrxs {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        QGrid(viewModel.myProducts.unique(), columns: 2, vSpacing: 10, hSpacing: 10, vPadding: 5, hPadding: 5, isScrollable: false, showScrollIndicators: false) { item in
                            Button {
                                viewModel.productSelected = item
                            } label: {
                                HStack {
                                    Spacer()
                                    VStack {
                                        Text(item.priceToString())
                                        
                                        Group {
                                            switch item.productIdentifier {
                                            case viewModel.productIDs[0]:
                                                Text(LocaleText.valueCoinLabel("16000".toPriceFormat()))
                                            case viewModel.productIDs[1]:
                                                Text(LocaleText.valueCoinLabel("65000".toPriceFormat()))
                                            case viewModel.productIDs[2]:
                                                Text(LocaleText.valueCoinLabel("109000".toPriceFormat()))
                                            case viewModel.productIDs[3]:
                                                Text(LocaleText.valueCoinLabel("159000".toPriceFormat()))
                                            case viewModel.productIDs[4]:
                                                Text(LocaleText.valueCoinLabel("209000".toPriceFormat()))
                                            case viewModel.productIDs[5]:
                                                Text(LocaleText.valueCoinLabel("259000".toPriceFormat()))
                                            case viewModel.productIDs[6]:
                                                Text(LocaleText.valueCoinLabel("309000".toPriceFormat()))
                                            case viewModel.productIDs[7]:
                                                Text(LocaleText.valueCoinLabel("429000".toPriceFormat()))
                                            default:
                                                Text("")
                                            }
                                        }
                                    }
                                    Spacer()
                                }
                                .font((viewModel.productSelected ?? SKProduct()).id == item.id ? .robotoBold(size: 12) : .robotoRegular(size: 12))
                                .foregroundColor(.DinotisDefault.primary)
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .foregroundColor((viewModel.productSelected ?? SKProduct()).id == item.id ? .secondaryViolet : .clear)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.DinotisDefault.primary, lineWidth: 1)
                                )
                            }
                        }
                    }
                }
                .frame(height: 250)
                
                Spacer()
                
                VStack {
                    Button {
                        if let product = viewModel.productSelected {
                            viewModel.purchaseProduct(product: product)
                        }
                    } label: {
                        HStack {
                            Spacer()
                            
                            Text(LocaleText.homeScreenAddCoin)
                                .font(.robotoMedium(size: 12))
                                .foregroundColor(viewModel.isLoadingTrxs || viewModel.productSelected == nil ? Color(.systemGray2) : .white)
                            
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundColor(viewModel.isLoadingTrxs || viewModel.productSelected == nil ? Color(.systemGray5) : .DinotisDefault.primary)
                        )
                    }
                    .disabled(viewModel.isLoadingTrxs || viewModel.productSelected == nil)
                    
                    Button {
                        viewModel.openWhatsApp()
                    } label: {
                        HStack {
                            Spacer()
                            
                            Text(LocaleText.helpText)
                                .font(.robotoMedium(size: 12))
                                .foregroundColor(viewModel.isLoadingTrxs ? Color(.systemGray2) : .DinotisDefault.primary)
                            
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundColor(viewModel.isLoadingTrxs ? Color(.systemGray5) : .secondaryViolet)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(viewModel.isLoadingTrxs ? Color(.systemGray2) : Color.DinotisDefault.primary, lineWidth: 1)
                        )
                    }
                    .disabled(viewModel.isLoadingTrxs)
                    
                }
                
            }
        }
    }
    
    struct PaymentTypeOption: View {
        @ObservedObject var viewModel: TalentProfileDetailViewModel
        
        var body: some View {
            
            VStack(spacing: 16) {
                HStack {
                    Text(LocalizableText.paymentMethodLabel)
                        .font(.robotoBold(size: 14))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button {
                        viewModel.showPaymentMenu = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                            .foregroundColor(Color(UIColor.systemGray4))
                    }
                }
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        Button {
                            DispatchQueue.main.async {
                                viewModel.showPaymentMenu.toggle()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                withAnimation {
                                    Task {
                                        await viewModel.extraFees()
                                    }
                                    
                                    viewModel.isShowCoinPayment.toggle()
                                }
                            }
                        } label: {
                            HStack(spacing: 15) {
                                Image.paymentAppleIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 28)
                                    .foregroundColor(.DinotisDefault.primary)
                                
                                Text(LocalizableText.inAppPurchaseLabel)
                                    .font(.robotoBold(size: 12))
                                    .foregroundColor(.DinotisDefault.primary)
                                
                                Spacer()
                                
                                Image.sessionDetailChevronIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 37)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundColor(.DinotisDefault.lightPrimary)
                            )
                        }
                        
                        if viewModel.selectedMeeting?.isPrivate ?? false {
                            Button {
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                    withAnimation {
                                        viewModel.routeToPaymentMethod(price: (viewModel.selectedMeeting?.price).orEmpty(), meetingId: viewModel.meetingId)
                                        viewModel.showPaymentMenu.toggle()
                                    }
                                }
                            } label: {
                                HStack(spacing: 15) {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(LocalizableText.otherPaymentMethodTitle)
                                            .font(.robotoBold(size: 12))
                                        
                                        Text(LocalizableText.otherPaymentMethodDescription)
                                            .font(.robotoRegular(size: 10))
                                    }
                                    .foregroundColor(.DinotisDefault.primary)
                                    
                                    Spacer()
                                    
                                    Image.sessionDetailChevronIcon
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 37)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .foregroundColor(.DinotisDefault.lightPrimary)
                                )
                            }
                        }
                    }
                }
            }
        }
    }
    
    struct SlideOverCardView: View {
        
        @ObservedObject var viewModel: TalentProfileDetailViewModel
        
        var body: some View {
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(spacing: 12) {
                            HStack(spacing: 16) {
                                HStack(spacing: -8) {
                                    DinotisImageLoader(
                                        urlString: (viewModel.talentData?.profilePhoto).orEmpty(),
                                        width: 40,
                                        height: 40
                                    )
                                    .clipShape(Circle())
                                    
                                    if (viewModel.selectedMeeting?.meetingCollaborations?.count).orZero() > 0 {
                                        Text("+\((viewModel.selectedMeeting?.meetingCollaborations?.count).orZero())")
                                            .font(.robotoMedium(size: 16))
                                            .foregroundColor(.white)
                                            .background(
                                                Circle()
                                                    .frame(width: 40, height: 40)
                                                    .foregroundColor(Color(hex: "#CD2DAD")?.opacity(0.75))
                                                    .overlay(
                                                        Circle()
                                                            .stroke(Color.white, lineWidth: 2)
                                                            .frame(width: 40, height: 40)
                                                    )
                                            )
                                    }
                                }
                                
                                HStack {
                                    Text((viewModel.talentData?.name).orEmpty())
                                        .font(.robotoBold(size: 14))
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.leading)
                                    
                                    if (viewModel.talentData?.isVerified) ?? false {
                                        Image.sessionCardVerifiedIcon
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 16)
                                    }
                                }
                                
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text((viewModel.selectedMeeting?.title).orEmpty())
                                        .font(.robotoBold(size: 14))
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                }
                                
                                VStack(alignment: .leading) {
                                    Text((viewModel.selectedMeeting?.meetingDescription).orEmpty())
                                        .font(.robotoRegular(size: 12))
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(viewModel.isDescComplete ? nil : 3)
                                    
                                    Button {
                                        withAnimation {
                                            viewModel.isDescComplete.toggle()
                                        }
                                    } label: {
                                        Text(viewModel.isDescComplete ? LocalizableText.bookingRateCardHideFullText : LocalizableText.bookingRateCardShowFullText)
                                            .font(.robotoBold(size: 12))
                                            .foregroundColor(.DinotisDefault.primary)
                                    }
                                    .isHidden(
                                        (viewModel.selectedMeeting?.meetingDescription).orEmpty().count < 150,
                                        remove: (viewModel.selectedMeeting?.meetingDescription).orEmpty().count < 150
                                    )
                                }
                            }
                          
                          VStack {
                            if !(viewModel.selectedMeeting?.meetingCollaborations ?? []).isEmpty {
                              VStack(alignment: .leading, spacing: 10) {
                                Text("\(LocalizableText.withText):")
                                  .font(.robotoMedium(size: 12))
                                  .foregroundColor(.black)
                                
                                ForEach((viewModel.selectedMeeting?.meetingCollaborations ?? []).prefix(3), id: \.id) { item in
                                  HStack(spacing: 10) {
                                    ImageLoader(url: (item.user?.profilePhoto).orEmpty(), width: 40, height: 40)
                                      .frame(width: 40, height: 40)
                                      .clipShape(Circle())
                                    
                                    Text((item.user?.name).orEmpty())
                                      .lineLimit(1)
                                      .font(.robotoBold(size: 14))
                                      .foregroundColor(.DinotisDefault.black1)
                                    
                                    Spacer()
                                  }
                                  .onTapGesture {
                                    viewModel.isPresent = false
                                    viewModel.routeToMyTalent(talent: item.username.orEmpty())
                                  }
                                }
                                
                                if (viewModel.selectedMeeting?.meetingCollaborations ?? []).count > 3 {
                                  Button {
                                    viewModel.isPresent = false
                                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                                      viewModel.isShowCollabList.toggle()
                                    }
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
                          .padding(.vertical, 10)
                        }
                        
                        VStack(spacing: 10) {
                            HStack(spacing: 10) {
                                Image.sessionCardDateIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 17)
                                
                                Text((viewModel.selectedMeeting?.startAt?.toStringFormat(with: .ddMMMMyyyy)).orEmpty())
                                    .font(.robotoRegular(size: 12))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                            }
                            
                            HStack(spacing: 10) {
                                Image.sessionCardTimeSolidIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 17)
                                
                                Text("\((viewModel.selectedMeeting?.startAt?.toStringFormat(with: .HHmm)).orEmpty()) – \((viewModel.selectedMeeting?.endAt?.toStringFormat(with: .HHmm)).orEmpty())")
                                    .font(.robotoRegular(size: 12))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                            }
                            
                            HStack(spacing: 10) {
                                Image.sessionCardPersonSolidIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 17)
                                
                                Text("\((viewModel.selectedMeeting?.slots).orZero()) \(LocalizableText.participant)")
                                    .font(.robotoRegular(size: 12))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.leading)
                                
                                Text(LocalizableText.limitedQuotaLabelWithEmoji)
                                    .font(.robotoBold(size: 10))
                                    .foregroundColor(.DinotisDefault.red)
                                    .padding(.vertical, 5)
                                    .padding(.horizontal, 8)
                                    .background(Color.DinotisDefault.red.opacity(0.1))
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.DinotisDefault.red, lineWidth: 1.0)
                                    )
                                
                                Spacer()
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            Text(LocalizableText.priceLabel)
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            if (viewModel.selectedMeeting?.price).orEmpty() == "0" {
                                Text(LocalizableText.freeText)
                                    .font(.robotoBold(size: 16))
                                    .foregroundColor(.black)
                            } else {
                                Text((viewModel.selectedMeeting?.price).orEmpty().toPriceFormat())
                                    .font(.robotoBold(size: 16))
                                    .foregroundColor(.black)
                            }
                        }
                    }
                }
                
                Spacer()
                
                HStack(spacing: 15) {
                    DinotisSecondaryButton(
                        text: LocalizableText.cancelLabel,
                        type: .adaptiveScreen,
                        textColor: .DinotisDefault.black1,
                        bgColor: .DinotisDefault.lightPrimary,
                        strokeColor: .DinotisDefault.primary) {
                            viewModel.isPresent = false
                        }
                    
                    DinotisPrimaryButton(
                        text: LocalizableText.payLabel,
                        type: .adaptiveScreen,
                        textColor: .white,
                        bgColor: .DinotisDefault.primary) {
                            
                            if viewModel.freeTrans {
                                viewModel.onSendFreePayment()
                            } else {
                                viewModel.isPresent = false
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                    withAnimation {
                                        if (viewModel.selectedMeeting?.price).orEmpty() == "0" {
                                            viewModel.onSendFreePayment()
                                        } else {
                                            viewModel.showPaymentMenu = true
                                        }
                                    }
                                }
                            }
                        }
                    
                }
                .padding(.top)
            }
            .onDisappear {
                viewModel.isDescComplete = false
            }
        }
    }
    
    struct RequestMenuView: View {
        
        @ObservedObject var viewModel: TalentProfileDetailViewModel
        
        var body: some View {
            VStack(spacing: 30) {
                VStack(spacing: 5) {
                    Text(LocaleText.requestScheduleText)
                        .font(.robotoBold(size: 14))
                    
                    Text(LocaleText.requestScheduleSubLabel)
                        .font(.robotoRegular(size: 12))
                        .multilineTextAlignment(.center)
                }
                .foregroundColor(.black)
                
                VStack(spacing: 20) {
                    Button {
                        Task {
                            await viewModel.sendRequest(type: .privateType, message: LocaleText.requestPrivateText)
                        }
                    } label: {
                        HStack {
                            Spacer()
                            
                            Text(LocaleText.requestPrivateText)
                                .font(.robotoMedium(size: 12))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                    }
                    .padding(.vertical)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(.DinotisDefault.primary)
                    )
                    
                    Button {
                        Task {
                            await viewModel.sendRequest(type: .groupType, message: LocaleText.requestGroupText)
                        }
                    } label: {
                        HStack {
                            Spacer()
                            
                            Text(LocaleText.requestGroupText)
                                .font(.robotoMedium(size: 12))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                    }
                    .padding(.vertical)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(.DinotisDefault.primary)
                    )
                    
                    Button {
                        Task {
                            await viewModel.sendRequest(type: .liveType, message: LocaleText.requestLiveText)
                        }
                    } label: {
                        HStack {
                            Spacer()
                            
                            Text(LocaleText.requestLiveText)
                                .font(.robotoMedium(size: 12))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                    }
                    .padding(.vertical)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(.DinotisDefault.primary)
                    )
                    
                    Spacer()
                    
                    Button {
                        viewModel.showingRequest = false
                    } label: {
                        HStack {
                            Spacer()
                            
                            Text(LocaleText.cancelText)
                                .font(.robotoMedium(size: 12))
                                .foregroundColor(.black)
                            
                            Spacer()
                        }
                    }
                    .padding(.vertical)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(.secondaryViolet)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.DinotisDefault.primary, lineWidth: 1)
                    )
                }
            }
            .padding([.top, .trailing, .leading], -12)
            .padding(.bottom)
        }
    }
    
    struct SectionContent: View {
        
        @ObservedObject var viewModel: TalentProfileDetailViewModel
        
        @Binding var tabValue: TabRoute
      var geo: GeometryProxy
        
        var body: some View {
            if viewModel.tabNumb == 0 {
                LazyVStack(spacing: 20) {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(LocalizableText.talentDetailAboutMe)
                                .font(.robotoBold(size: 20))
                                .foregroundColor(.black)
                            
                            Spacer()
                        }
                        
                        Text((viewModel.talentData?.profileDescription).orEmpty())
                            .font(.robotoRegular(size: 14))
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.black)
                        
                        
                    }
                    .padding([.horizontal, .top])
                    
                    LazyVStack(alignment: .leading,spacing: 5) {
                        HStack {
                            Text(LocalizableText.talentDetailGallery)
                                .font(.robotoBold(size: 20))
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        if viewModel.profileBanner.isEmpty {
                            HStack {
                                
                                Spacer()
                                
                                VStack(spacing: 15) {
                                    Image.talentProfileEmptyGallery
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 95)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    
                                    Text(LocalizableText.galleryEmpty)
                                        .font(.robotoRegular(size: 17))
                                        .foregroundColor(.DinotisDefault.black3)
                                }
                                .padding(.vertical)
                                
                                Spacer()
                            }
                            .padding(.top, 8)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack {
                                    ForEach(viewModel.profileBanner, id: \.id) { item in
                                        DinotisImageLoader(urlString: item.imgUrl.orEmpty(), width: 190, height: 190)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 0)
                                    }
                                }
                                .padding(.top)
                                .padding(.horizontal)
                                .padding(.bottom)
                            }
                        }
                    }
                }
                
            } else if viewModel.tabNumb == 1 {
                if viewModel.talentData?.management == nil {
                    ScheduleTalent(viewModel: viewModel, tabValue: $tabValue)
                        .padding(.top, 10)
                } else {
                  ListCreator(viewModel: viewModel, geo: geo)
                }
                
            } else if viewModel.tabNumb == 2 {
                if viewModel.talentData?.management != nil {
                    ScheduleTalent(viewModel: viewModel, tabValue: $tabValue)
                        .padding(.top, 10)
                } else {
                    if viewModel.rateCardList.isEmpty {
                        TalentProfileDetailView.EmptyScheduleTalentProfile(viewModel: viewModel)
                    } else {
                        ForEach(viewModel.rateCardList.unique(), id: \.id) { item in
                            RateHorizontalCardView(
                                item: item,
                                isTalent: false,
                                onTapDelete: {},
                                onTapEdit: {}
                            )
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .padding(.top, 5)
                            .onTapGesture(perform: {
                                viewModel.routeToRateCardForm(
                                    rateCardId: item.id.orEmpty(),
                                    title: item.title.orEmpty(),
                                    description: item.description.orEmpty(),
                                    price: item.price.orEmpty(),
                                    duration: item.duration.orZero(),
                                    isPrivate: item.isPrivate ?? false
                                )
                            })
                            .onAppear {
                                Task {
                                    if (viewModel.rateCardList.unique().last?.id).orEmpty() == item.id.orEmpty() && viewModel.nextCursorRateCard != nil {
                                        viewModel.query.skip = viewModel.query.take
                                        viewModel.query.take += 15
                                        await viewModel.getRateCardList(by: (viewModel.talentData?.id).orEmpty(), isMore: true)
                                    }
                                }
                            }
                        }
                        
                        if viewModel.isLoadingMoreRateCard {
                            HStack {
                                Spacer()
                                
                                ProgressView()
                                    .progressViewStyle(.circular)
                                
                                Spacer()
                            }
                            .padding()
                        }
                    }
                }
                
            } else if viewModel.tabNumb == 3 {
                if viewModel.reviewData.unique().isEmpty {
                    HStack {
                        
                        Spacer()
                        
                        VStack(alignment: .center, spacing: 15) {
                            Text(LocalizableText.talentDetailEmptyReviewTitle)
                                .font(.robotoBold(size: 20))
                                .foregroundColor(.black)
                            
                            Text(LocalizableText.talentDetailEmptyReviewContent)
                                .font(.robotoRegular(size: 16))
                                .foregroundColor(.DinotisDefault.black3)
                        }
                        .multilineTextAlignment(.center)
                        .padding()
                        .padding(.vertical)
                        .padding(.top)
                        
                        Spacer()
                    }
                } else {
                    HStack {
                        Text(LocalizableText.talentDetailReviews)
                            .font(.robotoBold(size: 16))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Menu {
                            Picker(selection: $viewModel.filterSelectionReview) {
                                ForEach(viewModel.filterOptionReview, id: \.id) { item in
                                    Text(item.label.orEmpty())
                                        .tag(item.label.orEmpty())
                                }
                            } label: {
                                EmptyView()
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Text(viewModel.filterSelectionReview)
                                    .font(.robotoRegular(size: 12))
                                    .foregroundColor(.black)
                                
                                Image(systemName: "chevron.down")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 5)
                                    .foregroundColor(.black)
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(.secondaryViolet)
                            )
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.DinotisDefault.primary, lineWidth: 1))
                        }
                        .isHidden(true, remove: true)
                    }
                    .padding(.top)
                    .padding(.horizontal)
                    .padding(.bottom, 15)
                    
                    ForEach(viewModel.reviewData.unique(), id: \.id) { item in
                        ReviewCard(data: item)
                            .onAppear {
                                if item.id == viewModel.reviewData.unique().last?.id && viewModel.nextCursorReview != nil {
                                    
                                    Task {
                                        viewModel.reviewParam.skip = viewModel.reviewParam.take
                                        viewModel.reviewParam.take += 15
                                        
                                        await viewModel.getReviewsList(with: (viewModel.talentData?.id).orEmpty(), isMore: true)
                                    }
                                }
                            }
                        
                        Divider()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    if viewModel.isLoadingMoreReview {
                        HStack {
                            Spacer()
                            
                            ProgressView()
                                .progressViewStyle(.circular)
                            
                            Spacer()
                        }
                        .padding()
                    }
                }
            }
        }
    }
    
    struct ReviewCard: View {
        
        let data: ReviewData
        
        init(data: ReviewData) {
            self.data = data
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 15) {
                HStack(alignment: .center, spacing: 15) {
                    DinotisImageLoader(urlString: (data.user?.profilePhoto).orEmpty(), width: 40, height: 40)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text((data.user?.name).orEmpty())
                            .font(.robotoBold(size: 14))
                            .foregroundColor(.black)
                        
                        Text(countHourTime(time: data.createdAt.orCurrentDate()))
                            .font(.robotoRegular(size: 12))
                            .foregroundColor(.black)
                    }
                    .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 15)
                            .foregroundColor(.DinotisDefault.orange)
                        
                        Text(data.rating.orEmpty())
                            .font(.robotoMedium(size: 12))
                            .foregroundColor(.black)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .background(
                        Capsule()
                            .foregroundColor(.DinotisDefault.lightPrimary)
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.DinotisDefault.primaryActive, lineWidth: 1)
                    )
                }
                
                Text(data.review.orEmpty())
                    .font(.robotoRegular(size: 12))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
            }
        }
        
        private func countHourTime(time: Date) -> String {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            formatter.locale = Locale.current
            return formatter.localizedString(for: time, relativeTo: Date())
        }
    }
}
