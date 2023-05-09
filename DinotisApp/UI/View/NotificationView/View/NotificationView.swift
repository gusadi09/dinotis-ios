//
//  NotificationView.swift
//  DinotisApp
//
//  Created by Gus Adi on 04/08/21.
//

import SwiftUI
import DinotisDesignSystem

struct NotificationView: View {
    
    @ObservedObject var viewModel: NotificationViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            
            Color.DinotisDefault.baseBackground
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                HeaderView(
                    type: .textHeader,
                    title: LocalizableText.notificationTitle,
                    headerColor: .white,
                    leadingButton: {
                        DinotisElipsisButton(
                            icon: .generalBackIcon,
                            iconColor: .DinotisDefault.black1,
                            bgColor: .DinotisDefault.white,
                            strokeColor: nil,
                            iconSize: 12,
                            type: .primary, {
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        )
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 0)
                    },
                    trailingButton: {
                        DinotisNudeButton(text: LocalizableText.notificationReadAll, textColor: .DinotisDefault.primaryActive, fontSize: 14) {
                            Task {
                                await viewModel.readAll()
                            }
                        }
                    }
                )
                .onChange(of: viewModel.type) { newValue in
                    Task {
                        viewModel.query.type = newValue
                        viewModel.query.skip = 0
                        viewModel.query.take = 15
                        
                        await viewModel.getNotifications(isReplacing: true)
                    }
                }
                .onChange(of: Locale.current.languageCode) { newValue in
                    Task {
                        viewModel.query.lang = newValue.orEmpty()
                        viewModel.query.skip = 0
                        viewModel.query.take = 15
                        
                        await viewModel.getNotifications(isReplacing: true)
                    }
                }
                
                if viewModel.stateObservable.userType == 3 {
                    HStack {
                        Button {
                            withAnimation {
                                viewModel.type = "general"
                            }
                            
                        } label: {
                            VStack(spacing: 0) {
                                HStack {
                                    Spacer()
                                    
                                    Text(LocalizableText.notificationGeneralTabText)
                                        .font(viewModel.type == "general" ? .robotoMedium(size: 14) : .robotoRegular(size: 14))
                                        .foregroundColor(.black)
                                        .padding(.bottom, 15)
                                    
                                    Spacer()
                                }
                                
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(viewModel.type == "general" ? .DinotisDefault.primary : .white)
                            }
                        }
                        
                        Button {
                            withAnimation {
                                viewModel.type = "transaction"
                            }
                            
                        } label: {
                            VStack(spacing: 0) {
                                HStack {
                                    Spacer()
                                    
                                    Text(LocalizableText.notificationTransactionTabText)
                                        .font(viewModel.type == "transaction" ? .robotoMedium(size: 14) : .robotoRegular(size: 14))
                                        .foregroundColor(.black)
                                        .padding(.bottom, 15)
                                    
                                    Spacer()
                                }
                                
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(viewModel.type == "transaction" ? .DinotisDefault.primary : .white)
                            }
                        }
                    }
                    .background(
                        Color.white
                    )
                }
                
