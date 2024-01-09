//
//  UserScheduleDetail.swift
//  DinotisApp
//
//  Created by Gus Adi on 24/08/21.
//

import SwiftUI
import SwiftUITrackableScrollView
import CurrencyFormatter
import SwiftUINavigation
import OneSignal
import DinotisDesignSystem
import DinotisData
import QGrid
import StoreKit

struct UserScheduleDetail: View {
    
    @Environment(\.dismiss) var dismiss
    
    @Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
    
    @StateObject private var customerChatManager = CustomerChatManager()
    
    private var viewController: UIViewController? {
        self.viewControllerHolder.value
    }
    
    @ObservedObject var viewModel: ScheduleDetailViewModel
    @ObservedObject var stateObservable = StateObservable.shared
    
    @Binding var mainTabValue: TabRoute
    @AppStorage("isShowDetailScheduleTooltip") var isShowTooltip = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if let meetId = viewModel.dataBooking?.id {
                    
                    NavigationLink(
                        unwrapping: $viewModel.route,
                        case: /HomeRouting.talentProfileDetail,
                        destination: {viewModel in
                            CreatorProfileDetailView(viewModel: viewModel.wrappedValue, tabValue: $mainTabValue)
                        },
                        onNavigate: {_ in},
                        label: {
                            EmptyView()
                        }
                    )
                    
                    NavigationLink(
                        unwrapping: $viewModel.route,
                        case: /HomeRouting.dyteGroupVideoCall,
                        destination: {viewModel in
                            GroupVideoCallView(viewModel: viewModel.wrappedValue)
                        },
                        onNavigate: {_ in},
                        label: {
                            EmptyView()
                        }
                    )
                    
                    NavigationLink(
                        unwrapping: $viewModel.route,
                        case: /HomeRouting.feedbackAfterCall,
                        destination: { viewModel in
                            AftercallFeedbackView(viewModel: viewModel.wrappedValue)
                        },
                        onNavigate: {_ in},
                        label: {
                            EmptyView()
                        }
                    )
                    
                    NavigationLink(
                        unwrapping: $viewModel.route,
                        case: /HomeRouting.videoCall,
                        destination: {viewModel in
                            PrivateVideoCallView(viewModel: viewModel.wrappedValue)
                        },
                        onNavigate: {_ in},
                        label: {
                            EmptyView()
                        }
                    )
                    
                }
                
