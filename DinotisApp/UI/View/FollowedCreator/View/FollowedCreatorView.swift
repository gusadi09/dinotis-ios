//
//  FollowedCreatorView.swift
//  DinotisApp
//
//  Created by Gus Adi on 19/12/22.
//

import SwiftUI
import DinotisDesignSystem
import DinotisData
import SwiftUINavigation

struct FollowedCreatorView: View {
    
    @ObservedObject var viewModel: FollowedCreatorViewModel
    
    @Environment(\.dismiss) var dismiss
    
    @Binding var tabValue: TabRoute
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                NavigationLink(
                    unwrapping: $viewModel.route,
                    case: /HomeRouting.talentProfileDetail
                ) { viewModel in
                    CreatorProfileDetailView(viewModel: viewModel.wrappedValue, tabValue: $tabValue)
                } onNavigate: { _ in
                    
                } label: {
                    EmptyView()
                }
                
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    HeaderView(
                        type: .textHeader,
                        title: LocalizableText.titleFollowedCreator,
                        headerColor: .white,
                        leadingButton: {
                            DinotisElipsisButton(
                                icon: .generalBackIcon,
                                iconColor: .DinotisDefault.black1,
                                bgColor: .DinotisDefault.white,
                                strokeColor: nil,
                                iconSize: 12,
                                type: .primary, {
                                    dismiss()
                                }
                            )
                        },
                        trailingButton: {
                            Button {
                                viewModel.openWhatsApp()
                            } label: {
                                Image.generalQuestionIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 25)
                            }
                        }
                    )
                    
                    SectionHeaderView(geo: geo)
                    
                    TabView(selection: $viewModel.currentTab) {
                        FollowingListView(geo: geo)
                            .tag(0)
                        
                        SubscriptionListView()
                            .tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .background(Color.DinotisDefault.baseBackground.ignoresSafeArea())
                }
            }
        }
        .navigationBarTitle(Text(""))
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await viewModel.getFollowedCreator()
                await viewModel.getSubscriptionList()
            }
        }
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