                TabView(selection: $viewModel.type) {
                    RefreshableScrollViews {
                        Task {
                            viewModel.query.take = 15
                            viewModel.query.skip = 0
                            await viewModel.getNotifications(isReplacing: true)
                        }
                    } content: {
                        HStack {
                            Spacer()
                            
                            ProgressView()
                                .progressViewStyle(.circular)
                                .padding(.vertical, 10)
                            
                            Spacer()
                        }
                        .isHidden(!viewModel.isLoading, remove: !viewModel.isLoading)
                        
                        LazyVStack(spacing: 0) {
                            
                            if viewModel.resultGeneral.isEmpty {
                                VStack(spacing: 15) {
                                    Image.notificationEmptyImage
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 182)
                                    
                                    Text(LocalizableText.notificationEmptyTitle)
                                        .font(.robotoBold(size: 14))
                                        .foregroundColor(.black)
                                    
                                    Text(LocalizableText.notificationEmptyDescription)
                                        .font(.robotoRegular(size: 12))
                                        .foregroundColor(.black)
                                }
                                .multilineTextAlignment(.center)
                                .padding()
                            } else {
                                ForEach(viewModel.resultGeneral, id: \.?.id) { item in
                                    VStack(spacing: 0) {
                                        NotificationCard(
                                            data: viewModel.convertToNotificationModel(raw: item),
                                            action: {
                                                viewModel.isShowCollabSheet.toggle()
                                                viewModel.getDetailCollab(for: (item?.meetingId).orEmpty())
                                            }
                                        )
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            Task {
                                                await viewModel.readById(id: item?.id)
                                            }
                                        }
                                        
                                        Divider()
                                            .padding(.horizontal)
                                    }
                                    .onAppear {
                                        Task {
                                            if item?.id == viewModel.resultGeneral.last??.id {
                                                if viewModel.nextCursor != nil {
                                                    viewModel.query.skip = viewModel.query.take
                                                    viewModel.query.take += 15
                                                    
                                                    await viewModel.getNotifications(isReplacing: false)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .tag("general")
                    
                    RefreshableScrollViews {
                        Task {
                            viewModel.query.take = 15
                            viewModel.query.skip = 0
                            await viewModel.getNotifications(isReplacing: true)
                        }
                    } content: {
                        HStack {
                            Spacer()
                            
                            ProgressView()
                                .progressViewStyle(.circular)
                                .padding(.vertical, 10)
                            
                            Spacer()
                        }
                        .isHidden(!viewModel.isLoading, remove: !viewModel.isLoading)
                        
                        LazyVStack(spacing: 0) {
                            
                            if viewModel.resultTrans.isEmpty {
                                VStack(spacing: 15) {
                                    Image.notificationEmptyImage
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 182)
                                    
                                    Text(LocalizableText.notificationTransactionEmptyTitle)
                                        .font(.robotoBold(size: 14))
                                        .foregroundColor(.black)
                                    
                                    Text(LocalizableText.notificationTransactionEmptyDescription)
                                        .font(.robotoRegular(size: 12))
                                        .foregroundColor(.black)
                                }
                                .multilineTextAlignment(.center)
                                .padding()
                            } else {
                                ForEach(viewModel.resultTrans, id: \.?.id) { item in
                                    VStack(spacing: 0) {
                                        NotificationCard(
                                            data: viewModel.convertToNotificationModel(raw: item),
                                            action: {}
                                        )
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            Task {
                                                await viewModel.readById(id: item?.id)
                                            }
                                        }
                                        
                                        
                                        Divider()
                                            .padding(.horizontal)
                                    }
                                    .onAppear {
                                        Task {
                                            if item?.id == viewModel.resultTrans.last??.id {
                                                if viewModel.nextCursor != nil {
                                                    viewModel.query.skip = viewModel.query.take
                                                    viewModel.query.take += 15
                                                    
                                                    await viewModel.getNotifications(isReplacing: false)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .tag("transaction")
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            
            DinotisLoadingView(.small, hide: !viewModel.isReadLoading)
        }
        .navigationBarTitle(Text(""))
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await viewModel.getNotifications(isReplacing: true)
            }
        }
        .sheet(isPresented: $viewModel.isShowCollabSheet, content: {
            if #available(iOS 16.0, *) {
                DetailCollaborationSheet(viewModel: viewModel)
                    .padding()
                    .presentationDetents([.medium, .large])
            } else {
                DetailCollaborationSheet(viewModel: viewModel)
                    .padding()
            }
        })
        .dinotisAlert(
            isPresent: $viewModel.isShowAlert,
            title: viewModel.alert.title,
            isError: viewModel.alert.isError,
            message: viewModel.alert.message,
            primaryButton: viewModel.alert.primaryButton,
            secondaryButton: viewModel.alert.secondaryButton
        )
    }
}

private extension NotificationView {
    struct DetailCollaborationSheet: View {
        
        @ObservedObject var viewModel: NotificationViewModel
        
        var body: some View {
            
            if viewModel.isLoadingDetail {
                VStack {
                    Spacer()
                    
                    ProgressView()
                        .progressViewStyle(.circular)
                    
                    Spacer()
                }
            } else {
                VStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(spacing: 12) {
                                HStack(spacing: 16) {
                                    DinotisImageLoader(
                                        urlString: (viewModel.detailMeeting?.user?.profilePhoto).orEmpty(),
                                        width: 40,
                                        height: 40
                                    )
                                    .clipShape(Circle())
                                    
                                    HStack {
                                        Text((viewModel.detailMeeting?.user?.name).orEmpty())
                                            .font(.robotoBold(size: 14))
                                            .foregroundColor(.black)
                                            .multilineTextAlignment(.leading)
                                        
                                        if (viewModel.detailMeeting?.user?.isVerified) ?? false {
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
                                        Text((viewModel.detailMeeting?.title).orEmpty())
                                            .font(.robotoBold(size: 14))
                                            .foregroundColor(.black)
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer()
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Text((viewModel.detailMeeting?.description).orEmpty())
                                            .font(.robotoRegular(size: 12))
                                            .foregroundColor(.black)
                                            .multilineTextAlignment(.leading)
                                    }
                                }
                            }
                            
                            VStack(spacing: 10) {
                                HStack(spacing: 10) {
                                    Image.sessionCardDateIcon
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 17)
                                    
                                    Text((viewModel.detailMeeting?.startAt?.toStringFormat(with: .ddMMMMyyyy)).orEmpty())
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
                                    
                                    Text("\((viewModel.detailMeeting?.startAt?.toStringFormat(with: .HHmm)).orEmpty()) – \((viewModel.detailMeeting?.endAt?.toStringFormat(with: .HHmm)).orEmpty())")
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
                                    
                                    Text("\((viewModel.detailMeeting?.slots).orZero()) \(LocalizableText.participant)")
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
                                
                                if (viewModel.detailMeeting?.price).orEmpty() == "0" {
                                    Text(LocalizableText.freeText)
                                        .font(.robotoBold(size: 16))
                                        .foregroundColor(.black)
                                } else {
                                    Text((viewModel.detailMeeting?.price).orEmpty().toPriceFormat())
                                        .font(.robotoBold(size: 16))
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    
                    if !(viewModel.detailMeeting?.isCollaborationAlreadyConfirmed ?? false) {
                        HStack(spacing: 15) {
                            DinotisSecondaryButton(text: LocalizableText.decline, type: .adaptiveScreen, height: 45, textColor: .black, bgColor: .DinotisDefault.lightPrimary, strokeColor: .DinotisDefault.primary) {
                                viewModel.approveMeeting(false)
                            }
                            
                            DinotisPrimaryButton(text: LocalizableText.acceptInvitation, type: .adaptiveScreen, height: 45, textColor: .white, bgColor: .DinotisDefault.primary) {
                                viewModel.approveMeeting(true)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
		NotificationView(viewModel: NotificationViewModel(backToRoot: {}, backToHome: {}))
    }
}
