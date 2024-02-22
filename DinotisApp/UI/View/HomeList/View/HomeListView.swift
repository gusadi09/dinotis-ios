//
//  HomeListView.swift
//  DinotisApp
//
//  Created by Irham Naufal on 07/02/24.
//

import DinotisDesignSystem
import QGrid
import Shimmer
import StoreKit
import SwiftUI
import SwiftUINavigation

struct HomeListView: View {
    
    @ObservedObject var viewModel: HomeListViewModel
    @Binding var tabValue: TabRoute
    
    @Environment(\.dismiss) var dismiss
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView {
                LazyVStack(spacing: 10, pinnedViews: .sectionHeaders) {
                    Section {
                        Group {
                            switch viewModel.type {
                            case .session:
                                sessionList
                            case .creator:
                                creatorList
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                    } header: {
                        tabFilter
                    }
                    
                    if viewModel.isLoadMore {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                }
                .padding(.bottom)
                .padding(.top, 10)
            }
            .refreshable {
                viewModel.getSearchedData(isRefresh: true)
            }
        }
        .background(Color.DinotisDefault.baseBackground.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarHidden(true)
        .background(navigationHelper)
        .dinotisAlert(
            isPresent: $viewModel.isShowAlert,
            title: viewModel.alert.title,
            isError: viewModel.alert.isError,
            message: viewModel.alert.message,
            primaryButton: viewModel.alert.primaryButton,
            secondaryButton: viewModel.alert.secondaryButton
        )
        .onChange(of: viewModel.searchText) { _ in
            viewModel.debounceText()
        }
        .valueChanged(value: viewModel.debouncedText) { _ in
            viewModel.getSearchedData()
        }
        .sheet(
            isPresented: $viewModel.isShowSessionDetail,
            content: {
                if #available(iOS 16.0, *) {
                    SessionDetailView(viewModel: viewModel)
                        .presentationDetents([.fraction(0.8), .fraction(0.999)])
                        .dynamicTypeSize(.large)
                } else {
                    SessionDetailView(viewModel: viewModel)
                        .dynamicTypeSize(.large)
                }
            }
        )
        .sheet(
            isPresented: $viewModel.isShowPaymentOption,
            content: {
                if #available(iOS 16.0, *) {
                    PaymentTypeOption(viewModel: viewModel)
                    .presentationDetents([.fraction(viewModel.sessionCard.isPrivate.orFalse() ? 0.44 : 0.33)])
                    .dynamicTypeSize(.large)
                } else {
                    PaymentTypeOption(viewModel: viewModel)
                        .dynamicTypeSize(.large)
                }
            }
        )
        .sheet(
            isPresented: $viewModel.isShowCoinPayment,
            onDismiss: {
                viewModel.resetStateCode()
            },
            content: {
                if #available(iOS 16.0, *) {
                    CoinPaymentSheetView(viewModel: viewModel)
                        .presentationDetents([.fraction(0.85), .fraction(0.999)])
                        .dynamicTypeSize(.large)
                } else {
                    CoinPaymentSheetView(viewModel: viewModel)
                        .dynamicTypeSize(.large)
                }
            }
        )
        .sheet(
            isPresented: $viewModel.isShowAddCoin,
            content: {
                if #available(iOS 16.0, *) {
                    AddCoinSheetView(viewModel: viewModel)
                        .presentationDetents([.fraction(0.67), .fraction(0.999)])
                        .dynamicTypeSize(.large)
                } else {
                    AddCoinSheetView(viewModel: viewModel)
                        .dynamicTypeSize(.large)
                }
            }
        )
        .sheet(isPresented: $viewModel.isShowCollabList, content: {
            if #available(iOS 16.0, *) {
              SelectedCollabCreatorView(
                isEdit: false,
                isAudience: true,
                arrUsername: .constant((viewModel.sessionCard.meetingCollaborations ?? []).compactMap({
                  $0.username
              })),
                arrTalent: .constant(viewModel.sessionCard.meetingCollaborations ?? [])) {
                    viewModel.isShowCollabList = false
                } visitProfile: { username in
                    viewModel.isShowSessionDetail = false
                    viewModel.routeToCreatorProfile(username: username)
                }
                .presentationDetents([.medium, .fraction(0.999)])
                .dynamicTypeSize(.large)
            } else {
              SelectedCollabCreatorView(
                isEdit: false,
                isAudience: true,
                arrUsername: .constant((viewModel.sessionCard.meetingCollaborations ?? []).compactMap({
                  $0.username
              })),
                arrTalent: .constant(viewModel.sessionCard.meetingCollaborations ?? [])) {
                    viewModel.isShowCollabList = false
                } visitProfile: { username in
                    viewModel.isShowSessionDetail = false
                    viewModel.routeToCreatorProfile(username: username)
                }
                .dynamicTypeSize(.large)
            }
        })
    }
}