                ZStack(alignment: .top) {
                    Color.DinotisDefault.baseBackground
                        .edgesIgnoringSafeArea(.all)
                        .alert(isPresented: $viewModel.isRefreshFailed) {
                            Alert(
                                title: Text(LocaleText.attention),
                                message: Text(LocaleText.sessionExpireText),
                                dismissButton: .default(Text(LocaleText.returnText), action: {
                                    NavigationUtil.popToRootView()
                                    self.stateObservable.userType = 0
                                    self.stateObservable.isVerified = ""
                                    self.stateObservable.refreshToken = ""
                                    self.stateObservable.accessToken = ""
                                    self.stateObservable.isAnnounceShow = false
                                    OneSignal.setExternalUserId("")
                                })
                            )
                        }
                        .onAppear {
                            stateObservable.spotlightedIdentity = ""
                            viewModel.onAppearView()
                            viewModel.getProductOnAppear()
                            
                            StateObservable.shared.cameraPositionUsed = .front
                            StateObservable.shared.twilioRole = ""
                            StateObservable.shared.twilioUserIdentity = ""
                            StateObservable.shared.twilioAccessToken = ""
                        }
                    
                    VStack(spacing: 0) {
                        HeaderView(
                            type: .textHeader,
                            title: LocalizableText.videoCallDetailTitle,
                            leadingButton: {
                                DinotisElipsisButton(
                                    icon: .generalBackIcon,
                                    iconColor: .DinotisDefault.black1,
                                    bgColor: .DinotisDefault.white,
                                    strokeColor: nil,
                                    iconSize: 12,
                                    type: .primary, {
                                        if viewModel.isDirectToHome {
                                            self.viewModel.backToHome()
                                        } else {
                                            dismiss()
                                        }
                                    }
                                )
                                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 0)
                            }
                        )
                        
                        ScrollableContent(viewModel: viewModel, action: refreshList, participantCount: participantCount(data: viewModel.dataBooking))
                            .environmentObject(customerChatManager)
                        
                        if !(viewModel.dataBooking?.status).orEmpty().contains(SessionStatus.done.rawValue)  &&
                            viewModel.dataBooking != nil
                        {
                            BottomView(viewModel: viewModel)
                        }
                    }
                    .onChange(of: viewModel.successDetail) { _ in
                        
                        guard let meet = viewModel.dataBooking?.meeting else {return}
                        
                    }
                    
                }
                
                ZStack {
                    Color.black.opacity(viewModel.isShowingRules ? 0.4 : 0)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                viewModel.isShowingRules = false
                            }
                        }
                    
                    VStack {
                        Spacer()
                        
                        VStack {
                            Text(LocalizableText.videoCallRulesLabel)
                                .font(.robotoBold(size: 14))
                                .foregroundColor(.black)
                                .padding()
                            
                            HTMLStringView(htmlContent: viewModel.HTMLContent)
                                .font(.robotoRegular(size: 14))
                                .frame(height: geo.size.height/2)
                                .padding([.horizontal, .bottom])
                        }
                        .background(Color.white)
                        .clipShape(RoundedCorner(radius: 18, corners: [.topLeft, .topRight]))
                        
                    }
                    .edgesIgnoringSafeArea(.bottom)
                    .offset(y: viewModel.isShowingRules ? .zero : geo.size.height+100)
                }
                .sheet(unwrapping: $viewModel.route, case: /HomeRouting.scheduleNegotiationChat, onDismiss: {
                    customerChatManager.hasUnreadMessage = false
                }) { viewModel in
                    ScheduleNegotiationChatView(viewModel: viewModel.wrappedValue, isOnSheet: true)
                        .environmentObject(customerChatManager)
                        .dynamicTypeSize(.large)
                }
                .onChange(of: viewModel.tokenConversation, perform: { value in
                    customerChatManager.connect(accessToken: value, conversationName: (viewModel.dataBooking?.meeting?.meetingRequest?.id).orEmpty())
                })
                .onDisappear {
                    customerChatManager.disconnect()
                }
                
                AlreadyReviewAlert(viewModel: viewModel)
                    .isHidden(!viewModel.showAlreadyReview, remove: !viewModel.showAlreadyReview)
                
                Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            isShowTooltip = false
                        }
                    }
                    .isHidden(!isShowTooltip, remove: !isShowTooltip)
            }
            .navigationBarTitle(Text(""))
            .navigationBarHidden(true)
            .overlayPreferenceValue(BoundsPreference.self, alignment: .top, { value in
                if let preference = value.first(where: { item in
                    item.key == ScheduleDetailTooltip.review.value
                }), isShowTooltip {
                    GeometryReader { proxy in
                        let rect = proxy[preference.value]
                        
                        Button {
                            withAnimation {
                                isShowTooltip = false
                                if viewModel.reviewStars() > 0 {
                                    viewModel.showAlreadyReview.toggle()
                                } else {
                                    viewModel.showReviewSheet.toggle()
                                }
                            }
                            
                        } label: {
                            HStack {
                                Text(LocalizableText.sessionDetailrateForCreator)
                                    .font(.robotoMedium(size: 14))
                                    .foregroundColor(.DinotisDefault.black1)
                                
                                Spacer()
                                
                                HStack(spacing: 2) {
                                    ForEach(1...5, id: \.self) { rate in
                                        (viewModel.reviewStars() >= rate ?
                                         Image.sessionDetailMiniStarFilled : Image.sessionDetailMiniStarOutline
                                        )
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 26.4, height: 26.4)
                                    }
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 0)
                            )
                            .contentShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .dinotisTooltip(
                            $isShowTooltip,
                            id: ScheduleDetailTooltip.review.value,
                            width: 245,
                            height: 90
                        ) {
                            Text(LocalizableText.sessionDetailRatingTooltip)
                                .font(.robotoRegular(size: 14))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: rect.width, height: rect.height)
                        .offset(x: rect.minX, y: rect.minY)
                    }
                }
            })
            .sheet(isPresented: $viewModel.startPresented, content: {
                if #available(iOS 16.0, *) {
                    VStack(spacing: 15) {
                        
                        Spacer()
                        
                        Image.Dinotis.popoutImage
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                        
                        VStack(spacing: 35) {
                            VStack(spacing: 10) {
                                Text(LocaleText.startMeetingAlertTitle)
                                    .font(.robotoBold(size: 14))
                                    .foregroundColor(.black)
                                
                                Text(LocaleText.talentStartCallLabel)
                                    .font(.robotoRegular(size: 12))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 15) {
                                Button(action: {
                                    viewModel.startPresented.toggle()
                                }, label: {
                                    HStack {
                                        Spacer()
                                        Text(LocaleText.cancelText)
                                            .font(.robotoMedium(size: 12))
                                            .foregroundColor(.black)
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.secondaryViolet)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.DinotisDefault.primary, lineWidth: 1.0)
                                    )
                                })
                                
                                Button(action: {
                                    
                                    guard let meet = viewModel.dataBooking?.meeting else { return }
                                    
                                    viewModel.startPresented.toggle()
                                    
                                    if !(meet.isPrivate ?? false) {
                                            self.viewModel.routeToGroupCall(meeting: meet)
                                    } else {
                                        self.viewModel.routeToVideoCall(meeting: meet)
                                    }
                                }, label: {
                                    HStack {
                                        Spacer()
                                        Text(LocaleText.startNowText)
                                            .font(.robotoMedium(size: 12))
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.DinotisDefault.primary)
                                    .cornerRadius(12)
                                })
                            }
                        }
                    }
                    .padding()
                    .presentationDetents([.height(450)])
                    .dynamicTypeSize(.large)
                } else {
                    VStack(spacing: 15) {
                        
                        Spacer()
                        
                        Image.Dinotis.popoutImage
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                        
                        VStack(spacing: 35) {
                            VStack(spacing: 10) {
                                Text(LocaleText.startMeetingAlertTitle)
                                    .font(.robotoBold(size: 14))
                                    .foregroundColor(.black)
                                
                                Text(LocaleText.talentStartCallLabel)
                                    .font(.robotoRegular(size: 12))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 15) {
                                Button(action: {
                                    viewModel.startPresented.toggle()
                                }, label: {
                                    HStack {
                                        Spacer()
                                        Text(LocaleText.cancelText)
                                            .font(.robotoMedium(size: 12))
                                            .foregroundColor(.black)
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.secondaryViolet)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.DinotisDefault.primary, lineWidth: 1.0)
                                    )
                                })
                                
                                Button(action: {
                                    
                                    guard let meet = viewModel.dataBooking?.meeting else { return }
                                    
                                    viewModel.startPresented.toggle()
                                    
                                    if !(meet.isPrivate ?? false) {
                                        self.viewModel.routeToGroupCall(meeting: meet)
                                    } else {
                                        self.viewModel.routeToVideoCall(meeting: meet)
                                    }
                                }, label: {
                                    HStack {
                                        Spacer()
                                        Text(LocaleText.startNowText)
                                            .font(.robotoMedium(size: 12))
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.DinotisDefault.primary)
                                    .cornerRadius(12)
                                })
                            }
                        }
                    }
                    .padding()
                    .padding(.vertical)
                    .dynamicTypeSize(.large)
                }
                
            })
            .sheet(isPresented: $viewModel.isShowAttachments) {
                if #available(iOS 16.0, *) {
                    AttachmentBottomSheet(viewModel: viewModel)
                        .presentationDetents([.fraction(0.4), .fraction(0.6), .large])
                        .dynamicTypeSize(.large)
                } else {
                    AttachmentBottomSheet(viewModel: viewModel)
                        .dynamicTypeSize(.large)
                }
            }
            .sheet(isPresented: $viewModel.isShowWebView) {
                if let url = URL(string: viewModel.attachmentURL) {
#if os(iOS)
                    SafariViewWrapper(url: url)
                        .dynamicTypeSize(.large)
#else
                    WebView(url: url)
                        .dynamicTypeSize(.large)
#endif
                } else {
                    if #available(iOS 16.0, *) {
                        EmptyURLView(viewModel: viewModel)
                            .presentationDetents([.fraction(0.6)])
                            .dynamicTypeSize(.large)
                    } else {
                        EmptyURLView(viewModel: viewModel)
                            .dynamicTypeSize(.large)
                    }
                }
            }
            .sheet(isPresented: $viewModel.isShowCollabList, content: {
                if #available(iOS 16.0, *) {
                    SelectedCollabCreatorView(
                        isEdit: false,
                        isAudience: true,
                        arrUsername: .constant((viewModel.dataBooking?.meeting?.meetingCollaborations ?? []).compactMap({
                            $0.username
                        })),
                        arrTalent: .constant(viewModel.dataBooking?.meeting?.meetingCollaborations ?? [])) {
                            viewModel.isShowCollabList = false
                        } visitProfile: { item in
                            viewModel.routeToTalentProfile(username: item)
                        }
                        .presentationDetents([.medium, .large])
                        .dynamicTypeSize(.large)
                } else {
                    SelectedCollabCreatorView(
                        isEdit: false,
                        isAudience: true,
                        arrUsername: .constant((viewModel.dataBooking?.meeting?.meetingCollaborations ?? []).compactMap({
                            $0.username
                        })),
                        arrTalent: .constant(viewModel.dataBooking?.meeting?.meetingCollaborations ?? [])) {
                            viewModel.isShowCollabList = false
                        } visitProfile: { item in
                            viewModel.routeToTalentProfile(username: item)
                        }
                        .dynamicTypeSize(.large)
                }
            })
            .sheet(
                isPresented: $viewModel.showReviewSheet,
                content: {
                    if #available(iOS 16.0, *) {
                        ReviewSheetView(viewModel: viewModel)
                            .presentationDetents([.height(610), .large])
                            .presentationDragIndicator(.hidden)
                            .dynamicTypeSize(.large)
                    } else {
                        ReviewSheetView(viewModel: viewModel)
                            .dynamicTypeSize(.large)
                    }
                }
            )
            .sheet(isPresented: $viewModel.showAddCoin) {
                if #available(iOS 16.0, *) {
                    AddCoinBottomSheet(viewModel: viewModel)
                        .presentationDetents([.height(450)])
                } else {
                    AddCoinBottomSheet(viewModel: viewModel)
                }
            }
            .overlay {
                ReviewSuccessPopUp(viewModel: viewModel)
                    .isHidden(!viewModel.isReviewSuccess, remove: !viewModel.isReviewSuccess)
            }
        }
    }
    
    private func participantCount(data: UserBookingData?) -> Int {
        (data?.meeting?.participants).orZero()
    }
    
    func refreshList() {
        Task {
            await viewModel.getDetailBookingUser()
        }
    }
}

private extension UserScheduleDetail {
    
    struct AlreadyReviewAlert: View {
        @ObservedObject var viewModel: ScheduleDetailViewModel
        
