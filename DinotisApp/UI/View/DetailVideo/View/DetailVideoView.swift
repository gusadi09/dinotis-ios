//
//  DetailVideoView.swift
//  DinotisApp
//
//  Created by Irham Naufal on 01/11/23.
//

import DinotisDesignSystem
import SwiftUI

struct DetailVideoView: View {
    
    @EnvironmentObject var viewModel: DetailVideoViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HeaderView(
                    type: .textHeader,
                    title: (viewModel.videoData?.video?.user?.username).orEmpty(),
                    headerColor: .clear,
                    textColor: .DinotisDefault.black1,
                    leadingButton:  {
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
                    }) {
                        if let url = viewModel.videoData?.video?.shareUrl {
                            Button {
                                viewModel.shareSheet(url: url)
                            } label: {
                                Image.talentProfileShareIcon
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
                        }
                    }
                    .transition(.move(edge: .top))
                
                if viewModel.isLoading {
                    
                    Spacer()
                    
                    DinotisLoadingView(.small, hide: !viewModel.isLoading)
                    
                    Spacer()
                } else {
                    LazyVStack {
                        if let url = URL(string: viewModel.videoUrl.orEmpty()) {
                            DinotisVideoPlayer(url: url, isAutoPlay: true)
                                .frame(width: geometry.size.width, height: geometry.size.width * 9 / 16)
                        } else {
                            Rectangle()
                                .foregroundStyle(Color.black)
                                .frame(width: geometry.size.width, height: geometry.size.width * 9 / 16)
                                .overlay(
                                    LottieView(name: "regular-loading", loopMode: .loop)
                                        .scaledToFit()
                                        .frame(height: 50)
                                )
                            
                        }
                    }
                    
                    List {
                        Group {
                            VideoDataView()
                                .buttonStyle(.plain)
                            
                            CommentCardView()
                                .buttonStyle(.plain)
                            
                            if viewModel.state.userType != 2 {
                                Button {
                                    
                                } label: {
                                    HStack(spacing: 12) {
                                        Text(LocalizableText.detailVideoUpcomingSessionDesc)
                                            .foregroundColor(.DinotisDefault.black1)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.DinotisDefault.black2)
                                    }
                                    .font(.robotoBold(size: 16))
                                }
                                .buttonStyle(.plain)
                                .padding(.top)
                            }
                        }
                        .buttonStyle(.plain)
                        .padding([.horizontal, .top])
                        .listRowSeparator(.hidden)
                        .listSectionSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 18))
                        
                        if viewModel.state.userType != 2 {
                            Section {
                                SessionListView()
                            } header: {
                                ListHeaderView()
                            }
                            .padding([.horizontal, .bottom])
                            .listRowSeparator(.hidden)
                            .listSectionSeparator(.hidden)
                            .listRowBackground(Color.DinotisDefault.baseBackground)
                            .listRowInsets(EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 18))
                            .background(Color.DinotisDefault.baseBackground)
                        }
                    }
                    .padding(.horizontal, -18)
                    .listStyle(.plain)
                    .refreshable {
                        
                    }
                }
            }
            .sheet(isPresented: $viewModel.isShowBottomSheet, content: {
                if #available(iOS 16.0, *) {
                    CommentBottomSheet()
                        .presentationDetents([.height(geometry.size.height - (geometry.size.width * 9 / 16) - 76), .fraction(0.99)])
                        .presentationDragIndicator(.hidden)
                } else {
                    CommentBottomSheet()
                }
            })
        }
        .background(Color.DinotisDefault.baseBackground)
        .navigationBarTitle(Text(""))
        .navigationBarHidden(true)
        .onAppear {
            viewModel.onGetDetail()
            viewModel.onGetUser()
            viewModel.onAppearGetComments()
        }
    }
}

extension DetailVideoView {
    @ViewBuilder
    func VideoDataView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text((viewModel.videoData?.video?.title).orEmpty())
                    .font(.robotoBold(size: 18))
                    .foregroundColor(.DinotisDefault.black1)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text(viewModel.dateFormatter((viewModel.videoData?.video?.createdAt).orCurrentDate()))
                    
                    Circle()
                        .frame(width: 4, height: 4)
                    
                    Text((viewModel.videoData?.video?.videoType?.rawValue).orEmpty().capitalized)
                    
                    Circle()
                        .frame(width: 4, height: 4)
                    
