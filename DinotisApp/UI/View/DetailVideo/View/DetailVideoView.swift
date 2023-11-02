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
                    title: (viewModel.userData?.username).orEmpty(),
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
                        Button {
                            
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
                    .transition(.move(edge: .top))
                
                DinotisVideoPlayer(url: viewModel.videoData.url!, isAutoPlay: true)
                    .frame(width: geometry.size.width, height: geometry.size.width * 9 / 16)
                
                List {
                    VStack(spacing: 22) {
                        VideoDataView()
                        
                        CommentCardView()
                        
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
                    .padding([.horizontal, .top])
                    .listRowSeparator(.hidden)
                    .listSectionSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 18))
                    
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
                .padding(.horizontal, -18)
                .listStyle(.plain)
                .refreshable {
                    
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.DinotisDefault.baseBackground)
        .navigationBarTitle(Text(""))
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await viewModel.getUsers()
                await viewModel.getTalentMeeting()
            }
        }
    }
}

extension DetailVideoView {
    @ViewBuilder
    func VideoDataView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.videoData.title)
                    .font(.robotoBold(size: 18))
                    .foregroundColor(.DinotisDefault.black1)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text(viewModel.dateFormatter(viewModel.videoData.date))
                    
                    Circle()
                        .frame(width: 4, height: 4)
                    
                    Text(viewModel.videoData.type)
                    
                    Circle()
                        .frame(width: 4, height: 4)
                    
                    Text(LocalizableText.publicLabel)
                }
                .font(.robotoRegular(size: 12))
                .foregroundColor(.DinotisDefault.black3)
            }
            
            HStack(spacing: 12) {
                DinotisImageLoader(urlString: (viewModel.userData?.profilePhoto).orEmpty())
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text((viewModel.userData?.name).orEmpty())
                        .font(.robotoBold(size: 14))
                        .foregroundColor(.DinotisDefault.black2)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    Text(viewModel.professionText.orEmpty())
                        .font(.robotoRegular(size: 12))
                        .foregroundColor(.DinotisDefault.black3)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
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
            
            HStack(spacing: 8) {
                HStack(spacing: -10) {
                    ForEach(viewModel.videoData.comments.prefix(3), id: \.id) { item in
                        
                        DinotisImageLoader(urlString: item.profileImage)
                            .frame(width: 25, height: 25)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 1)
                                    .frame(width: 25, height: 25)
                            )
                    }
                    
                    if viewModel.videoData.comments.count > 3 {
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
            
            VStack(alignment: .leading) {
                Text(viewModel.videoData.description)
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
                    
                    Text("\(LocalizableText.searchSeeAllLabel)(\(viewModel.videoData.commentCount))")
                        .foregroundColor(.DinotisDefault.primary)
                }
                .font(.robotoBold(size: 14))
                
                HStack(alignment: .top, spacing: 16) {
                    DinotisImageLoader(urlString: (viewModel.videoData.comments.last?.profileImage).orEmpty())
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text((viewModel.videoData.comments.last?.name).orEmpty())
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text(viewModel.dateFormatter((viewModel.videoData.comments.last?.date).orCurrentDate()))
                        }
                        .font(.robotoMedium(size: 12))
                        .foregroundColor(.DinotisDefault.black3)
                        
                        Text((viewModel.videoData.comments.last?.comment).orEmpty())
                            .font(.robotoRegular(size: 12))
                            .foregroundColor(.DinotisDefault.black1)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
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
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.videoData.comments.sorted(by: { $0.date > $1.date }), id: \.id) { item in
                        VStack(spacing: 16) {
                            HStack(alignment: .top, spacing: 16) {
                                DinotisImageLoader(urlString: item.profileImage)
                                    .scaledToFill()
                                    .frame(width: 48, height: 48)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(item.name)
                                            .lineLimit(1)
                                        
                                        Spacer()
                                        
                                        Text(viewModel.dateFormatter((item.date)))
                                    }
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.DinotisDefault.black3)
                                    
                                    Text(item.comment)
                                        .font(.robotoRegular(size: 12))
                                        .foregroundColor(.DinotisDefault.black1)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                            
                            Divider()
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            HStack(alignment: .bottom, spacing: 8) {
                MultilineTextField(LocalizableText.yourCommentPlaceholder, text: $viewModel.commentText)
                    .tint(.DinotisDefault.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 7)
                    .background(Color.DinotisDefault.lightPrimary)
                    .cornerRadius(24)
                
                Button {
                    viewModel.addComment()
                } label: {
                    Image.messageSendIcon
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 32, maxHeight: 32)
                        .padding(10)
                        .background(Color.DinotisDefault.primary)
                        .frame(width: 40, height: 40)
                        .clipShape(.circle)
                }
                .disabled(viewModel.disableSendButton())
                .opacity(viewModel.disableSendButton() ? 0.7 : 1)
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
        .environmentObject(DetailVideoViewModel(backToHome: {}))
}