        var body: some View {
            ZStack {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    VStack(spacing: 10) {
                        HStack(spacing: 2) {
                            ForEach(1...5, id: \.self) { rate in
                                (viewModel.reviewStars() >= rate ?
                                 Image.sessionDetailMiniStarFilled : Image.sessionDetailMiniStarOutline
                                )
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                            }
                        }
                        
                        Text(LocalizableText.tippingSuccessDesc)
                            .font(.robotoRegular(size: 12))
                            .foregroundColor(.DinotisDefault.black3)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 18)
                    
                    DinotisPrimaryButton(
                        text: LocalizableText.closeLabel,
                        type: .fixed(285),
                        height: 40,
                        textColor: .white,
                        bgColor: .DinotisDefault.primary
                    ) {
                        withAnimation {
                            viewModel.showAlreadyReview.toggle()
                        }
                    }
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(.white)
                )
            }
        }
    }
    
    struct ScrollableContent: View {
        
        @ObservedObject var viewModel: ScheduleDetailViewModel
        @EnvironmentObject var customerChatManager: CustomerChatManager
        var action: (() -> Void)
        var participantCount: Int
        
        @AppStorage("isFirstLaunchDetailSchedule") var isFirstLaunch: Bool = true
        @AppStorage("isShowDetailScheduleTooltip") var isShowTooltip = false
        
        var body: some View {
            ScrollViewReader { scroll in
                RefreshableScrollViews(action: action) {
                    if viewModel.isLoading {
                        HStack {
                            Spacer()
                            
                            ProgressView()
                                .progressViewStyle(.circular)
                            
                            Spacer()
                        }
                        .padding()
                    }
                    
                    if let detail = viewModel.dataBooking {
                        if viewModel.dataBooking?.meeting?.meetingRequest != nil {
                            if let detail = viewModel.dataBooking?.meeting {
                                VStack {
                                    Text(LocalizableText.detailScheduleTitle)
                                        .font(.robotoBold(size: 12))
                                        .foregroundColor(.black)
                                    
                                    HStack(spacing: 12) {
                                        if UIDevice.current.userInterfaceIdiom == .pad {
                                            VStack(alignment: .leading) {
                                                ZStack(alignment: .topLeading) {
                                                    HStack(spacing: 53) {
                                                        Rectangle()
                                                            .foregroundColor(viewModel.isPaymentDone(status: detail.status.orEmpty()) ? .DinotisDefault.primary : Color(.systemGray4))
                                                            .frame(width: 50, height: 2)
                                                            .padding(.leading, 75)
                                                        
                                                        Rectangle()
                                                            .foregroundColor(
                                                                viewModel.isWaitingCreatorConfirmationDone(
                                                                    status: detail.status.orEmpty(),
                                                                    isAccepted: detail.meetingRequest?.isAccepted
                                                                ) ? .DinotisDefault.primary
                                                                : Color(.systemGray4)
                                                            )
                                                            .frame(width: 50, height: 2)
                                                        
                                                        Rectangle()
                                                            .foregroundColor(
                                                                viewModel.isScheduleConfirmationDone(
                                                                    status: detail.status.orEmpty(),
                                                                    isConfirmed: detail.meetingRequest?.isConfirmed
                                                                ) ? .DinotisDefault.primary
                                                                : Color(.systemGray4)
                                                            )
                                                            .frame(width: 50, height: 2)
                                                        
                                                        Rectangle()
                                                            .foregroundColor(
                                                                viewModel.isScheduleStartedDone(status: detail.status.orEmpty()) ?
                                                                    .DinotisDefault.primary :
                                                                    Color(.systemGray4)
                                                            )
                                                            .frame(width: 50, height: 2)
                                                    }
                                                    .padding(.top, 17.5)
                                                    
                                                    HStack(alignment: .top, spacing: 3) {
                                                        VStack(spacing: 6) {
                                                            (viewModel.isPaymentDone(status: detail.status.orEmpty()) ? Image.sessionDetailActiveCheckmarkIcon : Image.sessionDetailInactiveCheckmarkIcon)
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 35, height: 35)
                                                            
                                                            Text(LocalizableText.stepPaymentDone)
                                                                .font(.robotoMedium(size: 10))
                                                                .foregroundColor(.DinotisDefault.primary)
                                                        }
                                                        .multilineTextAlignment(.center)
                                                        .frame(width: 100)
                                                        .padding(.leading, -12)
                                                        
                                                        VStack(spacing: 6) {
                                                            //FIXME: Fix the conditional logic
                                                            if viewModel.isWaitingCreatorConfirmationDone(
                                                                status: detail.status.orEmpty(),
                                                                isAccepted: detail.meetingRequest?.isAccepted
                                                            ) {
                                                                Image.sessionDetailActiveCheckmarkIcon
                                                                    .resizable()
                                                                    .scaledToFit()
                                                                    .frame(width: 35, height: 35)
                                                                
                                                                Text(LocalizableText.stepWaitingConfirmation)
                                                                    .font(.robotoMedium(size: 10))
                                                                    .foregroundColor(.DinotisDefault.primary)
                                                            } else if viewModel.isWaitingCreatorConfirmationFailed(
                                                                status: detail.status.orEmpty(),
                                                                isAccepted: detail.meetingRequest?.isAccepted
                                                            ) {
                                                                Image.sessionDetailXmarkIcon
                                                                    .resizable()
                                                                    .scaledToFit()
                                                                    .frame(width: 35, height: 35)
                                                                
                                                                Text(LocalizableText.stepWaitingConfirmation)
                                                                    .font(.robotoMedium(size: 10))
                                                                    .foregroundColor(.red)
                                                            } else {
                                                                Image.sessionDetailInactiveCheckmarkIcon
                                                                    .resizable()
                                                                    .scaledToFit()
                                                                    .frame(width: 35, height: 35)
                                                                
                                                                Text(LocalizableText.stepWaitingConfirmation)
                                                                    .font(.robotoMedium(size: 10))
                                                                    .foregroundColor(Color(.systemGray4))
                                                            }
                                                            
                                                        }
                                                        .multilineTextAlignment(.center)
                                                        .frame(width: 100)
                                                        
                                                        VStack(spacing: 6) {
                                                            //FIXME: Fix the conditional logic
                                                            if viewModel.isScheduleConfirmationDone(
                                                                status: detail.status.orEmpty(),
                                                                isConfirmed: detail.meetingRequest?.isConfirmed
                                                            ) {
                                                                (Image.sessionDetailActiveCheckmarkIcon)
                                                                    .resizable()
                                                                    .scaledToFit()
                                                                    .frame(width: 35, height: 35)
                                                                
                                                                Text(LocalizableText.stepSetSessionTime)
                                                                    .font(.robotoMedium(size: 10))
                                                                    .foregroundColor(.DinotisDefault.primary)
                                                            } else if viewModel.isScheduleConfirmationFailed(
                                                                status: detail.status.orEmpty(),
                                                                isConfirmed: detail.meetingRequest?.isConfirmed
                                                            ) {
                                                                Image.sessionDetailXmarkIcon
                                                                    .resizable()
                                                                    .scaledToFit()
                                                                    .frame(width: 35, height: 35)
                                                                
                                                                Text(LocalizableText.stepSetSessionTime)
                                                                    .font(.robotoMedium(size: 10))
                                                                    .foregroundColor(.red)
                                                            } else {
                                                                Image.sessionDetailInactiveCheckmarkIcon
                                                                    .resizable()
                                                                    .scaledToFit()
                                                                    .frame(width: 35, height: 35)
                                                                
                                                                Text(LocalizableText.stepSetSessionTime)
                                                                    .font(.robotoMedium(size: 10))
                                                                    .foregroundColor(Color(.systemGray4))
                                                            }
                                                            
                                                        }
                                                        .multilineTextAlignment(.center)
                                                        .frame(width: 100)
                                                        
                                                        VStack(spacing: 6) {
                                                            
                                                            (viewModel.isScheduleStartedDone(status: detail.status.orEmpty()) ?
                                                             Image.sessionDetailActiveCheckmarkIcon : Image.sessionDetailInactiveCheckmarkIcon
                                                            )
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 35, height: 35)
                                                            
                                                            Text(LocalizableText.stepSessionStart)
                                                                .font(.robotoMedium(size: 10))
                                                                .foregroundColor(
                                                                    viewModel.isScheduleStartedDone(status: detail.status.orEmpty()) ?
                                                                        .DinotisDefault.primary :
                                                                        Color(.systemGray4)
                                                                )
                                                            
                                                        }
                                                        .multilineTextAlignment(.center)
                                                        .frame(width: 100)
                                                        
                                                        VStack(spacing: 6) {
                                                            (viewModel.isScheduleEndedDone(status: detail.status.orEmpty()) ?
                                                             Image.sessionDetailActiveCheckmarkIcon : Image.sessionDetailInactiveCheckmarkIcon
                                                            )
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 35, height: 35)
                                                            
                                                            Text(LocaleText.detailScheduleStepFour)
                                                                .font(.robotoMedium(size: 10))
                                                                .foregroundColor(viewModel.isScheduleEndedDone(status: detail.status.orEmpty()) ? .DinotisDefault.primary : Color(.systemGray4))
                                                            
                                                        }
                                                        .multilineTextAlignment(.center)
                                                        .frame(width: 100)
                                                    }
                                                    .padding(.horizontal, 10)
                                                }
                                            }
                                        } else {
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                VStack(alignment: .leading) {
                                                    ZStack(alignment: .topLeading) {
                                                        HStack(spacing: 53) {
                                                            Rectangle()
                                                                .foregroundColor(viewModel.isPaymentDone(status: detail.status.orEmpty()) ? .DinotisDefault.primary : Color(.systemGray4))
                                                                .frame(width: 50, height: 2)
                                                                .padding(.leading, 75)
                                                            
                                                            Rectangle()
                                                                .foregroundColor(
                                                                    viewModel.isWaitingCreatorConfirmationDone(
                                                                        status: detail.status.orEmpty(),
                                                                        isAccepted: detail.meetingRequest?.isAccepted
                                                                    ) ? .DinotisDefault.primary
                                                                    : Color(.systemGray4)
                                                                )
                                                                .frame(width: 50, height: 2)
                                                            
                                                            Rectangle()
                                                                .foregroundColor(
                                                                    viewModel.isScheduleConfirmationDone(
                                                                        status: detail.status.orEmpty(),
                                                                        isConfirmed: detail.meetingRequest?.isConfirmed
                                                                    ) ? .DinotisDefault.primary
                                                                    : Color(.systemGray4)
                                                                )
                                                                .frame(width: 50, height: 2)
                                                            
                                                            Rectangle()
                                                                .foregroundColor(
                                                                    viewModel.isScheduleStartedDone(status: detail.status.orEmpty()) ?
                                                                        .DinotisDefault.primary :
                                                                        Color(.systemGray4)
                                                                )
                                                                .frame(width: 50, height: 2)
                                                        }
                                                        .padding(.top, 17.5)
                                                        
                                                        HStack(alignment: .top, spacing: 3) {
                                                            VStack(spacing: 6) {
                                                                (viewModel.isPaymentDone(status: detail.status.orEmpty()) ?
                                                                 Image.sessionDetailActiveCheckmarkIcon : Image.sessionDetailInactiveCheckmarkIcon
                                                                )
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 35, height: 35)
                                                                
                                                                Text(LocalizableText.stepPaymentDone)
                                                                    .font(.robotoMedium(size: 10))
                                                                    .foregroundColor(viewModel.isPaymentDone(status: detail.status.orEmpty()) ? .DinotisDefault.primary : Color(.systemGray4))
                                                            }
                                                            .multilineTextAlignment(.center)
                                                            .frame(width: 100)
                                                            .padding(.leading, -12)
                                                            
                                                            VStack(spacing: 6) {
                                                                //FIXME: Fix the conditional logic
                                                                if viewModel.isWaitingCreatorConfirmationDone(
                                                                    status: detail.status.orEmpty(),
                                                                    isAccepted: detail.meetingRequest?.isAccepted
                                                                ) {
                                                                    Image.sessionDetailActiveCheckmarkIcon
                                                                        .resizable()
                                                                        .scaledToFit()
                                                                        .frame(width: 35, height: 35)
                                                                    
                                                                    Text(LocalizableText.stepWaitingConfirmation)
                                                                        .font(.robotoMedium(size: 10))
                                                                        .foregroundColor(.DinotisDefault.primary)
                                                                } else if viewModel.isWaitingCreatorConfirmationFailed(
                                                                    status: detail.status.orEmpty(),
                                                                    isAccepted: detail.meetingRequest?.isAccepted
                                                                ) {
                                                                    Image.sessionDetailXmarkIcon
                                                                        .resizable()
                                                                        .scaledToFit()
                                                                        .frame(width: 35, height: 35)
                                                                    
                                                                    Text(LocalizableText.stepWaitingConfirmation)
                                                                        .font(.robotoMedium(size: 10))
                                                                        .foregroundColor(.red)
                                                                } else {
                                                                    Image.sessionDetailInactiveCheckmarkIcon
                                                                        .resizable()
                                                                        .scaledToFit()
                                                                        .frame(width: 35, height: 35)
                                                                    
                                                                    Text(LocalizableText.stepWaitingConfirmation)
                                                                        .font(.robotoMedium(size: 10))
                                                                        .foregroundColor(Color(.systemGray4))
                                                                }
                                                                
                                                            }
                                                            .multilineTextAlignment(.center)
                                                            .frame(width: 100)
                                                            
                                                            VStack(spacing: 6) {
                                                                //FIXME: Fix the conditional logic
                                                                if viewModel.isScheduleConfirmationDone(
                                                                    status: detail.status.orEmpty(),
                                                                    isConfirmed: detail.meetingRequest?.isConfirmed
                                                                ) {
                                                                    Image.sessionDetailActiveCheckmarkIcon
                                                                        .resizable()
                                                                        .scaledToFit()
                                                                        .frame(width: 35, height: 35)
                                                                    
                                                                    Text(LocalizableText.stepSetSessionTime)
                                                                        .font(.robotoMedium(size: 10))
                                                                        .foregroundColor(.DinotisDefault.primary)
                                                                } else if viewModel.isScheduleConfirmationFailed(
                                                                    status: detail.status.orEmpty(),
                                                                    isConfirmed: detail.meetingRequest?.isConfirmed
                                                                ) {
                                                                    Image.sessionDetailXmarkIcon
                                                                        .resizable()
                                                                        .scaledToFit()
                                                                        .frame(width: 35, height: 35)
                                                                    
                                                                    Text(LocalizableText.stepSetSessionTime)
                                                                        .font(.robotoMedium(size: 10))
                                                                        .foregroundColor(.red)
                                                                } else {
                                                                    Image.sessionDetailInactiveCheckmarkIcon
                                                                        .resizable()
                                                                        .scaledToFit()
                                                                        .frame(width: 35, height: 35)
                                                                    
                                                                    Text(LocalizableText.stepSetSessionTime)
                                                                        .font(.robotoMedium(size: 10))
                                                                        .foregroundColor(Color(.systemGray4))
                                                                }
                                                                
                                                            }
                                                            .multilineTextAlignment(.center)
                                                            .frame(width: 100)
                                                            
                                                            VStack(spacing: 6) {
                                                                
                                                                (viewModel.isScheduleStartedDone(status: detail.status.orEmpty()) ?
                                                                 Image.sessionDetailActiveCheckmarkIcon : Image.sessionDetailInactiveCheckmarkIcon
                                                                )
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 35, height: 35)
                                                                
                                                                Text(LocalizableText.stepSessionStart)
                                                                    .font(.robotoMedium(size: 10))
                                                                    .foregroundColor(
                                                                        viewModel.isScheduleStartedDone(status: detail.status.orEmpty()) ?
                                                                            .DinotisDefault.primary :
                                                                            Color(.systemGray4)
                                                                    )
                                                                
                                                            }
                                                            .multilineTextAlignment(.center)
                                                            .frame(width: 100)
                                                            
                                                            VStack(spacing: 6) {
                                                                (viewModel.isScheduleEndedDone(status: detail.status.orEmpty()) ?
                                                                 Image.sessionDetailActiveCheckmarkIcon : Image.sessionDetailInactiveCheckmarkIcon
                                                                )
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 35, height: 35)
                                                                
                                                                Text(LocalizableText.stepSessionDone)
                                                                    .font(.robotoMedium(size: 10))
                                                                    .foregroundColor(viewModel.isScheduleEndedDone(status: detail.status.orEmpty()) ? .DinotisDefault.primary : Color(.systemGray4))
                                                                
                                                            }
                                                            .multilineTextAlignment(.center)
                                                            .frame(width: 100)
                                                        }
                                                        .padding(.horizontal, 10)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .foregroundColor(.white)
                                        .shadow(color: Color.dinotisShadow.opacity(0.08), radius: 10, x: 0, y: 0)
                                )
                                .padding([.top, .horizontal])
                            }
                        } else {
                            if let detail = viewModel.dataBooking?.meeting, let bookingPay = viewModel.dataBooking?.bookingPayment {
                                VStack {
                                    Text(LocalizableText.detailScheduleTitle)
                                        .font(.robotoBold(size: 12))
                                        .foregroundColor(.black)
                                    
                                    HStack(spacing: 3) {
                                        VStack(alignment: .leading) {
                                            HStack(spacing: 3) {
                                                HStack(spacing: 3) {
                                                    
                                                    (bookingPay.paidAt != nil ? Image.sessionDetailActiveCheckmarkIcon : Image.sessionDetailInactiveCheckmarkIcon)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(height: 35)
                                                    
                                                    Rectangle()
                                                        .foregroundColor(bookingPay.paidAt != nil ? .DinotisDefault.primary : Color(.systemGray4))
                                                        .frame(height: 2)
                                                    
                                                }
                                                
                                                HStack(spacing: 3) {
                                                    
                                                    (bookingPay.paidAt != nil ? Image.sessionDetailActiveCheckmarkIcon : Image.sessionDetailInactiveCheckmarkIcon)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(height: 35)
                                                    
                                                    Rectangle()
                                                        .foregroundColor(bookingPay.paidAt != nil ? .DinotisDefault.primary : Color(.systemGray4))
                                                        .frame(height: 2)
                                                    
                                                }
                                                
                                                HStack(spacing: 3) {
                                                    
                                                    (
                                                        detail.startedAt != nil ||
                                                        detail.startAt.orCurrentDate() <= Date() ?
                                                        Image.sessionDetailActiveCheckmarkIcon : Image.sessionDetailInactiveCheckmarkIcon
                                                    )
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 35)
                                                    
                                                    Rectangle()
                                                        .foregroundColor(
                                                            detail.startedAt != nil ||
                                                            detail.startAt.orCurrentDate() <= Date() ?
                                                                .DinotisDefault.primary :
                                                                Color(.systemGray4)
                                                        )
                                                        .frame(height: 2)
                                                    
                                                }
                                                
                                                HStack(spacing: 3) {
                                                    
                                                    (detail.endedAt != nil ? Image.sessionDetailActiveCheckmarkIcon : Image.sessionDetailInactiveCheckmarkIcon)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(height: 35)
                                                }
                                            }
                                            .padding(.horizontal, 10)
                                            
                                            HStack {
                                                VStack(spacing: 6) {
                                                    Text(LocalizableText.stepPaymentDone)
                                                        .font(.robotoMedium(size: 10))
                                                        .foregroundColor(bookingPay.paidAt != nil ? .DinotisDefault.primary : Color(.systemGray4))
                                                }
                                                .multilineTextAlignment(.center)
                                                .frame(width: 55)
                                                
                                                Spacer()
                                                
                                                VStack(spacing: 6) {
                                                    Text(LocalizableText.stepWaitingForSession)
                                                        .font(.robotoMedium(size: 10))
                                                        .foregroundColor(bookingPay.paidAt != nil ? .DinotisDefault.primary : Color(.systemGray4))
                                                    
                                                }
                                                .multilineTextAlignment(.center)
                                                .frame(width: 55)
                                                
                                                Spacer()
                                                
                                                VStack(spacing: 6) {
                                                    Text(LocalizableText.stepSessionStart)
                                                        .font(.robotoMedium(size: 10))
                                                        .foregroundColor(
                                                            detail.startedAt != nil ||
                                                            detail.startAt.orCurrentDate() <= Date() ?
                                                                .DinotisDefault.primary :
                                                                Color(.systemGray4)
                                                        )
                                                    
                                                }
                                                .multilineTextAlignment(.center)
                                                .frame(width: 55)
                                                
                                                Spacer()
                                                
                                                VStack(spacing: 6) {
                                                    Text(LocalizableText.stepSessionDone)
                                                        .font(.robotoMedium(size: 10))
                                                        .foregroundColor(detail.endedAt != nil ? .DinotisDefault.primary : Color(.systemGray4))
                                                    
                                                }
                                                .multilineTextAlignment(.center)
                                                .frame(width: 55)
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .foregroundColor(.white)
                                        .shadow(color: Color.dinotisShadow.opacity(0.08), radius: 10, x: 0, y: 0)
                                )
                                .padding([.top, .horizontal])
                            }
                        }
                        
                        if viewModel.dataBooking?.meeting?.meetingRequest != nil {
                            
                            if !(viewModel.dataBooking?.meeting?.meetingRequest?.isConfirmed ?? false) {
                                HStack {
                                    Image.Dinotis.noticeIcon
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 23, height: 23)
                                    
                                    Text(LocaleText.waitingConfirmationCaption)
                                        .font(.robotoRegular(size: 10))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color.infoColor)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.DinotisDefault.primary, lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding(.top, 6)
                                .padding(.horizontal)
                            }
                            
                            if let accept = viewModel.dataBooking?.meeting?.meetingRequest?.isAccepted, accept {
                                Button {
                                    guard let data = viewModel.dataBooking?.meeting else { return }
                                    viewModel.routeToScheduleNegotiationChat(meet: data)
                                } label: {
                                    HStack {
                                        Image.Dinotis.messageIcon
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 16, height: 16)
                                        
                                        Text(LocaleText.discussWithCreator)
                                            .font(.robotoMedium(size: 12))
                                            .foregroundColor(.black)
                                        
                                        Spacer()
                                        
                                        Circle()
                                            .foregroundColor(.DinotisDefault.primary)
                                            .scaledToFit()
                                            .frame(height: 15)
                                            .isHidden(!customerChatManager.hasUnreadMessage, remove: !customerChatManager.hasUnreadMessage)
                                        
                                        Image(systemName: "chevron.right")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(.black)
                                            .frame(width: 8)
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .foregroundColor(.white)
                                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 0)
                                    )
                                    .padding(.horizontal)
                                    .padding(.top, 10)
                                }
                            }
                        } else {
                            Button {
                                withAnimation(.spring()) {
                                    viewModel.isShowingRules.toggle()
                                }
                                
                            } label: {
                                HStack {
                                    Text(LocalizableText.videoCallRulesLabel)
                                        .font(.robotoRegular(size: 14))
                                        .foregroundColor(.DinotisDefault.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 10)
                                        .foregroundColor(.DinotisDefault.primary)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 20)
                                .background(RoundedRectangle(cornerRadius: 12).foregroundColor(.DinotisDefault.lightPrimary))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.DinotisDefault.primary, lineWidth: 1))
                                .padding(.top, 10)
                                .padding(.horizontal)
                            }
                        }
                        
                        if let isRefunded = viewModel.dataBooking?.meeting?.meetingRequest?.isAccepted, !isRefunded {
                            HStack {
                                Text(LocalizableText.refundStatus)
                                    .font(.robotoRegular(size: 12))
                                    .foregroundColor(.DinotisDefault.black2)
                                
                                Spacer()
                                
                                Text(LocalizableText.alreadyRefund)
                                    .font(.robotoRegular(size: 12))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.DinotisDefault.primary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .foregroundColor(Color(red: 0.95, green: 0.89, blue: 1))
                                    )
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(.DinotisDefault.lightPrimary)
                            )
                            .padding(.horizontal)
                            .padding(.top, 5)
                        }
                        
                        VStack(alignment: .leading, spacing: 20) {
                            if detail.meeting?.endedAt != nil {
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
                            } else if detail.meeting?.meetingRequest != nil && detail.meeting?.meetingRequest?.isAccepted == nil {
                                Text(LocalizableText.creatorConfirmationStatus)
                                    .multilineTextAlignment(.center)
                                    .font(.robotoBold(size: 12))
                                    .foregroundColor(.DinotisDefault.orange)
                                    .padding(10)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .background(
                                        Capsule()
                                            .foregroundColor(.DinotisDefault.lightOrange)
                                    )
                            } else if let accepted = detail.meeting?.meetingRequest?.isAccepted, detail.meeting?.meetingRequest != nil && accepted && detail.meeting?.startAt == nil {
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
                            } else if detail.meeting?.startAt != nil {
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
                            } else if let canceled = detail.meeting?.meetingRequest?.isAccepted, detail.meeting?.meetingRequest != nil && !canceled {
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
                            
                            HStack(spacing: 15) {
                                DinotisImageLoader(urlString: (viewModel.dataBooking?.meeting?.user?.profilePhoto).orEmpty())
                                    .scaledToFill()
                                    .frame(width: 48, height: 48)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    if viewModel.dataBooking?.meeting?.user?.isVerified ?? false {
                                        Text("\((viewModel.dataBooking?.meeting?.user?.name).orEmpty()) \(Image.sessionCardVerifiedIcon)")
                                            .font(.robotoBold(size: 14))
                                            .foregroundColor(.black)
                                    } else {
                                        Text("\((viewModel.dataBooking?.meeting?.user?.name).orEmpty())")
                                            .font(.robotoBold(size: 14))
                                            .foregroundColor(.black)
                                    }
                                    
                                    HStack {
                                        Image.talentProfileManagementIcon
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 13)
                                        
                                        Text((viewModel.dataBooking?.meeting?.user?.stringProfessions?.joined(separator: ", ")).orEmpty())
                                            .font(.robotoRegular(size: 12))
                                            .foregroundColor(.DinotisDefault.black1)
                                    }
                                }
                                
                                Spacer()
                            }
                            
                            VStack(alignment:.leading, spacing: 5) {
                                Text((detail.meeting?.title).orEmpty())
                                    .font(.robotoBold(size: 16))
                                    .foregroundColor(.black)
                                
                                VStack(alignment: .leading) {
                                    Text((detail.meeting?.meetingDescription).orEmpty())
                                        .font(.robotoRegular(size: 12))
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(viewModel.isTextComplete ? nil : 3)
                                    
                                    HStack {
                                        Button {
                                            withAnimation {
                                                viewModel.isTextComplete.toggle()
                                            }
                                        } label: {
                                            Text(viewModel.isTextComplete ? LocalizableText.bookingRateCardHideFullText : LocalizableText.bookingRateCardShowFullText)
                                                .font(.robotoMedium(size: 12))
                                                .foregroundColor(.DinotisDefault.primary)
                                        }
                                        
                                        Spacer()
                                    }
                                    .isHidden(
                                        (detail.meeting?.meetingDescription).orEmpty().count < 150,
                                        remove: (detail.meeting?.meetingDescription).orEmpty().count < 150
                                    )
                                }
                            }
                            
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 10) {
                                    Image.sessionCardDateIcon
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 20)
                                    
                                    if let dateStart = detail.meeting?.startAt {
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
                                    
                                    if let timeStart = viewModel.dataBooking?.meeting?.startAt,
                                       let timeEnd = viewModel.dataBooking?.meeting?.endAt {
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
                                    
                                    if let data = viewModel.dataBooking {
                                        Text("\(String.init(participantCount))/\(String.init((data.meeting?.slots).orZero())) \(LocalizableText.participant)")
                                            .font(.robotoRegular(size: 12))
                                            .foregroundColor(.black)
                                        
                                        Text((!(data.meeting?.isPrivate ?? false)) ? LocalizableText.groupSessionLabelWithEmoji : LocalizableText.privateSessionLabelWithEmoji)
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
                            }
                            .valueChanged(value: viewModel.isLoadingDetail) { value in
                                DispatchQueue.main.async {
                                    withAnimation(.spring()) {
                                        self.viewModel.isLoading = value
                                    }
                                }
                            }
                            
                            CollaboratorView(viewModel: viewModel)
                                .isHidden((viewModel.dataBooking?.meeting?.meetingCollaborations ?? []).isEmpty, remove: (viewModel.dataBooking?.meeting?.meetingCollaborations ?? []).isEmpty)
                            
                            ParticipantView(viewModel: viewModel)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 0)
                        .padding(.top, 10)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                        
                        if !(viewModel.dataBooking?.meeting?.meetingUrls?.isEmpty).orFalse() {
                            Button {
                                viewModel.isShowAttachments = true
                            } label: {
                                HStack {
                                    Image.icDocumentSessionDetail
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 32)
                                    
                                    Text(LocalizableText.attachmentsText)
                                        .font(.robotoMedium(size: 14))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Image.sessionDetailChevronIcon
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 0)
                                )
                                .padding(.horizontal)
                            }
                            .padding(.bottom, 10)
                        }
                        
                        if viewModel.isShowRating() {
                            Button {
                                withAnimation {
                                    if viewModel.reviewStars() > 0 {
                                        viewModel.showAlreadyReview.toggle()
                                    } else {
                                        viewModel.showReviewSheet.toggle()
                                    }
                                }
                                
                            } label: {
                                HStack {
                                    Text(LocalizableText.sessionDetailrateForCreator)
                                        .font(.robotoMedium(size: 14))
                                        .foregroundColor(.DinotisDefault.black1)
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 2) {
                                        ForEach(1...5, id: \.self) { rate in
                                            (viewModel.reviewStars() >= rate ?
                                             Image.sessionDetailMiniStarFilled : Image.sessionDetailMiniStarOutline
                                            )
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 26.4, height: 26.4)
                                        }
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 0)
                                )
                                .contentShape(RoundedRectangle(cornerRadius: 6))
                            }
                            .dinotisTooltip(
                                $isShowTooltip,
                                id: ScheduleDetailTooltip.review.value,
                                width: 241,
                                height: 90
                            ) {
                                Text(LocalizableText.sessionDetailRatingTooltip)
                                    .font(.robotoRegular(size: 14))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            }
                            .id(ScheduleDetailTooltip.review.value)
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                            
                        }
                        
                        Button(action: {
                            if let waurl = URL(string: "https://wa.me/6281318506068") {
                                if UIApplication.shared.canOpenURL(waurl) {
                                    UIApplication.shared.open(waurl, options: [:], completionHandler: nil)
                                }
                            }
                        }, label: {
                            HStack {
                                Image.talentProfileWhatsappIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 32)
                                
                                HStack(spacing: 5) {
                                    Text(LocalizableText.needHelpQuestion)
                                        .font(.robotoRegular(size: 14))
                                        .foregroundColor(.black)
                                    
                                    Text(LocalizableText.contactUsLabel)
                                        .font(.robotoBold(size: 14))
                                        .foregroundColor(.black)
                                }
                                
                                Spacer()
                                
                                Image.sessionDetailChevronIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 0)
                            )
                            .padding(.horizontal)
                        })
                        .padding(.bottom)
                    }
                }
                .onChange(of: viewModel.dataBooking?.id, perform: { newValue in
                    if newValue != nil && viewModel.isShowRating() {
                        scroll.scrollTo(ScheduleDetailTooltip.review.value)
                        
                        if isFirstLaunch {
                            withAnimation {
                                self.isShowTooltip = true
                                self.isFirstLaunch = false
                            }
                        }
                    }
                })
            }
        }
    }
    
    struct ReviewSheetView: View {
        @ObservedObject var viewModel: ScheduleDetailViewModel
        
        var body: some View {
            var width = CGFloat.zero
            var height = CGFloat.zero
            
            return VStack {
                HStack {
                    Text(LocalizableText.giveReviewLabel)
                        .font(.robotoBold(size: 14))
                        .foregroundColor(.DinotisDefault.black1)
                    
                    Spacer()
                    
                    Button {
                        viewModel.showReviewSheet = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                            .foregroundColor(Color(UIColor.systemGray4))
                    }
                }
                
                ScrollView(showsIndicators: false) {
                    
                    if viewModel.isLoadingReview {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        HStack(spacing: 14) {
                            DinotisImageLoader(urlString: (viewModel.dataBooking?.meeting?.user?.profilePhoto).orEmpty())
                                .frame(width: 56, height: 56)
                                .cornerRadius(8)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text((viewModel.dataBooking?.meeting?.user?.name).orEmpty())
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.DinotisDefault.black3)
                                    .lineLimit(1)
                                
                                Text((viewModel.dataBooking?.meeting?.title).orEmpty())
                                    .font(.robotoBold(size: 14))
                                    .foregroundColor(.DinotisDefault.black2)
                                    .lineLimit(2)
                            }
                            
                            Spacer()
                        }
                        .padding(.bottom)
                        
                        HStack(spacing: 32) {
                            ForEach(1...5, id: \.self) { index in
                                Button {
                                    withAnimation {
                                        viewModel.reviewRating = index
                                    }
                                } label: {
                                    Image(systemName: "star.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40)
                                        .foregroundColor(viewModel.reviewRating >= index ? .DinotisDefault.orange : Color(UIColor.systemGray3))
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(LocalizableText.tippingGiftTitle)
                                    .font(.robotoBold(size: 16))
                                    .foregroundColor(.black)
                                
                                HStack(spacing: 6) {
                                    Text(LocalizableText.tippingYourBalance)
                                        .font(.robotoRegular(size: 14))
                                        .foregroundColor(.DinotisDefault.black3)
                                    
                                    Text((viewModel.user?.coinBalance?.current).orEmpty().toDecimal())
                                        .font(.robotoMedium(size: 14))
                                        .foregroundColor(.DinotisDefault.black1)
                                    
                                    Button {
                                        viewModel.showReviewSheet = false
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                            viewModel.showAddCoin = true
                                        }
                                    } label: {
                                        Text("\(Image(systemName: "plus")) \(LocalizableText.tippingTopUpNow)")
                                            .font(.robotoBold(size: 12))
                                            .foregroundColor(.DinotisDefault.primary)
                                            .padding(.vertical, 6)
                                            .padding(.horizontal, 12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(Color.DinotisDefault.primary.opacity(0.3))
                                            )
                                    }
                                    
                                    Spacer()
                                }
                            }
                            
                            Text(LocalizableText.tippingNotEnoughBalance)
                                .multilineTextAlignment(.leading)
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.DinotisDefault.black1)
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .foregroundColor(.DinotisDefault.red.opacity(0.1))
                                )
                                .isHidden(!viewModel.showNotEnoughBalance(), remove: !viewModel.showNotEnoughBalance())
                            
                            HStack(spacing: 8) {
                                GeometryReader { geo in
                                    ZStack(alignment: .topLeading, content: {
                                        ForEach(viewModel.tips, id: \.self) { data in
                                            Button {
                                                viewModel.selectTipAmount(data: data)
                                            } label: {
                                                Text(data.toDecimal())
                                                    .font(.robotoBold(size: 12))
                                                    .foregroundColor(
                                                        viewModel.tipAmount == data ?
                                                            .DinotisDefault.white : .DinotisDefault.black1
                                                    )
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 6)
                                                    .background(
                                                        viewModel.tipAmount == data ?
                                                        Color.DinotisDefault.primary : Color.DinotisDefault.smokeWhite
                                                    )
                                                    .cornerRadius(5)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 5)
                                                            .inset(by: -0.5)
                                                            .stroke(viewModel.tipAmount == data ? Color.DinotisDefault.primary : Color.DinotisDefault.black3, lineWidth: 1)
                                                    )
                                                    .padding(4)
                                                    .alignmentGuide(.leading) { dimension in
                                                        if (abs(width - dimension.width) > geo.size.width) {
                                                            width = 0
                                                            height -= dimension.height
                                                        }
                                                        let result = width
                                                        if data == viewModel.tips.last {
                                                            width = 0
                                                        } else {
                                                            width -= dimension.width
                                                        }
                                                        return result
                                                    }
                                                    .alignmentGuide(.top) { dimension in
                                                        let result = height
                                                        if data == viewModel.tips.last {
                                                            height = 0
                                                        }
                                                        return result
                                                    }
                                            }
                                        }
                                    })
                                }
                                .frame(height: 60)
                            }
                        }
                        .padding(.vertical)
                        .isHidden(viewModel.tips.isEmpty, remove: viewModel.tips.isEmpty)
                        
                        Divider()
                            .isHidden(viewModel.tips.isEmpty, remove: viewModel.tips.isEmpty)
                        
                        DinotisTextEditor(
                            LocalizableText.yourCommentPlaceholder,
                            label: LocalizableText.yourCommentTitle,
                            text: $viewModel.reviewMessage,
                            errorText: .constant(nil)
                        )
                        .padding(.top)
                    }
                    
                }
                
                DinotisPrimaryButton(
                    text: LocalizableText.sendReviewLabel,
                    type: .adaptiveScreen,
                    textColor: viewModel.disableReviewButton() ? .DinotisDefault.black3 : .white,
                    bgColor: viewModel.disableReviewButton() ? .DinotisDefault.lightPrimary : .DinotisDefault.primary) {
                        Task {
                            await viewModel.giveReview()
                        }
                    }
                    .disabled(viewModel.disableReviewButton())
            }
            .padding()
            .onDisappear {
                viewModel.reviewRating = 0
                viewModel.reviewMessage = ""
                viewModel.tipAmount = nil
            }
        }
    }
    
    struct BottomView: View {
        
        @ObservedObject var viewModel: ScheduleDetailViewModel
        
        @Environment(\.dismiss) var dismiss
        
        var body: some View {
            
            if !(viewModel.dataBooking?.meeting?.meetingRequest?.isAccepted ?? false) && viewModel.dataBooking?.meeting?.meetingRequest != nil  {
                HStack {
                    DinotisPrimaryButton(
                        text: LocalizableText.startNowLabel,
                        type: .adaptiveScreen,
                        textColor: .DinotisDefault.lightPrimaryActive,
                        bgColor: .DinotisDefault.lightPrimary
                    ) {}
                }
                .padding()
                .background(Color.white.edgesIgnoringSafeArea(.all))
            } else {
                if viewModel.dataBooking?.meeting?.endedAt == nil {
                    HStack {
                        DinotisPrimaryButton(
                            text: LocalizableText.startNowLabel,
                            type: .adaptiveScreen,
                            textColor: viewModel.disableStartButton() ? .DinotisDefault.lightPrimaryActive : .white,
                            bgColor: viewModel.disableStartButton() ? .DinotisDefault.lightPrimary : .DinotisDefault.primary
                        ) {
                            viewModel.startPresented.toggle()
                        }
                        .disabled(viewModel.disableStartButton())
                    }
                    .padding()
                    .background(Color.white.edgesIgnoringSafeArea(.all))
                } else if (viewModel.dataBooking?.meeting?.status).orEmpty().contains(SessionStatus.notReviewed.rawValue) {
                    HStack {
                        DinotisPrimaryButton(
                            text: LocalizableText.giveReviewLabel,
                            type: .adaptiveScreen,
                            textColor: .white,
                            bgColor: .DinotisDefault.primary
                        ) {
                            viewModel.showReviewSheet.toggle()
                        }
                    }
                    .padding()
                    .background(Color.white.edgesIgnoringSafeArea(.all))
                }
            }
        }
    }
    
    struct CollaboratorView: View {
        @ObservedObject var viewModel: ScheduleDetailViewModel
        
        var body: some View {
            VStack {
                if !(viewModel.dataBooking?.meeting?.meetingCollaborations ?? []).isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(LocalizableText.collaboratorSpeakerTitle)
                            .font(.robotoRegular(size: 12))
                            .foregroundColor(.black)
                        
                        ForEach((viewModel.dataBooking?.meeting?.meetingCollaborations ?? []).prefix(3), id: \.id) { item in
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
                                viewModel.routeToTalentProfile(username: item.username)
                            }
                        }
                        
                        if (viewModel.dataBooking?.meeting?.meetingCollaborations ?? []).count > 3 {
                            Button {
                                viewModel.isShowCollabList.toggle()
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
    }
    
    struct ParticipantView: View {
        @ObservedObject var viewModel: ScheduleDetailViewModel
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                
                Text(((viewModel.dataBooking?.meeting?.slots).orZero() > 1) ? LocalizableText.groupSessionParticipantTitle : LocalizableText.privateSessionParticipantTitle)
                    .font(.robotoRegular(size: 12))
                    .foregroundColor(.black)
                
                ForEach(viewModel.participantDetail.reversed().prefix(4), id: \.id) { item in
                    VStack {
                        HStack {
                            DinotisImageLoader(urlString: item.profilePhoto.orEmpty())
                                .scaledToFill()
                                .frame(width: 48, height: 48)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            Text((item.name).orEmpty())
                                .font(.robotoBold(size: 14))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            if let first = viewModel.user?.id, let user = item.id {
                                if user == first {
                                    Text(LocalizableText.meLabel)
                                        .font(.robotoRegular(size: 12))
                                        .foregroundColor(.DinotisDefault.primary)
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
                        }
                    }
                }
                
                if viewModel.participantDetail.reversed().count > 4 {
                    Text(LocalizableText.andMoreParticipant(viewModel.participantDetail.reversed().count-4))
                        .font(.robotoBold(size: 12))
                        .foregroundColor(.black)
                }
            }
        }
    }
    
    struct AttachmentBottomSheet: View {
        
        @ObservedObject var viewModel: ScheduleDetailViewModel
        
        var body: some View {
            VStack(spacing: 18) {
                HStack {
                    Text(LocalizableText.attachmentsText)
                        .font(.robotoBold(size: 14))
                        .foregroundColor(.DinotisDefault.black1)
                    
                    Spacer()
                    
                    Button {
                        viewModel.isShowAttachments = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                            .foregroundColor(Color(UIColor.systemGray4))
                    }
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        if let data = viewModel.dataBooking?.meeting?.meetingUrls {
                            ForEach(data, id: \.id) { item in
                                Button {
                                    viewModel.isShowAttachments = false
                                    viewModel.attachmentURL = item.url.orEmpty()
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                                        viewModel.isShowWebView = true
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image.icGlobeSessionDetail
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 24)
                                        
                                        Text(item.title.orEmpty())
                                            .font(.robotoMedium(size: 12))
                                            .foregroundColor(.DinotisDefault.primary)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(1)
                                        
                                        Spacer()
                                        
                                        Image.sessionDetailChevronIcon
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 32, height: 32)
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .foregroundColor(.DinotisDefault.lightPrimary)
                                    )
                                }
                            }
                        }
                    }
                }
            }
            .padding([.top, .horizontal])
        }
    }
    
    struct EmptyURLView: View {
        
        @ObservedObject var viewModel: ScheduleDetailViewModel
        
        var body: some View {
            VStack {
                Spacer()
                
                Image.searchNotFoundImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 315)
                
                Text(LocalizableText.emptyFileMessage)
                    .font(.robotoBold(size: 20))
                    .foregroundColor(.DinotisDefault.black1)
                    .multilineTextAlignment(.center)
                    .padding(12)
                
                Spacer()
                
                DinotisPrimaryButton(
                    text: LocalizableText.okText,
                    type: .adaptiveScreen,
                    textColor: .white,
                    bgColor: .DinotisDefault.primary) {
                        viewModel.isShowWebView = false
                    }
            }
            .padding()
        }
    }
    
    struct AddCoinBottomSheet: View {
        
        @ObservedObject var viewModel: ScheduleDetailViewModel
        
        var body: some View {
            VStack {
                HStack {
                    Spacer()

                    Button {
                        viewModel.showAddCoin.toggle()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                            .foregroundColor(Color(UIColor.systemGray4))
                    }
                }
                
                VStack(spacing: 20) {
                    VStack {
                        Text(LocalizableText.tippingYourCurrentCoin)
                            .font(.robotoBold(size: 14))
                            .foregroundColor(.DinotisDefault.primary)
                        
                        HStack(alignment: .top) {
                            Image.sessionCardCoinYellowPurpleIcon
                                .resizable()
                                .scaledToFit()
                                .frame(height: 20)
                            
                            Text((viewModel.user?.coinBalance?.current).orEmpty().toDecimal())
                                .font(.robotoBold(size: 24))
                                .foregroundColor(.DinotisDefault.primary)
                        }
                        .multilineTextAlignment(.center)
                        
                        Text(LocalizableText.descriptionAddCoin)
                            .font(.robotoRegular(size: 12))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                    }
                    
                    Group {
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
            }
            .padding()
            .dynamicTypeSize(.large)
            .onDisappear {
                viewModel.onDisappear()
                viewModel.productSelected = nil
            }
        }
    }
    
    struct ReviewSuccessPopUp: View {
        
        @ObservedObject var viewModel: ScheduleDetailViewModel
        
        var body: some View {
            ZStack {
                Color.black.opacity(0.3).ignoresSafeArea()
                
                VStack(spacing: 10) {
                    Image.feedbackSuccessImage
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                    
                    VStack(spacing: 18) {
                        VStack(spacing: 8) {
                            HStack {
                                ForEach(1...5, id: \.self) { index in
                                    (index <= viewModel.reviewStars() ?
                                     Image.feedbackStarYellow : Image.feedbackStarGray
                                    )
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 36)
                                }
                            }
                            
                            if let tipAmount = viewModel.successTipAmount {
                                Text("+ \(tipAmount.toDecimal()) \(LocalizableText.giftLabel)")
                                    .font(.robotoBold(size: 12))
                                    .foregroundColor(.DinotisDefault.green)
                                    .multilineTextAlignment(.center)
                            }
                            
                            Text(viewModel.successTipAmount != nil ?
                                 LocalizableText.reviewSuccessWithTipDesc : LocalizableText.tippingSuccessDesc
                            )
                            .font(.robotoRegular(size: 12))
                            .foregroundColor(.DinotisDefault.black3)
                            .multilineTextAlignment(.center)
                        }
                        
                        DinotisPrimaryButton(
                            text: LocalizableText.closeLabel,
                            type: .adaptiveScreen,
                            textColor: .white,
                            bgColor: .DinotisDefault.primary) {
                                withAnimation {
                                    viewModel.isReviewSuccess = false
                                    viewModel.successTipAmount = nil
                                }
                            }
                    }
                }
                .padding(20)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(.white)
                )
                .scaleEffect(viewModel.isReviewSuccess ? 1 : 0)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: viewModel.isReviewSuccess)
                .padding()
            }
        }
    }
}
