//
//  CreatorProfileDetailView+Component.swift
//  DinotisApp
//
//  Created by Irham Naufal on 07/11/23.
//

import SwiftUINavigation
import SwiftUI
import QGrid
import StoreKit
import DinotisDesignSystem
import DinotisData

extension CreatorProfileDetailView {
    @ViewBuilder
    func ProfileHeaderView() -> some View {
        VStack(spacing: 16) {
            HStack(alignment: viewModel.isManagementView ? .top : .center, spacing: 20) {
                DinotisImageLoader(urlString: (viewModel.talentData?.profilePhoto).orEmpty())
                    .scaledToFill()
                    .frame(width: 84, height: 84)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Group {
                            if viewModel.talentData?.isVerified ?? true {
                                Text("\(viewModel.talentName.orEmpty()) \(Image.Dinotis.accountVerifiedIcon)")
                                    
                            } else {
                                Text("\(viewModel.talentName.orEmpty())")
                            }
                        }
                        .font(.robotoBold(size: 16))
                        .minimumScaleFactor(0.9)
                        .lineLimit(2)
                        .foregroundColor(.black)
                        
                        Spacer()
                    }
                    
                    HStack(alignment: .top, spacing: 8) {
                        Image.talentProfileManagementIcon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 13)
                            .isHidden(viewModel.isManagementView, remove: true)
                        
                        Text(viewModel.isManagementView ? LocalizableText.managementCreatorLabel : viewModel.professionText)
                            .font(.robotoMedium(size: 12))
                            .minimumScaleFactor(0.9)
                            .foregroundColor(.DinotisDefault.black2)
                    }
                    
                    HStack(spacing: 4) {
                        Image.talentProfilePerson2Icon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16)
                        
                        Text("\((viewModel.talentData?.management?.managementTalents ?? []).count) \(LocalizableText.creatorTitle)")
                            .font(.robotoMedium(size: 12))
                            .minimumScaleFactor(0.9)
                            .foregroundColor(.DinotisDefault.black2)
                    }
                    .isHidden(!viewModel.isManagementView, remove: true)
                    
