//
//  PreviewTalentView.swift
//  DinotisApp
//
//  Created by Gus Adi on 23/04/22.
//

import DinotisDesignSystem
import Introspect
import SwiftUI
import OneSignal

struct PreviewTalentView: View {

 	@ObservedObject var viewModel: PreviewTalentViewModel

	var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .center) {
                Color.white.edgesIgnoringSafeArea(.all)
                    .alert(isPresented: $viewModel.isRefreshFailed) {
                        Alert(
                            title: Text(LocaleText.attention),
                            message: Text(LocaleText.sessionExpireText),
                            dismissButton: .default(Text(LocaleText.returnText), action: {
                                NavigationUtil.popToRootView()
                                self.viewModel.stateObservable.userType = 0
                                self.viewModel.stateObservable.isVerified = ""
                                self.viewModel.stateObservable.refreshToken = ""
                                self.viewModel.stateObservable.accessToken = ""
                                self.viewModel.stateObservable.isAnnounceShow = false
                                OneSignal.setExternalUserId("")
                            })
                        )
                    }
                
                VStack(spacing: 0) {
                    
                    HeaderView(viewModel: viewModel)
                        .padding(.top, 5)
                        .padding(.bottom)
                        .background(Color.clear)
                    
                    List {
                        
                        Section {
                            ProfileHeaderView()
                        }
                        .listRowBackground(Color.DinotisDefault.baseBackground)
                        .listRowSeparator(.hidden)
                        .listSectionSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 18, bottom: 10, trailing: 18))
                        
                        Section {
                            RatingView()
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 18, bottom: -22, trailing: 18))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listSectionSeparator(.hidden)
                        
                        Section {
                            SectionContentView(geometry: geo)
                        } header: {
                            SectionHeaderView()
                        }
                        .listRowSpacing(0)
                        .headerProminence(.increased)
                        .listRowInsets(EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 18))
                        .listRowSeparator(.hidden)
                        .listSectionSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .onAppear {
                        UITableView.appearance().sectionHeaderTopPadding = 0
                    }
                    .onDisappear(perform: {
                        UITableView.appearance().sectionHeaderTopPadding = 25
                    })
                    .listStyle(.plain)
                    .padding(.horizontal, -18)
                    
                    DinotisLoadingView(.fullscreen, hide: !viewModel.isLoading)
                }
                .onAppear {
                    Task {
                        await viewModel.getUsers()
                    }
                }
                .navigationBarTitle(Text(""))
                .navigationBarHidden(true)
            }
        }
	}
    
    @ViewBuilder
    func ProfileHeaderView() -> some View {
        VStack(spacing: 16) {
            HStack(alignment: .center, spacing: 20) {
                DinotisImageLoader(urlString: (viewModel.userData?.profilePhoto).orEmpty())
                    .scaledToFill()
                    .frame(width: 84, height: 84)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Group {
                            if viewModel.userData?.isVerified ?? true {
                                Text("\((viewModel.userData?.name).orEmpty()) \(Image.Dinotis.accountVerifiedIcon)")
                                    
                            } else {
                                Text("\((viewModel.userData?.name).orEmpty())")
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
                        
                        Text(viewModel.professionText)
                            .font(.robotoMedium(size: 12))
                            .minimumScaleFactor(0.9)
                            .foregroundColor(.DinotisDefault.black2)
                    }
                    
                    HStack(spacing: 4) {
                        Image.talentProfilePerson2Icon
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16)
                        
                        Text("\((viewModel.userData?.management?.managementTalents ?? []).count) \(LocalizableText.creatorTitle)")
                            .font(.robotoBold(size: 12))
                            .minimumScaleFactor(0.9)
                    }
                    .foregroundColor(.DinotisDefault.primary)
                    
                    if let data = viewModel.userData?.managements,
                       !data.isEmpty
                    {
                        Button {
                            
                        } label: {
                            (
                                Text(LocalizableText.managementName)
                                    .foregroundColor(.DinotisDefault.black3)
                                    .font(.robotoRegular(size: 12))
                                +
                                (
                                    Text("\((data.first?.management?.user?.name).orEmpty()) ")
                                        .foregroundColor(.DinotisDefault.primary)
                                    +
                                    Text(data.count > 1 ? LocalizableText.managementPlusOther(data.count-1) : "")
                                        .foregroundColor(.DinotisDefault.black3)
                                )
                                .font(.robotoBold(size: 12))
                            )
                        }
                    }
                }
            }
            
            if let avail = viewModel.userData?.userAvailability?.availability, avail {
                VStack(spacing: 8) {
                    DinotisPrimaryButton(
                        text: "🔥 \(LocalizableText.requestPrivateLabel)",
                        type: .adaptiveScreen,
                        height: 40,
                        textColor: .white,
                        bgColor: .DinotisDefault.primary
                    ) {
                        
                    }
                    .shineEffect()
                    
                    HStack(spacing: 6) {
                        Button {
                            
                        } label: {
                            HStack(spacing: 4) {
                                Image.talentProfileHeartAddBlackIcon
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 20)
                                    .isHidden((viewModel.userData?.isFollowed).orFalse(), remove: true)
                                
                                Text((viewModel.userData?.isFollowed).orFalse() ? LocalizableText.unfollowLabel : LocalizableText.followLabel)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .foregroundColor((viewModel.userData?.isFollowed).orFalse() ? .DinotisDefault.black2 : .DinotisDefault.primary)
                            .frame(maxWidth: .infinity, maxHeight: 40, alignment: .center)
                            .background((viewModel.userData?.isFollowed).orFalse() ? Color(red: 0.91, green: 0.91, blue: 0.91) : .DinotisDefault.lightPrimary)
                            .cornerRadius(12)
                            .overlay {
                                if !(viewModel.userData?.isFollowed).orFalse() {
                                    RoundedRectangle(cornerRadius: 12)
                                        .inset(by: 0.55)
                                        .stroke(Color.DinotisDefault.primary, lineWidth: 1)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            
                        } label: {
                            HStack(spacing: 4) {
                                Image.talentProfileStarAddBlackIcon
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 20)
                                
                                Text(LocalizableText.subscribeLabel)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .foregroundColor(.DinotisDefault.primary)
                            .frame(maxWidth: .infinity, maxHeight: 40, alignment: .center)
                            .background(Color.DinotisDefault.lightPrimary)
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                    .font(.robotoMedium(size: 14))
                }
            } else {
                HStack(spacing: 8) {
                    DinotisPrimaryButton(
                        text: "🔥 \(LocalizableText.requestPrivateLabel)",
                        type: .adaptiveScreen,
                        height: 40,
                        textColor: .white,
                        bgColor: .DinotisDefault.primary
                    ) {
                        
                    }
                    .shineEffect()
                    
                    Button {
                        
                    } label: {
                        HStack(spacing: 4) {
                            Image.talentProfileHeartAddBlackIcon
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 20)
                                .isHidden((viewModel.userData?.isFollowed).orFalse(), remove: true)
                            
                            Text((viewModel.userData?.isFollowed).orFalse() ? LocalizableText.unfollowLabel : LocalizableText.followLabel)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .foregroundColor((viewModel.userData?.isFollowed).orFalse() ? .DinotisDefault.black2 : .DinotisDefault.primary)
                        .frame(maxWidth: .infinity, maxHeight: 40, alignment: .center)
                        .background((viewModel.userData?.isFollowed).orFalse() ? Color(red: 0.91, green: 0.91, blue: 0.91) : .DinotisDefault.lightPrimary)
                        .cornerRadius(12)
                        .overlay {
                            if !(viewModel.userData?.isFollowed).orFalse() {
                                RoundedRectangle(cornerRadius: 12)
                                    .inset(by: 0.55)
                                    .stroke(Color.DinotisDefault.primary, lineWidth: 1)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .font(.robotoMedium(size: 14))
                }
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
                
                Text(((viewModel.userData?.meetingCount).orZero()).kmbFormatter())
                    .font(.robotoBold(size: 16))
            }
            .foregroundColor(.DinotisDefault.black2)
            .frame(maxWidth: .infinity)
            
            Divider()
            
            VStack(spacing: 4) {
                Text(LocalizableText.talentDetailFollower)
                    .font(.robotoRegular(size: 12))
                
                Text(((viewModel.userData?.followerCount).orZero()).kmbFormatter())
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
                    
                    Text((viewModel.userData?.rating) ?? "-")
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
                
            } label: {
                Text(LocalizableText.overviewLabel)
                    .font(.robotoBold(size: 14))
                    .foregroundColor(.DinotisDefault.black1)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    .background(Color.white)
            }
            .buttonStyle(.plain)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.DinotisDefault.primary)
                    .frame(height: 1)
            }
            
            
        }
        .background(Color.white)
        .overlay(alignment: .top) {
            Divider()
        }
    }
    
    @ViewBuilder
    func SectionContentView(geometry: GeometryProxy) -> some View {
        Group {
            OverviewView(geometry: geometry)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
    }
    
    @ViewBuilder
    func OverviewView(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(LocalizableText.talentDetailAboutMe)
                    .font(.robotoBold(size: 14))
                    .foregroundColor(.DinotisDefault.black3)
                
                Text((viewModel.userData?.profileDescription).orEmpty())
                    .font(.robotoRegular(size: 14))
                    .foregroundColor(.DinotisDefault.black1)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(LocalizableText.talentDetailGallery)
                    .font(.robotoBold(size: 14))
                    .foregroundColor(.DinotisDefault.black3)
                
                if let data = viewModel.userData?.userHighlights {
                    let width = geometry.size.width / 3.5
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
                        }
                    })
                } else if (viewModel.userData?.userHighlights ?? []).isEmpty {
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
}

struct PreviewTalentView_Previews: PreviewProvider {
	static var previews: some View {
		PreviewTalentView(viewModel: PreviewTalentViewModel())
	}
}