extension HomeListView {
    
    @ViewBuilder var navigationHelper: some View {
        ZStack {
            NavigationLink(
                unwrapping: $viewModel.route,
                case: /HomeRouting.paymentMethod,
                destination: { viewModel in
                    PaymentMethodView(viewModel: viewModel.wrappedValue, mainTabValue: $tabValue)
                },
                onNavigate: {_ in},
                label: {
                    EmptyView()
                }
            )
            
            NavigationLink(
                unwrapping: $viewModel.route,
                case: /HomeRouting.talentProfileDetail,
                destination: { viewModel in
                    CreatorProfileDetailView(viewModel: viewModel.wrappedValue, tabValue: $tabValue)
                },
                onNavigate: {_ in},
                label: {
                    EmptyView()
                }
            )
        }
    }
    
    @ViewBuilder var header: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image.generalBackIcon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding(12)
                        .background(
                            Circle()
                                .fill(.white)
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 0)
                        )
                }
                
                if viewModel.isSearching {
                    SearchTextField("Placeholder", text: $viewModel.searchText, focused: _isFocused)
                } else {
                    Text(viewModel.type.title)
                        .font(.robotoBold(size: 20))
                        .foregroundColor(.DinotisDefault.black1)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
                
                Group {
                    if viewModel.isSearching {
                        Button {
                            viewModel.isSearching = false
                            isFocused = false
                        } label: {
                            Text(LocalizableText.cancelLabel)
                                .font(.robotoBold(size: 12))
                                .foregroundColor(.DinotisDefault.primary)
                        }
                    } else {
                        Button {
                            viewModel.isSearching = true
                            isFocused = true
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.DinotisDefault.black2)
                                .padding(12)
                        }
                    }
                }
                
            }
            .animation(.easeInOut, value: viewModel.isSearching)
            .padding()
            
            Divider()
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder var tabFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.tabFilters, id: \.self) { filter in
                    Button {
                        viewModel.currentTab = filter
                        viewModel.getSearchedData()
                    } label: {
                        Text(filter.title)
                            .font(viewModel.currentTab == filter ? .robotoBold(size: 14) : .robotoRegular(size: 14))
                            .foregroundColor(viewModel.currentTab == filter ? .DinotisDefault.primary : .DinotisDefault.black1)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                Capsule()
                                    .fill(viewModel.currentTab == filter ? Color.DinotisDefault.lightPrimary : Color.clear)
                            )
                            .overlay {
                                Capsule()
                                    .stroke(
                                        viewModel.currentTab == filter ? Color.DinotisDefault.primary : Color.DinotisDefault.grayDinotis,
                                        lineWidth: 1
                                    )
                            }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
        }
        .background(Color.DinotisDefault.baseBackground)
    }
    
    @ViewBuilder var sessionList: some View {
        if viewModel.isLoading {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 440))], spacing: 10) {
                ForEach(0...8, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(.gray)
                        .frame(height: 190)
                        .shimmering(active: viewModel.isLoading)
                }
            }
        } else {
            if viewModel.searchedSession.isEmpty {
                emptyView
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 440))], spacing: 10) {
                    ForEach(viewModel.searchedSession, id: \.id) { item in
                        if let user = item.user {
                            SessionCard(
                                with: SessionCardModel(
                                    title: item.title.orEmpty(),
                                    date: DateUtils.dateFormatter(item.startAt.orCurrentDate(), forFormat: .EEEEddMMMMyyyy),
                                    startAt: DateUtils.dateFormatter(item.startAt.orCurrentDate(), forFormat: .HHmm),
                                    endAt: DateUtils.dateFormatter(item.endAt.orCurrentDate(), forFormat: .HHmm),
                                    isPrivate: item.isPrivate ?? false,
                                    isVerified: (item.user?.isVerified) ?? false,
                                    photo: (item.user?.profilePhoto).orEmpty(),
                                    name: (item.user?.name).orEmpty(),
                                    color: item.background,
                                    participantsImgUrl: item.participantDetails?.compactMap({
                                        $0.profilePhoto.orEmpty()
                                    }) ?? [],
                                    isActive: item.endAt.orCurrentDate() > Date(),
                                    collaborationCount: (item.meetingCollaborations ?? []).count,
                                    collaborationName: (item.meetingCollaborations ?? []).compactMap({
                                        (
                                            $0.user?.name
                                        ).orEmpty()
                                    }).joined(separator: ", "),
                                    isAlreadyBooked: false
                                )
                            ) {
                                viewModel.seeDetailMeeting(from: item)
                            } visitProfile: {
                                viewModel.routeToCreatorProfile(username: user.username.orEmpty())
                            } seeCollaboration: {
                                viewModel.sessionCard = item
                                viewModel.isShowCollabList = true
                            }
                            .onAppear {
                                if item.id == viewModel.searchedSession.last?.id && viewModel.nextCursor != nil {
                                    viewModel.takeItem += 30
                                    viewModel.getSearchedData(isMore: true, isRefresh: false)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder var creatorList: some View {
        if viewModel.isLoading {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 10) {
                ForEach(0...8, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(.gray)
                        .frame(height: 270)
                        .shimmering(active: viewModel.isLoading)
                }
            }
        } else {
            if viewModel.searchedCreator.isEmpty {
                emptyView
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 10) {
                    ForEach(viewModel.searchedCreator.indices, id: \.self) { index in
                        let talent = viewModel.searchedCreator[index]
                        Button {
                            viewModel.routeToCreatorProfile(username: talent.username.orEmpty())
                        } label: {
                            CreatorCardWithFollowButton(
                                width: 165,
                                height: 255,
                                imageURL: talent.profilePhoto.orEmpty(),
                                name: talent.name.orEmpty(),
                                isVerified: talent.isVerified.orFalse(),
                                professions: (talent.stringProfessions ?? []).joined(separator: ", "),
                                isFollowed: $viewModel.isFollowed[index],
                                isLoading: $viewModel.isLoadingFollowUnfollow[index]
                            ) {
                                viewModel.onFollowUnfollowCreator(id: talent.id, index: index)
                            }
                        }
                        .buttonStyle(.plain)
                        .onAppear {
                            if talent.id == viewModel.searchedCreator.last?.id && viewModel.nextCursor != nil {
                                viewModel.takeItem += 30
                                viewModel.getSearchedData(isMore: true, isRefresh: false)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder var emptyView: some View {
        VStack(spacing: 30) {
            Image.searchNotFoundImage
                .resizable()
                .scaledToFit()
                .frame(width: 315)

            Text(LocalizableText.searchGeneralNotFound)
                .multilineTextAlignment(.center)
                .font(.robotoBold(size: 20))
                .foregroundColor(.DinotisDefault.black2)
        }
        .padding(.vertical)
    }
    
    struct SessionDetailView: View {
        
        @ObservedObject var viewModel: HomeListViewModel
        
        @State private var isDescComplete = false
        
        var body: some View {
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(spacing: 12) {
                            HStack(spacing: 16) {
                                HStack(spacing: -8) {
                                    DinotisImageLoader(
                                        urlString: (viewModel.sessionCard.user?.profilePhoto).orEmpty(),
                                        width: 40,
                                        height: 40
                                    )
                                    .clipShape(Circle())
                                    
                                    if (viewModel.sessionCard.meetingCollaborations?.count).orZero() > 0 {
                                        Text("+\((viewModel.sessionCard.meetingCollaborations?.count).orZero())")
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
                                    Text((viewModel.sessionCard.user?.name).orEmpty())
                                        .font(.robotoBold(size: 14))
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.leading)
                                    
                                    if (viewModel.sessionCard.user?.isVerified) ?? false {
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
                                    Text(viewModel.sessionCard.title.orEmpty())
                                        .font(.robotoBold(size: 14))
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(viewModel.sessionCard.description.orEmpty())
                                        .font(.robotoRegular(size: 12))
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(isDescComplete ? nil : 3)
                                    
                                    Button {
                                        withAnimation {
                                            isDescComplete.toggle()
                                        }
                                    } label: {
                                        Text(isDescComplete ? LocalizableText.bookingRateCardHideFullText : LocalizableText.bookingRateCardShowFullText)
                                            .font(.robotoBold(size: 12))
                                            .foregroundColor(.DinotisDefault.primary)
                                    }
                                    .isHidden(
                                        viewModel.sessionCard.description.orEmpty().count < 150,
                                        remove: viewModel.sessionCard.description.orEmpty().count < 150
                                    )
                                }
                            }
                        }
                        
                        VStack {
                            if !(viewModel.sessionCard.meetingCollaborations ?? []).isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("\(LocalizableText.withText):")
                                        .font(.robotoMedium(size: 12))
                                        .foregroundColor(.black)
                                    
                                    ForEach((viewModel.sessionCard.meetingCollaborations ?? []).prefix(3), id: \.id) { item in
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
                                            viewModel.isShowSessionDetail = false
                                            viewModel.routeToCreatorProfile(username: item.username.orEmpty())
                                        }
                                    }
                                    
                                    if (viewModel.sessionCard.meetingCollaborations ?? []).count > 3 {
                                        Button {
                                            viewModel.isShowSessionDetail = false
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
                        
                        VStack(spacing: 10) {
                            HStack(spacing: 10) {
                                Image.sessionCardDateIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 17)
                                
                                Text((viewModel.sessionCard.startAt?.toStringFormat(with: .ddMMMMyyyy)).orEmpty())
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
                                
                                Text("\((viewModel.sessionCard.startAt?.toStringFormat(with: .HHmm)).orEmpty()) – \((viewModel.sessionCard.endAt?.toStringFormat(with: .HHmm)).orEmpty())")
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
                                
                                Text("\(viewModel.sessionCard.slots.orZero()) \(LocalizableText.participant)")
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
                            
                            if viewModel.sessionCard.price.orEmpty() == "0" {
                                Text(LocalizableText.freeText)
                                    .font(.robotoBold(size: 16))
                                    .foregroundColor(.black)
                            } else {
                                Text(viewModel.sessionCard.price.orEmpty().toPriceFormat())
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
                            viewModel.isShowSessionDetail = false
                        }
                    
                    DinotisPrimaryButton(
                        text: LocalizableText.payLabel,
                        type: .adaptiveScreen,
                        textColor: .white,
                        bgColor: .DinotisDefault.primary) {
                            
                            if viewModel.freeTrans {
                                viewModel.onSendFreePayment()
                            } else {
                                viewModel.isShowSessionDetail = false
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                    withAnimation {
                                        viewModel.isShowPaymentOption = true
                                    }
                                }
                            }
                        }
                    
                }
                .padding(.top)
            }
            .padding()
            .padding(.vertical)
            .onDisappear {
                isDescComplete = false
            }
        }
    }
    
    struct PaymentTypeOption: View {
        @ObservedObject var viewModel: HomeListViewModel
        
        var body: some View {
            VStack(spacing: 16) {
                HStack {
                    Text(LocalizableText.paymentMethodLabel)
                        .font(.robotoBold(size: 14))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button {
                        viewModel.isShowPaymentOption = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                            .foregroundColor(Color(UIColor.systemGray4))
                    }
                }
                
                Spacer()
                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 16) {
                        Button {
                            DispatchQueue.main.async {
                                viewModel.isShowPaymentOption.toggle()
                                
                                Task {
                                    await viewModel.extraFees()
                                }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                withAnimation {
                                    viewModel.isShowCoinPayment = true
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
                        
                        Button {
                            viewModel.isShowPaymentOption = false
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                withAnimation {
                                    viewModel.routeToPaymentMethod()
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
                        .isHidden(!viewModel.sessionCard.isPrivate.orFalse(), remove: !viewModel.sessionCard.isPrivate.orFalse())
                    }
                    .padding(.bottom)
                }
                
            }
            .padding([.top, .horizontal])
            .onAppear{
                viewModel.onGetUser()
            }
        }
    }
    
    struct CoinPaymentSheetView: View {
        
        @ObservedObject var viewModel: HomeListViewModel
        
        var body: some View {
            VStack(spacing: 15) {
                HStack {
                    Text(LocalizableText.paymentConfirmationTitle)
                        .font(.robotoBold(size: 14))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button {
                        viewModel.isShowCoinPayment = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                            .foregroundColor(Color(UIColor.systemGray4))
                    }
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(LocalizableText.yourCoinLabel)
                            .font(.robotoBold(size: 12))
                            .foregroundColor(.black)
                        
                        HStack(alignment: .top) {
                            Image.coinBalanceIcon
                                .resizable()
                                .scaledToFit()
                                .frame(height: 15)
                            
                            Text("\((viewModel.userData?.coinBalance?.current).orEmpty().toPriceFormat())")
                                .font(.robotoBold(size: 14))
                                .foregroundColor((Int(viewModel.userData?.coinBalance?.current ?? "0") ?? 0) >= viewModel.totalPayment ? .DinotisDefault.primary : .DinotisDefault.red)
                        }
                    }
                    
                    Spacer()
                    
                    if (Int(viewModel.userData?.coinBalance?.current ?? "0") ?? 0) < viewModel.totalPayment {
                        Button {
                            DispatchQueue.main.async {
                                viewModel.isShowCoinPayment.toggle()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                viewModel.isShowAddCoin.toggle()
                            }
                        } label: {
                            Text(LocalizableText.addCoinLabel)
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
                .background(RoundedRectangle(cornerRadius: 12).foregroundColor(.DinotisDefault.lightPrimary))
                
                VStack(alignment: .leading) {
                    Text(LocalizableText.promoCodeTitle)
                        .font(.robotoBold(size: 12))
                        .foregroundColor(.black)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Group {
                                if viewModel.promoCodeSuccess {
                                    HStack {
                                        Text(viewModel.promoCode)
                                            .font(.robotoMedium(size: 12))
                                            .foregroundColor(viewModel.promoCodeSuccess ? Color(.systemGray) : .black)
                                        
                                        Spacer()
                                    }
                                } else {
                                    TextField(LocalizableText.promoCodeLabel, text: $viewModel.promoCode)
                                        .font(.robotoMedium(size: 12))
                                        .autocapitalization(.allCharacters)
                                        .disableAutocorrection(true)
                                }
                            }
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(UIColor.systemGray3), lineWidth: 1)
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
                                    Text(viewModel.promoCodeSuccess ? LocalizableText.changeLabel : LocalizableText.enterLabel)
                                        .font(.robotoBold(size: 12))
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
                                Image.talentProfileAttentionIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 10)
                                    .foregroundColor(.red)
                                Text(LocalizableText.paymentPromoNotFound)
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
                .background(RoundedRectangle(cornerRadius: 12).foregroundColor(.DinotisDefault.lightPrimary))
                
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(LocalizableText.paymentLabel)
                            
                            Spacer()
                            
                            Text(LocalizableText.applePayText)
                        }
                        
                        HStack {
                            Text(LocalizableText.feeSubTotalLabel)
                            
                            Spacer()
                            
                            Text("\(Int(viewModel.sessionCard.price.orEmpty()).orZero())".toCurrency())
                        }
                        
                        HStack {
                            Text(LocalizableText.feeApplication)
                            
                            Spacer()
                            
                            Text("\(viewModel.extraFee)".toCurrency())
                            
                        }
                        
                        HStack {
                            Text(LocalizableText.feeService)
                            
                            Spacer()
                            
                            Text("0".toCurrency())
                            
                        }
                    }
                    .font(.robotoMedium(size: 12))
                    .foregroundColor(.black)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        
                        if (viewModel.promoCodeData?.discountTotal).orZero() != 0 {
                            HStack {
                                Text(LocalizableText.discountLabel)
                                    .font(.robotoMedium(size: 10))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Text("-\((viewModel.promoCodeData?.discountTotal).orZero())".toCurrency())
                                    .font(.robotoMedium(size: 10))
                                    .foregroundColor(.red)
                            }
                        } else if (viewModel.promoCodeData?.amount).orZero() != 0 && (viewModel.promoCodeData?.discountTotal).orZero() == 0 {
                            HStack {
                                Text(LocalizableText.discountLabel)
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Text("-\((viewModel.promoCodeData?.amount).orZero())".toCurrency())
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.bottom)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 1.5)
                        .foregroundColor(.DinotisDefault.primary)
                    
                    HStack {
                        Text(LocalizableText.totalLabel)
                            .font(.robotoBold(size: 12))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Text("\(viewModel.totalPayment)")
                            .font(.robotoBold(size: 12))
                            .foregroundColor(.black)
                    }
                    
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).foregroundColor(.DinotisDefault.lightPrimary))
                
                Spacer()
                
                DinotisPrimaryButton(
                    text: LocalizableText.continuePaymentLabel,
                    type: .adaptiveScreen,
                    textColor: (Int(viewModel.userData?.coinBalance?.current ?? "0") ?? 0) < viewModel.totalPayment ? Color(.systemGray) : .white,
                    bgColor: (Int(viewModel.userData?.coinBalance?.current ?? "0") ?? 0) < viewModel.totalPayment ? Color(.systemGray4) : .DinotisDefault.primary) {
                        Task {
                            await viewModel.coinPayment()
                        }
                    }
                    .disabled((Int(viewModel.userData?.coinBalance?.current ?? "0") ?? 0) < viewModel.totalPayment || viewModel.isLoadingCoinPay)
            }
            .padding()
            .padding(.vertical)
            .onAppear {
                viewModel.getProductOnAppear()
            }
        }
    }
    
    struct AddCoinSheetView: View {
        
        @ObservedObject var viewModel: HomeListViewModel
        
        var body: some View {
            VStack(spacing: 20) {
                
                HStack {
                    Text(LocalizableText.addCoinLabel)
                        .font(.robotoBold(size: 14))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button {
                        viewModel.isShowAddCoin.toggle()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                            .foregroundColor(Color(UIColor.systemGray4))
                    }
                }
                
                VStack {
                    Text(LocalizableText.yourCoinLabel)
                        .font(.robotoRegular(size: 12))
                        .foregroundColor(.black)
                    
                    HStack(alignment: .top) {
                        Image.coinBalanceIcon
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)
                        
                        Text("\((viewModel.userData?.coinBalance?.current).orEmpty().toPriceFormat())")
                            .font(.robotoBold(size: 14))
                            .foregroundColor(.DinotisDefault.primary)
                    }
                    .multilineTextAlignment(.center)
                    
                    Text(LocalizableText.descriptionAddCoin)
                        .font(.robotoRegular(size: 10))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                }
                
                VStack {
                    if viewModel.isLoadingTrx {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        QGrid(viewModel.myProducts, columns: 4, vSpacing: 10, hSpacing: 10, vPadding: 5, hPadding: 5, isScrollable: false, showScrollIndicators: false) { item in
                            
                            Button {
                                viewModel.productSelected = item
                            } label: {
                                HStack {
                                    Spacer()
                                    
                                    Text(item.priceToString())
                                        .font(.robotoMedium(size: 12))
                                        .foregroundColor(.DinotisDefault.primary)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .foregroundColor((viewModel.productSelected ?? SKProduct()).id == item.id ? .DinotisDefault.lightPrimary : .clear)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.DinotisDefault.primary, lineWidth: 1)
                                )
                            }
                        }
                    }
                }
                .frame(height: 90)
                
                Spacer()
                
                VStack {
                    DinotisPrimaryButton(
                        text: LocalizableText.addCoinLabel,
                        type: .adaptiveScreen,
                        textColor: viewModel.isLoadingTrx || viewModel.productSelected == nil ? .DinotisDefault.lightPrimaryActive : .white,
                        bgColor: viewModel.isLoadingTrx || viewModel.productSelected == nil ? .DinotisDefault.lightPrimary : .DinotisDefault.primary
                    ) {
                        if let product = viewModel.productSelected {
                            viewModel.purchaseProduct(product: product)
                        }
                    }
                    .disabled(viewModel.isLoadingTrx || viewModel.productSelected == nil)
                    
                    DinotisSecondaryButton(
                        text: LocalizableText.helpLabel,
                        type: .adaptiveScreen,
                        textColor: viewModel.isLoadingTrx ? .white : .DinotisDefault.primary,
                        bgColor: viewModel.isLoadingTrx ? Color(UIColor.systemGray3) : .DinotisDefault.lightPrimary,
                        strokeColor: .DinotisDefault.primary) {
                            viewModel.openWhatsApp()
                        }
                        .disabled(viewModel.isLoadingTrx)
                }
            }
            .padding()
            .padding(.vertical)
            .onDisappear {
                viewModel.myProducts = []
            }
        }
    }
}

fileprivate struct Preview: View {
    
    init() {
        FontInjector.registerFonts()
    }
    
    var body: some View {
        HomeListView(viewModel: HomeListViewModel(type: .session, tab: .nearest, backToHome: {}), tabValue: .constant(.explore))
    }
}

#Preview {
    Preview()
}