                    if let data = viewModel.talentData?.managements?.prefix(3), !data.isEmpty {
                        Button {
                            viewModel.isShowManagements = true
                        } label: {
                            (
                                Text(LocalizableText.managementName)
                                    .foregroundColor(.DinotisDefault.black2)
                                +
                                (
                                    Text(" \(data.compactMap({ $0.management?.user?.name}).joined(separator: ", ")) ")
                                        .foregroundColor(.DinotisDefault.secondary)
                                    +
                                    Text(LocalizableText.searchSeeAllLabel)
                                        .foregroundColor(.DinotisDefault.black2)
                                )
                            )
                            .font(.robotoBold(size: 12))
                        }
                    }
                }
            }
            
            if let avail = viewModel.talentData?.userAvailability?.availability, avail {
                VStack(spacing: 8) {
                    DinotisPrimaryButton(
                        text: "🔥 \(LocalizableText.requestPrivateLabel)",
                        type: .adaptiveScreen,
                        height: 40,
                        textColor: .white,
                        bgColor: .DinotisDefault.primary
                    ) {
                        viewModel.isShowBundlingSheet = true
                    }
                    .shineEffect()
                    
                    HStack(spacing: 6) {
                        Button {
                            viewModel.followUnfollowCreator()
                        } label: {
                            HStack(spacing: 4) {
                                if viewModel.isLoadingFollow {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                } else {
                                    Image.talentProfileHeartAddBlackIcon
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 20)
                                        .isHidden((viewModel.talentData?.isFollowed).orFalse(), remove: true)
                                    
                                    Text((viewModel.talentData?.isFollowed).orFalse() ? LocalizableText.unfollowLabel : LocalizableText.followLabel)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .foregroundColor((viewModel.talentData?.isFollowed).orFalse() ? .DinotisDefault.black2 : .DinotisDefault.primary)
                            .frame(maxWidth: .infinity, maxHeight: 40, alignment: .center)
                            .background((viewModel.talentData?.isFollowed).orFalse() ? Color(red: 0.91, green: 0.91, blue: 0.91) : .DinotisDefault.lightPrimary)
                            .cornerRadius(12)
                            .overlay {
                                if !(viewModel.talentData?.isFollowed).orFalse() {
                                    RoundedRectangle(cornerRadius: 12)
                                        .inset(by: 0.55)
                                        .stroke(Color.DinotisDefault.primary, lineWidth: 1)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            viewModel.isLastSubscribeSheet = false
                            viewModel.isShowSubscribeSheet = true
                        } label: {
                            HStack(spacing: 4) {
                                Image.talentProfileStarAddBlackIcon
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 20)
                                    .isHidden(!viewModel.canSubscribe, remove: true)
                                
                                Text(viewModel.canSubscribe ? LocalizableText.subscribeLabel : LocalizableText.unsubscribeLabel)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .foregroundColor(viewModel.canSubscribe ? .DinotisDefault.primary : .DinotisDefault.black2)
                            .frame(maxWidth: .infinity, maxHeight: 40, alignment: .center)
                            .background(viewModel.canSubscribe ? Color.DinotisDefault.lightPrimary : Color(red: 0.91, green: 0.91, blue: 0.91))
                            .cornerRadius(12)
                            .overlay {
                                if viewModel.canSubscribe {
                                    RoundedRectangle(cornerRadius: 12)
                                        .inset(by: 0.55)
                                        .stroke(Color.DinotisDefault.primary, lineWidth: 1)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .font(.robotoMedium(size: 14))
                }
                .isHidden(viewModel.isManagementView, remove: true)
            } else {
                HStack(spacing: 8) {
                    DinotisPrimaryButton(
                        text: "🔥 \(LocalizableText.requestPrivateLabel)",
                        type: .adaptiveScreen,
                        height: 40,
                        textColor: .white,
                        bgColor: .DinotisDefault.primary
                    ) {
                        viewModel.isShowBundlingSheet = true
                    }
                    .shineEffect()
                    
                    Button {
                        viewModel.followUnfollowCreator()
                    } label: {
                        HStack(spacing: 4) {
                            if viewModel.isLoadingFollow {
                                ProgressView()
                                    .progressViewStyle(.circular)
                            } else {
                                Image.talentProfileHeartAddBlackIcon
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 20)
                                    .isHidden((viewModel.talentData?.isFollowed).orFalse(), remove: true)
                                
                                Text((viewModel.talentData?.isFollowed).orFalse() ? LocalizableText.unfollowLabel : LocalizableText.followLabel)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .foregroundColor((viewModel.talentData?.isFollowed).orFalse() ? .DinotisDefault.black2 : .DinotisDefault.primary)
                        .frame(maxWidth: .infinity, maxHeight: 40, alignment: .center)
                        .background((viewModel.talentData?.isFollowed).orFalse() ? Color(red: 0.91, green: 0.91, blue: 0.91) : .DinotisDefault.lightPrimary)
                        .cornerRadius(12)
                        .overlay {
                            if !(viewModel.talentData?.isFollowed).orFalse() {
                                RoundedRectangle(cornerRadius: 12)
                                    .inset(by: 0.55)
                                    .stroke(Color.DinotisDefault.primary, lineWidth: 1)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .font(.robotoMedium(size: 14))
                }
                .isHidden(viewModel.isManagementView, remove: true)
            }
            
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func RatingView() -> some View {
        HStack {
            VStack(spacing: 4) {
                Text(LocalizableText.requestCardSessionText)
                    .font(.robotoRegular(size: 12))
                
                Text(((viewModel.talentData?.meetingCount).orZero()).kmbFormatter())
                    .font(.robotoBold(size: 16))
            }
            .foregroundColor(.DinotisDefault.black2)
            .frame(maxWidth: .infinity)
            
            Divider()
            
            VStack(spacing: 4) {
                Text(LocalizableText.talentDetailFollower)
                    .font(.robotoRegular(size: 12))
                
                Text(((viewModel.talentData?.followerCount).orZero()).kmbFormatter())
                    .font(.robotoBold(size: 16))
            }
            .foregroundColor(.DinotisDefault.black2)
            .frame(maxWidth: .infinity)
            
            Divider()
            
            VStack(spacing: 4) {
                Text(LocalizableText.talentDetailReviews)
                    .font(.robotoRegular(size: 12))
                
                HStack {
                    Image.feedbackStarYellow
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                    
                    Text((viewModel.talentData?.rating) ?? "-")
                        .font(.robotoBold(size: 16))
                }
            }
            .foregroundColor(.DinotisDefault.black2)
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 8)
        .background(Color.white)
    }
    
    @ViewBuilder
    func SectionHeaderView() -> some View {
        HStack(spacing: 0) {
            Button {
                viewModel.tabNumb = 0
            } label: {
                Text(viewModel.isManagementView ? LocalizableText.talentDetailInformation : LocalizableText.overviewLabel)
                    .font(.robotoBold(size: 14))
                    .foregroundColor(viewModel.tabNumb == 0 ? .DinotisDefault.black1 : .DinotisDefault.black3)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    .background(Color.white)
            }
            .buttonStyle(.plain)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(viewModel.tabNumb == 0 ? Color.DinotisDefault.primary : .DinotisDefault.lightPrimary)
                    .frame(height: 1)
            }
            
            Button {
                viewModel.tabNumb = 1
            } label: {
                Text(viewModel.isManagementView ? LocalizableText.creatorTitle : LocalizableText.publicSessionLabel)
                    .font(.robotoBold(size: 14))
                    .foregroundColor(viewModel.tabNumb == 1 ? .DinotisDefault.black1 : .DinotisDefault.black3)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    .background(Color.white)
            }
            .buttonStyle(.plain)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(viewModel.tabNumb == 1 ? Color.DinotisDefault.primary : .DinotisDefault.lightPrimary)
                    .frame(height: 1)
            }
            
            Button {
                viewModel.tabNumb = 2
                if viewModel.videos.isEmpty {
                    Task {
                        await viewModel.getVideoList(isMore: false)
                    }
                }
            } label: {
                Text(viewModel.isManagementView ? LocalizableText.tabSession : LocalizableText.exclusiveVideoLabel)
                    .font(.robotoBold(size: 14))
                    .foregroundColor(viewModel.tabNumb == 2 ? .DinotisDefault.black1 : .DinotisDefault.black3)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    .background(Color.white)
            }
            .buttonStyle(.plain)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(viewModel.tabNumb == 2 ? Color.DinotisDefault.primary : .DinotisDefault.lightPrimary)
                    .frame(height: 1)
            }
        }
        .animation(.easeInOut, value: viewModel.tabNumb)
        .background(Color.white)
        .overlay(alignment: .top) {
            Divider()
        }
    }
    
    @ViewBuilder
    func SectionContentView(geometry: GeometryProxy) -> some View {
        Group {
            switch viewModel.tabNumb {
            case 1:
                if viewModel.isManagementView {
                    CreatorList(geo: geometry)
                } else {
                    SessionsView()
                }
            case 2:
                if viewModel.isManagementView {
                    SessionsView()
                } else {
                    ExclusiveVideoView()
                }
            default:
                OverviewView(geometry: geometry)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
    }
    
    @ViewBuilder
    func OverviewView(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.isManagementView ? LocalizableText.talentDetailAboutUs : LocalizableText.talentDetailAboutMe)
                    .font(.robotoBold(size: 14))
                    .foregroundColor(.DinotisDefault.black3)
                
                Text((viewModel.talentData?.profileDescription).orEmpty())
                    .font(.robotoRegular(size: 14))
                    .foregroundColor(.DinotisDefault.black1)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(LocalizableText.talentDetailGallery)
                    .font(.robotoBold(size: 14))
                    .foregroundColor(.DinotisDefault.black3)
                
                if let data = viewModel.talentData?.userHighlights {
                    let width = geometry.size.width / 3
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: width)),
                        GridItem(.adaptive(minimum: width)),
                        GridItem(.adaptive(minimum: width)),
                    ],
                              spacing: 4,
                              content: {
                        ForEach(data.indices, id: \.self) { index in
                            let image = data[index]
                            DinotisImageLoader(urlString: image.imgUrl.orEmpty())
                                .frame(maxWidth: width, maxHeight: width)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .onTapGesture {
                                    viewModel.currentImageIndex = index
                                    DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                        withAnimation {
                                            viewModel.isShowImageDetail = true
                                        }
                                    }
                                }
                        }
                    })
                } else if (viewModel.talentData?.userHighlights ?? []).isEmpty {
                    Text(LocalizableText.galleryEmpty)
                        .font(.robotoRegular(size: 14))
                        .foregroundColor(.DinotisDefault.black3)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func CreatorList(geo: GeometryProxy) -> some View {
        LazyVGrid(
            columns: Array(
                repeating: GridItem(.flexible(), spacing: 10),
                count: hasRegularWidth ? 4 : 2
            )
        ) {
            if let data = viewModel.talentData?.management?.managementTalents {
                ForEach(data, id: \.id) { item in
                    Button {
                        viewModel.routeToMyTalent(talent: (item.user?.username).orEmpty())
                    } label: {
                        ManagementCreatorCard(
                            item.user,
                            width: geo.size.width/(hasRegularWidth ? 4 : 2) - 22
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    @ViewBuilder
    func ManagementCreatorCard(_ data: ManagementTalentData?, width: CGFloat) -> some View {
        var proffessionText: String {
            var text = ""
            let data = data?.stringProfessions?.compactMap({ $0 })
            text = data?.joined(separator: ", ") ?? ""
            return text
        }
        
        VStack(spacing: 0) {
            DinotisImageLoader(urlString: (data?.profilePhoto).orEmpty())
                .scaledToFill()
                .frame(width: width, height: width)
                .overlay(alignment: .bottomLeading) {
                    HStack(spacing: 4) {
                        Image.talentProfileStarIcon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16)
                        
                        // FIXME: Change this when the backend send rating response
                        Text((data?.rating) ?? "– ")
                            .font(.robotoRegular(size: 12))
                            .foregroundColor(.black)
                    }
                    .padding(4)
                    .background(Color.DinotisDefault.lightPrimary)
                    .cornerRadius(8, corners: .topRight)
                }
            
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text((data?.name).orEmpty())
                            .font(.robotoBold(size: 14))
                            .foregroundColor(.DinotisDefault.black1)
                        
                        if (data?.isVerified).orFalse() {
                            Image.sessionCardVerifiedIcon
                                .resizable()
                                .scaledToFit()
                                .frame(width: 11, height: 11)
                        }
                    }
                    
                    Text(proffessionText)
                        .font(.robotoRegular(size: 12))
                        .foregroundColor(.DinotisDefault.black2)
                }
                .lineLimit(1)
                
                Rectangle()
                    .fill(Color.DinotisDefault.lightPrimary)
                    .frame(height: 1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
        }
        .frame(width: width)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 8)
    }
    
    @ViewBuilder
    func ImageDetailView() -> some View {
        TabView(selection: $viewModel.currentImageIndex) {
            ForEach((viewModel.talentData?.userHighlights ?? []).indices, id: \.self) { index in
                let image = (viewModel.talentData?.userHighlights ?? [])[index]
                DinotisImageLoader(urlString: image.imgUrl.orEmpty())
                    .scaledToFit()
                    .cornerRadius(20)
                    .padding()
                    .tag(index)
            }
        }
        .tabViewStyle(.page)
        .tint(.DinotisDefault.primary)
        .background(Color.black.opacity(0.3).ignoresSafeArea())
        .onTapGesture {
            withAnimation {
                viewModel.isShowImageDetail = false
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                    viewModel.currentImageIndex = 0
                }
            }
        }
    }
    
    @ViewBuilder
    func SessionsView() -> some View {
        HStack {
            Text(LocalizableText.scheduleFilterLabel)
                .font(.robotoBold(size: 12))
                .foregroundColor(.DinotisDefault.black2)
            
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
                    Image(systemName: "slider.horizontal.3")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 14)
                        .foregroundColor(.DinotisDefault.primary)
                    
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
        
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizableText.bundlingText)
                .font(.robotoBold(size: 18))
                .foregroundColor(.DinotisDefault.black1)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false, content: {
                LazyHStack(alignment: .top, spacing: 8, content: {
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
                                participantsImgUrl: [],
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
                        } visitProfile: {}
                        .grayscale(item.isActive.orFalse() ? 0 : 1)
                        .buttonStyle(.plain)
                    }
                })
                .padding(.horizontal)
            })
        }
        .isHidden(viewModel.bundlingData.isEmpty, remove: true)
        
        if viewModel.meetingData.isEmpty {
            VStack(spacing: 16) {
                Image.talentProfileComingSoonImage
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 145)
                
                VStack(spacing: 4) {
                    Text(LocalizableText.sessionEmptyTitle)
                        .font(.robotoBold(size: 14))
                        .foregroundColor(.DinotisDefault.black1)
                    
                    (
                        Text(LocalizableText.sessionEmptyDesc(name: (viewModel.talentData?.name).orEmpty()))
                            .foregroundColor(.DinotisDefault.black2)
                        +
                        Text(LocalizableText.requestSession)
                            .foregroundColor(.DinotisDefault.secondary)
                    )
                    .font(.robotoRegular(size: 12))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                }
                
                DinotisPrimaryButton(
                    text: LocalizableText.requestSession,
                    type: .adaptiveScreen,
                    height: 44,
                    textColor: .white,
                    bgColor: .DinotisDefault.primary
                ) {
                    viewModel.showingRequest.toggle()
                }
            }
            .padding(.horizontal)
        } else {
            Group {
                Text(LocalizableText.talentDetailAvailableSessions)
                    .font(.robotoBold(size: 18))
                    .foregroundColor(.DinotisDefault.black1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ForEach(viewModel.meetingData.unique(), id: \.id) { items in
                    SessionCard(
                        with: SessionCardModel(
                            title: items.title.orEmpty(),
                            date: DateUtils.dateFormatter(items.startAt.orCurrentDate(), forFormat: .EEEEddMMMMyyyy),
                            startAt: DateUtils.dateFormatter(items.startAt.orCurrentDate(), forFormat: .HHmm),
                            endAt: DateUtils.dateFormatter(items.endAt.orCurrentDate(), forFormat: .HHmm),
                            isPrivate: items.isPrivate ?? false,
                            isVerified: (items.user?.isVerified) ?? false,
                            photo: (items.user?.profilePhoto).orEmpty(),
                            name: (items.user?.name).orEmpty(),
                            color: items.background ?? [],
                            participantsImgUrl: items.participantDetails?.compactMap({
                                $0.profilePhoto.orEmpty()
                            }) ?? [],
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
                    } visitProfile: {}
                        .grayscale(items.endAt.orCurrentDate() < Date() ? 1 : 0)
                        .onAppear {
                            Task {
                                if viewModel.meetingData.unique().last?.id == items.id && viewModel.nextCursorMeeting != nil {
                                    viewModel.meetingParam.skip = viewModel.meetingParam.take
                                    viewModel.meetingParam.take += 15
                                    await viewModel.getTalentMeeting(by: (viewModel.talentData?.id).orEmpty(), isMore: true)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.top, -16)
                }
            }
            .padding(.horizontal)
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
    
    @ViewBuilder
    func ExclusiveVideoView() -> some View {
        Group {
            ListHeaderView()
                .layoutPriority(1)
            
            if viewModel.isLoadingVideoList {
                LottieView(name: "regular-loading", loopMode: .loop)
                    .scaledToFit()
                    .frame(height: 50)
            } else {
                if viewModel.videos.isEmpty {
                    VStack(spacing: 21) {
                        Image.talentProfileEmptyVideo
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 240, maxHeight: 240)
                        
                        Text(LocalizableText.emptyUploadDesc)
                            .font(.robotoRegular(size: 14))
                            .foregroundColor(.DinotisDefault.black2)
                    }
                    .padding()
                } else {
                    Group {
                        ForEach(viewModel.videos, id: \.id) { video in
                            VideoCard(video)
                                .padding(.top, -16)
                                .onAppear {
                                    Task {
                                        if (viewModel.videos.last?.id).orEmpty() == video.id.orEmpty() && viewModel.nextCursorExclusiveVideo != nil {
                                            viewModel.videoParam.skip = viewModel.videoParam.take
                                            viewModel.videoParam.take += 5
                                            await viewModel.getVideoList(isMore: true)
                                        }
                                    }
                                }
                        }
                        
                        if viewModel.isLoadingMoreVideoList {
                            HStack {
                                Spacer()
                                
                                ProgressView()
                                    .progressViewStyle(.circular)
                                
                                Spacer()
                            }
                            .padding()
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func ListHeaderView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { scrollView in
                HStack(spacing: 8) {
                    ForEach(viewModel.sections, id: \.self) { section in
                        Button {
                            if viewModel.currentSection != section {
                                withAnimation {
                                    viewModel.currentSection = section
                                    scrollView.scrollTo(section, anchor: .center)
                                }
                                
                                Task {
                                    await viewModel.getVideoList(isMore: false)
                                }
                            }
                        } label: {
                            Text(viewModel.chipText(section))
                                .font(viewModel.currentSection == section ? .robotoBold(size: 14) : .robotoRegular(size: 14))
                                .foregroundColor(viewModel.currentSection == section ? .DinotisDefault.primary : .DinotisDefault.black1)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(viewModel.currentSection == section ? Color.DinotisDefault.lightPrimary : .white)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .inset(by: 0.5)
                                        .stroke(viewModel.currentSection == section ? Color.DinotisDefault.primary : Color.DinotisDefault.brightPrimary, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        .id(section)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    func VideoCard(_ video: MineVideoData) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            DinotisImageLoader(urlString: video.cover.orEmpty())
                .scaledToFill()
                .frame(maxWidth: 358, maxHeight: 202)
                .overlay {
                    Button {
                        viewModel.viewExclusiveVideo(item: video)
                    } label: {
                        ZStack {
                            Color.black.opacity(0.05)
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: 358, maxHeight: 202)
                    }
                    .buttonStyle(.plain)
                }
                .clipShape(RoundedRectangle(cornerRadius: 14))
            
            Button {
                viewModel.viewExclusiveVideo(item: video)
            } label: {
                VStack(alignment: .leading, spacing: 5) {
                    Text(video.title.orEmpty())
                        .font(.robotoBold(size: 16))
                        .foregroundColor(.DinotisDefault.black1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Text(viewModel.dateFormatter(video.createdAt.orCurrentDate()))
                            .font(.robotoMedium(size: 12))
                        
                        Circle()
                            .frame(width: 4, height: 4)
                        
                        Text((video.videoType?.rawValue).orEmpty().capitalized)
                            .font(.robotoMedium(size: 12))
                        
                        Circle()
                            .frame(width: 4, height: 4)
                        
                        Text((video.audienceType?.rawValue).orEmpty().capitalized)
                            .font(.robotoMedium(size: 12))
                    }
                    .foregroundColor(.DinotisDefault.black3)
                }
                
            }
            .buttonStyle(.plain)
            Divider()
        }
    }
    
    @ViewBuilder
    func SubscribeSheet() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(LocalizableText.subscribeLabel)
                    .font(.robotoBold(size: 16))
                    .foregroundColor(.DinotisDefault.black1)
                
                Spacer()
                
                Button {
                    viewModel.isShowSubscribeSheet = false
                    viewModel.isLastSubscribeSheet = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.DinotisDefault.black2)
                }
            }
            
            if viewModel.canSubscribe {
                SubscribeCard(price: (viewModel.talentData?.userAvailability?.price).orEmpty(), withButton: !viewModel.isLastSubscribeSheet) {
                    if (viewModel.talentData?.userAvailability?.price).orEmpty() == "0" {
                        // run free pay
                        viewModel.trySubscribe(with: 99)
                        viewModel.isShowSubscribeSheet = false
                    } else {
                        withAnimation {
                            viewModel.isLastSubscribeSheet = true
                        }
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(LocalizableText.paymentMethodLabel)
                        .font(.robotoBold(size: 14))
                        .foregroundColor(.black)
                    
                    Button {
                        Task {
                            viewModel.isShowSubscribeSheet = false
                            viewModel.isLastSubscribeSheet = false
                            viewModel.trySubscribe(with: 10)
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
                    .isHidden(true, remove: true)
                }
                .isHidden(!viewModel.isLastSubscribeSheet, remove: true)
            } else {
                SubscriptionDetail()
            }
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .onDisappear {
            viewModel.isLastSubscribeSheet = false
        }
    }
    
    @ViewBuilder
    func SubscriptionDetail() -> some View {
        SubscriptionCard(
            name: (viewModel.talentData?.name).orEmpty(),
            imgProfile: (viewModel.talentData?.profilePhoto).orEmpty(),
            isVerified: (viewModel.talentData?.isVerified).orFalse(),
            professions: [viewModel.professionText],
            endAt: (viewModel.talentData?.subscription?.endAt)
        )
        .frame(maxHeight: .infinity, alignment: .top)
        
        DinotisSecondaryButton(
            text: LocalizableText.cancelSubscriptionLabel,
            type: .adaptiveScreen,
            textColor: .DinotisDefault.primary,
            bgColor: .white,
            strokeColor: .DinotisDefault.primary
        ) {
            viewModel.isShowSubscribeSheet = false
            viewModel.showUnsubscribeAlert()
        }
    }
    
    @ViewBuilder
    func BundlingListSheet() -> some View {
        VStack(spacing: 18) {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 194, height: 5)
                .background(Color(red: 0.91, green: 0.91, blue: 0.91))
                .cornerRadius(31)
                .padding(.top)
            
            VStack(spacing: 8) {
                Text(LocalizableText.requestPrivateLabel)
                    .font(.robotoBold(size: 18))
                    .foregroundColor(.DinotisDefault.black1)
                
                Text(LocalizableText.requestPrivateDesc)
                    .font(.robotoRegular(size: 12))
                    .foregroundColor(.DinotisDefault.black3)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            if viewModel.rateCardList.unique().isEmpty {
                Image.talentProfileNoServiceImage
                    .resizable()
                    .scaledToFit()
                    .frame(height: 136)
                
                VStack(spacing: 4) {
                    Text(LocalizableText.sessionEmptyTitle)
                        .font(.robotoBold(size: 14))
                        .foregroundColor(.DinotisDefault.black1)
                    
                    (
                        Text(LocalizableText.sessionEmptyDesc(name: (viewModel.talentData?.name).orEmpty()))
                            .foregroundColor(.DinotisDefault.black2)
                        +
                        Text(LocalizableText.requestRatecardLabel)
                            .foregroundColor(.DinotisDefault.secondary)
                    )
                    .font(.robotoRegular(size: 12))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                }
                .padding(.horizontal)
                
                DinotisPrimaryButton(
                    text: LocalizableText.requestSession,
                    type: .adaptiveScreen,
                    height: 44,
                    textColor: .white,
                    bgColor: .DinotisDefault.primary
                ) {
                    viewModel.isLockPrivate = true
                    viewModel.isShowBundlingSheet = false
                    viewModel.requestSessionType = .privateType
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                        self.viewModel.showingRequest.toggle()
                    }
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding([.horizontal, .bottom])
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.rateCardList.unique(), id: \.id) { item in
                            RateHorizontalCardView(
                                item: item,
                                isTalent: false,
                                onTapDelete: {},
                                onTapEdit: {}
                            )
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
                    .padding()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    @ViewBuilder
    func RequestMenuSheet() -> some View {
        VStack(spacing: 18) {
            HStack {
                Text(LocalizableText.requestRatecardLabel)
                    .font(.robotoBold(size: 14))
                
                Spacer()
                
                Button {
                    viewModel.showingRequest = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.title2)
                }
            }
            .foregroundColor(.DinotisDefault.black2)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(LocalizableText.sessionTypeLabel)
                    .font(.robotoMedium(size: 12))
                    .foregroundColor(.DinotisDefault.black1)
                
                if viewModel.isLockPrivate {
                    Text(LocalizableText.privateVideoCallLabel)
                        .font(.robotoRegular(size: 12))
                        .foregroundColor(.DinotisDefault.black1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.DinotisDefault.lightPrimary)
                        .cornerRadius(6)
                } else {
                    Menu {
                        Button {
                            viewModel.requestSessionType = .groupType
                        } label: {
                            Label(LocalizableText.groupVideoCallLabel, systemImage: viewModel.requestSessionType == .groupType ? "checkmark" : "")
                        }
                        .tag(RequestScheduleType.groupType)
                        
                        Button {
                            viewModel.requestSessionType = .privateType
                        } label: {
                            Label(LocalizableText.privateVideoCallLabel, systemImage: viewModel.requestSessionType == .privateType ? "checkmark" : "")
                        }
                        .tag(RequestScheduleType.privateType)
                    } label: {
                        HStack(spacing: 8) {
                            Text(viewModel.requestSessionText)
                                .font(.robotoRegular(size: 12))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(.DinotisDefault.black1)
                        .padding()
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .inset(by: 0.5)
                                .stroke(Color(red: 0.91, green: 0.91, blue: 0.91), lineWidth: 1)
                            
                        )
                    }
                }
            }
            
            DinotisTextEditor(LocalizableText.defaultPlaceholder, label: LocalizableText.messageLabel, text: $viewModel.requestSessionMessage, errorText: .constant(nil), stroke: Color(red: 0.91, green: 0.91, blue: 0.91))
                .tint(.DinotisDefault.primary)
            
            DinotisPrimaryButton(
                text: LocalizableText.sendRequestLabel,
                type: .adaptiveScreen,
                height: 44, 
                textColor: .white,
                bgColor: viewModel.requestSessionMessage.isEmpty ? .DinotisDefault.black3.opacity(0.2) : .DinotisDefault.primary,
                isLoading: $viewModel.isLoading
            ) {
                Task {
                    await viewModel.sendRequest(type: viewModel.requestSessionType, message: viewModel.requestSessionMessage)
                }
            }
            .disabled(viewModel.requestSessionMessage.isEmpty)
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
        .onDisappear {
            viewModel.isLockPrivate = false
            viewModel.requestSessionMessage = ""
            viewModel.requestSessionType = .groupType
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
                
                Spacer()
                
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
    
    struct ManagementBottomSheet: View {
        @StateObject var viewModel: TalentProfileDetailViewModel
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(LocalizableText.listManagementLabel)
                    .font(.robotoBold(size: 16))
                    .foregroundColor(.DinotisDefault.black1)
                    .padding(.top, 6)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        if let data = viewModel.talentData?.managements {
                            ForEach(data, id: \.id) { item in
                                HStack(spacing: 12) {
                                    // FIXME: Add management photo url
                                    DinotisImageLoader(
                                        urlString: (item.management?.user?.profilePhoto).orEmpty(),
                                        width: 40,
                                        height: 40
                                    )
                                    .cornerRadius(8)
                                    
                                    // FIXME: Add management name
                                    Text((item.management?.user?.name).orEmpty())
                                        .font(.robotoMedium(size: 14))
                                        .foregroundColor(.DinotisDefault.black2)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                    
                                    Button {
                                        // FIXME: Add management username
                                        viewModel.isShowManagements = false
                                        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                                            viewModel.routeToManagement(username: (item.management?.user?.username).orEmpty())
                                        }
                                    } label: {
                                        Text(LocalizableText.seeText)
                                            .font(.robotoBold(size: 10))
                                            .foregroundColor(.white)
                                            .padding(.horizontal)
                                            .padding(.vertical, 10)
                                            .background(Color.DinotisDefault.primary)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    struct SlideOverCardView: View {
        
        @ObservedObject var viewModel: TalentProfileDetailViewModel
        @Binding var tab: TabRoute
        
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
                                    Text((viewModel.selectedMeeting?.description).orEmpty())
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
                                        (viewModel.selectedMeeting?.description).orEmpty().count < 150,
                                        remove: (viewModel.selectedMeeting?.description).orEmpty().count < 150
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
                                viewModel.onSendFreePayment{
                                    self.tab = .agenda
                                }
                            } else {
                                viewModel.isPresent = false
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                    withAnimation {
                                        if (viewModel.selectedMeeting?.price).orEmpty() == "0" {
                                            viewModel.onSendFreePayment{
                                                self.tab = .agenda
                                            }
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
    
    @ViewBuilder
    func SubscriptionInvoice() -> some View {
        let durationCounter = Calendar.current.dateComponents([.day], from: .now, to: viewModel.invoiceData.endAt.orCurrentDate()).day.orZero()
        
        VStack(spacing: 0) {
            HeaderView(title: LocalizableText.subscriptionSuccessLabel)
            
            ScrollView {
                Image.Dinotis.paymentSuccessImage
                    .resizable()
                    .scaledToFit()
                    .frame(height: 213)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 24)
                
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(LocalizableText.invoiceLabel)
                            .font(.robotoRegular(size: 12))
                        
                        Text((viewModel.invoiceData.id).orEmpty())
                            .font(.robotoBold(size: 14))
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(LocalizableText.creatorNameLabel)
                            .font(.robotoRegular(size: 12))
                        
                        Text((viewModel.invoiceData.user?.name).orEmpty())
                            .font(.robotoBold(size: 14))
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(LocalizableText.paymentMethodLabel)
                            .font(.robotoRegular(size: 12))
                        
                        Text(viewModel.invoiceData.subscriptionPayment?.paymentMethod?.name ?? LocalizableText.dinotisCoinLabel)
                            .font(.robotoBold(size: 14))
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(LocalizableText.durationLabel)
                            .font(.robotoRegular(size: 12))
                        
                        Text(durationCounter > 0 ? "\(durationCounter+1) \(LocalizableText.dayText)" : LocalizableText.adaptiveSubscribtionLabel)
                            .font(.robotoBold(size: 14))
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(LocalizableText.totalPaymentLabel)
                            .font(.robotoRegular(size: 12))
                        
                        Group {
                            if let amount = viewModel.invoiceData.subscriptionPayment?.amount,
                               amount != "0" {
                                Text("Rp\(amount.toDecimal())")
                            } else {
                                Text(LocalizableText.freeText)
                            }
                        }
                        .font(.robotoBold(size: 14))
                    }
                }
                .foregroundColor(.DinotisDefault.black2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }
            
            DinotisPrimaryButton(
                text: LocalizableText.doneLabel,
                type: .adaptiveScreen,
                textColor: .white,
                bgColor: .DinotisDefault.primary
            ) {
                viewModel.isShowInvoice = false
            }
            .padding()
        }
        .background(Color.DinotisDefault.baseBackground.ignoresSafeArea())
    }
}

#Preview(body: {
    CreatorProfileDetailView(viewModel: TalentProfileDetailViewModel(backToHome: {}, username: "ramzramzz"), tabValue: .constant(.agenda))
})