                    Text(viewModel.videoData?.video?.audienceType == .PUBLIC ? LocalizableText.publicLabel : LocalizableText.recordedLabel)
                }
                .font(.robotoRegular(size: 12))
                .foregroundColor(.DinotisDefault.black3)
            }
            
            HStack(spacing: 12) {
                DinotisImageLoader(urlString: (viewModel.videoData?.video?.user?.profilePhoto).orEmpty())
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 3) {
                        Text((viewModel.videoData?.video?.user?.name).orEmpty())
                            .font(.robotoBold(size: 14))
                            .foregroundColor(.DinotisDefault.black2)
                            .multilineTextAlignment(.leading)
                            .lineLimit(1)
                        
                        if let verif = viewModel.videoData?.video?.user?.isVerified, verif {
                            Image.sessionCardVerifiedIcon
                        }
                    }
                    
                    Text(viewModel.professionText.orEmpty())
                        .font(.robotoRegular(size: 12))
                        .foregroundColor(.DinotisDefault.black3)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if viewModel.state.userType != 2 {
                    Button {
                        
                    } label: {
                        HStack(spacing: 4) {
                            Image.talentProfileSubsStarWhiteIcon
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                            
                            Text(LocalizableText.subscribeLabel)
                                .font(.robotoMedium(size: 14))
                                .foregroundColor(.white)
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundColor(.DinotisDefault.primary)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            if viewModel.videoData?.video?.videoType == .RECORD {
                HStack(spacing: 8) {
                    HStack(spacing: -10) {
                        ForEach((viewModel.videoData?.meeting?.participantDetails ?? []).prefix(3), id: \.id) { item in
                            
                            DinotisImageLoader(urlString: item.profilePhoto.orEmpty())
                                .frame(width: 25, height: 25)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 1)
                                        .frame(width: 25, height: 25)
                                )
                        }
                        
                        if (viewModel.videoData?.meeting?.participantDetails ?? []).count > 3 {
                            HStack(spacing: 2) {
                                Circle()
                                    .scaledToFit()
                                    .frame(height: 3)
                                    .foregroundColor(.white)
                                
                                Circle()
                                    .scaledToFit()
                                    .frame(height: 3)
                                    .foregroundColor(.white)
                                
                                Circle()
                                    .scaledToFit()
                                    .frame(height: 3)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 25, height: 25)
                            .background(
                                Circle()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(Color(hex: "#CD2DAD")?.opacity(0.75))
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 1)
                                            .frame(width: 25, height: 25)
                                    )
                            )
                        }
                    }
                    
                    Text(LocalizableText.groupSessionLabelWithEmoji)
                        .font(.robotoMedium(size: 10))
                        .foregroundColor(.DinotisDefault.primary)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                        .overlay(
                            Capsule()
                                .stroke(Color.DinotisDefault.primary, lineWidth: 1)
                        )
                }
            }
            
            VStack(alignment: .leading) {
                Text((viewModel.videoData?.video?.description).orEmpty())
                    .font(.robotoRegular(size: 14))
                    .foregroundColor(.DinotisDefault.black1)
                    .multilineTextAlignment(.leading)
                    .lineLimit(viewModel.isShowFullText ? nil : 3)
                
                Button {
                    withAnimation {
                        viewModel.isShowFullText.toggle()
                    }
                } label: {
                    Text(viewModel.isShowFullText ? LocalizableText.bookingRateCardHideFullText : LocalizableText.bookingRateCardShowFullText)
                        .font(.robotoMedium(size: 14))
                        .foregroundColor(.DinotisDefault.primary)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    func CommentCardView() -> some View {
        Button {
            viewModel.isShowBottomSheet = true
        } label: {
            VStack(spacing: 16) {
                HStack {
                    Text(LocalizableText.commentLabel)
                        .foregroundColor(.DinotisDefault.black1)
                    
                    Spacer()
                    
                    if (viewModel.videoData?.totalComment).orZero() > 0 {
                        Text("\(LocalizableText.searchSeeAllLabel)(\((viewModel.videoData?.totalComment).orZero()))")
                            .foregroundColor(.DinotisDefault.primary)
                    }
                }
                .font(.robotoBold(size: 14))
                
                if (viewModel.videoData?.totalComment).orZero() > 0 {
                    HStack(alignment: .top, spacing: 16) {
                        
                        DinotisImageLoader(urlString: (viewModel.videoData?.comment?.user?.profilePhoto).orEmpty())
                            .scaledToFill()
                            .frame(width: 48, height: 48)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 3) {
                                Text((viewModel.videoData?.comment?.user?.name).orEmpty())
                                    .lineLimit(1)
                                
                                if let verif = viewModel.videoData?.comment?.user?.isVerified, verif {
                                    Image.sessionCardVerifiedIcon
                                }
                                
                                Spacer()
                                
                                Text(viewModel.dateFormatter((viewModel.videoData?.comment?.createdAt).orCurrentDate()))
                            }
                            .font(.robotoMedium(size: 12))
                            .foregroundColor(.DinotisDefault.black3)
                            
                            Text((viewModel.videoData?.comment?.comment).orEmpty())
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.DinotisDefault.black1)
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                        }
                    }
                } else {
                    HStack(spacing: 8) {
                        DinotisImageLoader(urlString: (viewModel.userData?.profilePhoto).orEmpty())
                            .scaledToFill()
                            .frame(width: 36, height: 36)
                            .clipShape(Circle())
                        
                        HStack {
                            Text(LocalizableText.detailVideoCommentPlaceholder)
                                .font(.robotoRegular(size: 12))
                                .foregroundStyle(Color(red: 0.89, green: 0.77, blue: 1))
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                        }
                        .frame(height: 26)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 16)
                        .background(
                            Capsule()
                                .foregroundStyle(Color(red: 0.96, green: 0.93, blue: 1))
                        )
                    }
                }
            }
            .padding(16)
            .background(.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .inset(by: 0.5)
                    .stroke(Color.DinotisDefault.black3.opacity(0.4), lineWidth: 1)
                
            )
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    func ListHeaderView() -> some View {
        HStack(spacing: 8) {
            ForEach(1...2, id: \.self) { index in
                Button {
                    withAnimation {
                        viewModel.currentSection = index
                    }
                } label: {
                    Text(viewModel.sectionText(index))
                        .font(viewModel.currentSection == index ? .robotoBold(size: 14) : .robotoRegular(size: 14))
                        .foregroundColor(viewModel.currentSection == index ? .DinotisDefault.primary : .DinotisDefault.black2)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(viewModel.currentSection == index ? Color.DinotisDefault.lightPrimary : .clear)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .inset(by: 0.5)
                                .stroke(viewModel.currentSection == index ? Color.DinotisDefault.primary : .DinotisDefault.lightPrimary, lineWidth: 1)
                            
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top)
    }
    
    @ViewBuilder
    func SessionListView() -> some View {
        LazyVStack(spacing: 12) {
            switch viewModel.currentSection {
            case 2:
                ForEach(viewModel.meetingData.filter({ $0.isPrivate.orFalse() }), id: \.id) { item in
                    SessionCard(with: .init(
                        title: item.title.orEmpty(),
                        date: DateUtils.dateFormatter((item.startAt).orCurrentDate(), forFormat: .EEEEddMMMMyyyy),
                        startAt: DateUtils.dateFormatter((item.startAt).orCurrentDate(), forFormat: .HHmm),
                        endAt: DateUtils.dateFormatter((item.endAt).orCurrentDate(), forFormat: .HHmm),
                        isPrivate: item.isPrivate.orFalse(),
                        isVerified: (item.user?.isVerified).orFalse(),
                        photo: (item.user?.profilePhoto).orEmpty(),
                        name: (item.user?.name).orEmpty(),
                        color: item.background,
                        participantsImgUrl: item.participantDetails?.compactMap({
                            $0.profilePhoto.orEmpty()
                        }) ?? [],
                        isActive: item.endAt.orCurrentDate() > Date(),
                        type: .session,
                        collaborationCount: (item.meetingCollaborations ?? []).count,
                        collaborationName: (item.meetingCollaborations ?? []).compactMap({
                            ($0.user?.name).orEmpty()
                        }).joined(separator: ", "),
                        isAlreadyBooked: false
                    )) {
                        
                    } visitProfile: {
                        
                    }
                }
                
            default:
                ForEach(viewModel.meetingData.filter({ !$0.isPrivate.orFalse() }), id: \.id) { item in
                    SessionCard(with: .init(
                        title: item.title.orEmpty(),
                        date: DateUtils.dateFormatter((item.startAt).orCurrentDate(), forFormat: .EEEEddMMMMyyyy),
                        startAt: DateUtils.dateFormatter((item.startAt).orCurrentDate(), forFormat: .HHmm),
                        endAt: DateUtils.dateFormatter((item.endAt).orCurrentDate(), forFormat: .HHmm),
                        isPrivate: item.isPrivate.orFalse(),
                        isVerified: (item.user?.isVerified).orFalse(),
                        photo: (item.user?.profilePhoto).orEmpty(),
                        name: (item.user?.name).orEmpty(),
                        color: item.background,
                        participantsImgUrl: item.participantDetails?.compactMap({
                            $0.profilePhoto.orEmpty()
                        }) ?? [], 
                        isActive: item.endAt.orCurrentDate() > Date(),
                        type: .session,
                        collaborationCount: (item.meetingCollaborations ?? []).count,
                        collaborationName: (item.meetingCollaborations ?? []).compactMap({
                            ($0.user?.name).orEmpty()
                        }).joined(separator: ", "),
                        isAlreadyBooked: false
                    )) {
                        
                    } visitProfile: {
                        
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func CommentBottomSheet() -> some View {
        VStack(spacing: 0) {
            Capsule()
                .foregroundColor(.clear)
                .frame(width: 119, height: 4)
                .background(Color.DinotisDefault.black3.opacity(0.3))
                .padding()
            
            Text(LocalizableText.commentLabel)
                .font(.robotoBold(size: 16))
                .foregroundColor(.DinotisDefault.black1)
                .padding(.bottom)
            
            if viewModel.isLoadingComment {
                VStack {
                    Spacer()
                    
                    LottieView(name: "regular-loading", loopMode: .loop)
                        .scaledToFit()
                        .frame(height: 40)
                    
                    Spacer()
                }
            } else {
                if viewModel.comments.isEmpty {
                    VStack {
                        Spacer()
                        
                        Text("No comments right now")
                            .font(.robotoRegular(size: 12))
                            .foregroundStyle(Color.DinotisDefault.black3)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.comments, id: \.id) { item in
                                if item.id == viewModel.comments.last?.id {
                                    VStack(spacing: 16) {
                                        HStack(alignment: .top, spacing: 16) {
                                            DinotisImageLoader(urlString: (item.user?.profilePhoto).orEmpty())
                                                .scaledToFill()
                                                .frame(width: 48, height: 48)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                HStack {
                                                    Text((item.user?.name).orEmpty())
                                                        .lineLimit(1)
                                                    
                                                    Spacer()
                                                    
                                                    Text(viewModel.dateFormatter(item.createdAt.orCurrentDate()))
                                                }
                                                .font(.robotoMedium(size: 12))
                                                .foregroundColor(.DinotisDefault.black3)
                                                
                                                Text(item.comment.orEmpty())
                                                    .font(.robotoRegular(size: 12))
                                                    .foregroundColor(.DinotisDefault.black1)
                                                    .multilineTextAlignment(.leading)
                                            }
                                        }
                                        
                                        Divider()
                                        
                                        if viewModel.isLoadingMoreComment {
                                            HStack {
                                                Spacer()
                                                
                                                LottieView(name: "regular-loading", loopMode: .loop)
                                                    .scaledToFit()
                                                    .frame(maxHeight: 30)
                                                
                                                Spacer()
                                            }
                                        }
                                    }
                                    .onAppear {
                                        if item.id == viewModel.comments.last?.id && viewModel.nextCursor != nil {
                                            Task {
                                                viewModel.skipComment = viewModel.takeComment
                                                viewModel.takeComment += 10
                                                    
                                                await viewModel.getComments(isMore: true)
                                            }
                                        }
                                    }
                                } else {
                                    VStack(spacing: 16) {
                                        HStack(alignment: .top, spacing: 16) {
                                            DinotisImageLoader(urlString: (item.user?.profilePhoto).orEmpty())
                                                .scaledToFill()
                                                .frame(width: 48, height: 48)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                HStack(spacing: 3) {
                                                    Text((item.user?.name).orEmpty())
                                                        .lineLimit(1)
                                                    
                                                    if let verif = item.user?.isVerified, verif {
                                                        Image.sessionCardVerifiedIcon
                                                    }
                                                    
                                                    Spacer()
                                                    
                                                    Text(viewModel.dateFormatter(item.createdAt.orCurrentDate()))
                                                }
                                                .font(.robotoMedium(size: 12))
                                                .foregroundColor(.DinotisDefault.black3)
                                                
                                                Text(item.comment.orEmpty())
                                                    .font(.robotoRegular(size: 12))
                                                    .foregroundColor(.DinotisDefault.black1)
                                                    .multilineTextAlignment(.leading)
                                            }
                                        }
                                        
                                        Divider()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            HStack(alignment: .bottom, spacing: 8) {
                MultilineTextField(LocalizableText.yourCommentPlaceholder, text: $viewModel.commentText)
                    .tint(.DinotisDefault.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 7)
                    .background(Color.DinotisDefault.lightPrimary)
                    .cornerRadius(24)
                
                Button {
                    Task {
                        await viewModel.postComments()
                    }
                } label: {
                    Group {
                        if viewModel.isLoadingSend {
                            LottieView(name: "regular-loading", loopMode: .loop)
                                .scaledToFit()
                                .frame(maxHeight: 40)
                                .clipShape(.circle)
                        } else {
                            Image.messageSendIcon
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 32, maxHeight: 32)
                                .padding(10)
                                .background(Color.DinotisDefault.primary)
                                .frame(width: 40, height: 40)
                                .clipShape(.circle)
                                .opacity(viewModel.disableSendButton() ? 0.7 : 1)
                        }
                    }
                }
                .disabled(viewModel.disableSendButton())
            }
            .zIndex(100)
            .padding()
            .background(
                Color.white.ignoresSafeArea()
                    .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
            )
        }
    }
}

#Preview {
    DetailVideoView()
        .environmentObject(DetailVideoViewModel(videoId: "", backToHome: {}))
}