extension FollowedCreatorView {
    @ViewBuilder
    func SectionHeaderView(geo: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Button {
                    withAnimation {
                        viewModel.currentTab = 0
                    }
                } label: {
                    Text(LocalizableText.talentDetailFollowing)
                        .font(viewModel.currentTab == 0 ? .robotoBold(size: 14) : .robotoRegular(size: 14))
                        .foregroundColor(viewModel.currentTab == 0 ? .DinotisDefault.black1 : .DinotisDefault.black2)
                        .padding(.bottom, 14)
                        .frame(maxWidth: .infinity)
                }
                
                Button {
                    withAnimation {
                        viewModel.currentTab = 1
                    }
                } label: {
                    Text(LocalizableText.subscriptionLabel)
                        .font(viewModel.currentTab == 1 ? .robotoBold(size: 14) : .robotoRegular(size: 14))
                        .foregroundColor(viewModel.currentTab == 1 ? .DinotisDefault.black1 : .DinotisDefault.black2)
                        .padding(.bottom, 14)
                        .frame(maxWidth: .infinity)
                }
            }
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.DinotisDefault.lightPrimary)
                
                Rectangle()
                    .foregroundColor(.DinotisDefault.primary)
                    .frame(width: geo.size.width/2)
                    .offset(x: CGFloat(viewModel.currentTab) * (geo.size.width/2))
                    .animation(.easeInOut, value: viewModel.currentTab)
            }
            .frame(height: 2)
        }
        .background(Color.white)
    }
    
    @ViewBuilder
    func FollowingListView(geo: GeometryProxy) -> some View {
        List {
            if viewModel.talentData.isEmpty {
                Group {
                    if viewModel.isLoadingFollowing {
                        LottieView(name: "regular-loading", loopMode: .loop)
                            .scaledToFit()
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                    } else {
                        HStack {
                            Spacer()
                            
                            VStack(alignment: .center, spacing: -10) {
                                Image.onboardingSlide1Image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 266)
                                
                                Text(LocalizableText.choosenCreatorEmpty)
                                    .font(.robotoBold(size: 16))
                                    .foregroundColor(.black)
                            }
                            
                            Spacer()
                        }
                    }
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                
            } else {
                Group {
                    LazyVGrid(
                        columns: Array(
                            repeating: GridItem(.flexible(), spacing: 10),
                            count: UIDevice.current.userInterfaceIdiom == .pad ? 4 : 2
                        )
                    ) {
                        ForEach(viewModel.talentData, id: \.id) { item in
                            Button {
                                viewModel.routeToTalentDetail(username: item.username.orEmpty())
                            } label: {
                                CreatorCard(
                                    with: viewModel.convertToCardModel(with: item),
                                    size: UIDevice.current.userInterfaceIdiom == .pad ? geo.size.width/4 - 22 : geo.size.width/2 - 22
                                )
                                .onAppear {
                                    Task {
                                        if item.id == viewModel.talentData.last?.id,
                                           viewModel.nextCursosr != nil {
                                            viewModel.query.skip = viewModel.query.take
                                            viewModel.query.take += 5
                                            
                                            await viewModel.getFollowedCreator(isMore: true)
                                        }
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            
                        }
                    }
                    
                    LottieView(name: "regular-loading", loopMode: .loop)
                        .scaledToFit()
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .isHidden(!viewModel.isLoadingFollowing, remove: true)
                }
                .padding(.vertical)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.getFollowedCreator()
        }
    }
    
    @ViewBuilder
    func SubscriptionListView() -> some View {
        List {
            Group {
                if viewModel.subscriptionData.isEmpty {
                    if viewModel.isLoadingSubs {
                        LottieView(name: "regular-loading", loopMode: .loop)
                            .scaledToFit()
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                    } else {
                        HStack {
                            Spacer()
                            
                            VStack(alignment: .center, spacing: -10) {
                                Image.onboardingSlide1Image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 266)
                                
                                Text(LocalizableText.choosenCreatorEmpty)
                                    .font(.robotoBold(size: 16))
                                    .foregroundColor(.black)
                            }
                            
                            Spacer()
                        }
                    }
                } else {
                    ForEach(viewModel.subscriptionData, id: \.id) { item in
                        Button {
                            viewModel.routeToTalentDetail(username: (item.user?.username).orEmpty())
                        } label: {
                            SubscriptionRow(data: item)
                                .onAppear {
                                    Task {
                                        if item.id == viewModel.subscriptionData.last?.id,
                                           viewModel.subsNextCursor != nil
                                        {
                                            viewModel.subsQuery.skip = viewModel.query.take
                                            viewModel.subsQuery.take += 5
                                            
                                            await viewModel.getSubscriptionList(isMore: true)
                                        }
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                    }
                    
                    LottieView(name: "regular-loading", loopMode: .loop)
                        .scaledToFit()
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .isHidden(!viewModel.isLoadingSubs, remove: true)
                }
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
        .listStyle(.plain)
        .refreshable {
            Task {
                await viewModel.getSubscriptionList()
            }
        }
    }
    
    @ViewBuilder
    func SubscriptionRow(data: SubscriptionResponse) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 10) {
                DinotisImageLoader(urlString: (data.user?.profilePhoto).orEmpty())
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                
                VStack(alignment: .leading, spacing: 3) {
                    Text((data.user?.name).orEmpty())
                        .font(.robotoBold(size: 14))
                        .foregroundColor(.DinotisDefault.black2)
                    
                    Group {
                        if let endAt = data.endAt,
                           let attr = try? AttributedString(markdown: LocalizableText.subscriptionEndTimeAt(date: endAt.toStringFormat(with: .ddMMMyyyy))) {
                            Text(attr)
                        } else {
                            if let attr = try? AttributedString(markdown: LocalizableText.subscriptionEndTimeAt(date: "(\(LocalizableText.adaptiveLabel))")) {
                                Text(attr)
                            }
                        }
                    }
                    .lineLimit(2)
                    .font(.robotoRegular(size: 12))
                    .foregroundColor(.DinotisDefault.black3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Group {
                    if data.subscriptionType == "UNSUBSCRIBED" {
                        Text(data.subscriptionType.orEmpty().capitalized)
                    } else {
                        Text(data.subscriptionType == "FREE" ? LocalizableText.freeSubscriptionLabel : LocalizableText.premiumSubscriptionLabel)
                    }
                }
                .font(.robotoBold(size: 10))
                .foregroundColor(data.subscriptionType == "UNSUBSCRIBED" ? .DinotisDefault.red : .DinotisDefault.primary)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    Capsule()
                        .foregroundColor(data.subscriptionType == "UNSUBSCRIBED" ? .DinotisDefault.red.opacity(0.1) : .DinotisDefault.lightPrimary))
                .layoutPriority(1)
            }
            .padding(.horizontal)
            
            Rectangle()
                .foregroundColor(.DinotisDefault.black3.opacity(0.2))
                .frame(height: 1)
        }
        .padding(.top)
    }
}

struct FollowedCreatorView_Previews: PreviewProvider {
    static var previews: some View {
        FollowedCreatorView(viewModel: FollowedCreatorViewModel(backToHome: {}), tabValue: .constant(.agenda))
    }
}
