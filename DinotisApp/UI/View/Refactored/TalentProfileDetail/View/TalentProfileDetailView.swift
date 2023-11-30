//
//  TalentProfileDetailView.swift
//  DinotisApp
//
//  Created by Gus Adi on 25/08/21.
//

import CurrencyFormatter
import DinotisDesignSystem
import Lottie
import QGrid
import StoreKit
import SwiftUI
import SwiftUINavigation

struct TalentProfileDetailView: View {
    
    @ObservedObject var viewModel: TalentProfileDetailViewModel
    
    @Environment(\.dismiss) var dismiss
    
    @Binding var tabValue: TabRoute
    
    var body: some View {
        
        GeometryReader { geo in
            ZStack(alignment: .center) {
                LinearGradient(
                    colors: [
                        .DinotisDefault.baseBackground,
                        .DinotisDefault.baseBackground,
                        .white,
                        .white
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                NavigationLink(
                    unwrapping: $viewModel.route,
                    case: /HomeRouting.bundlingDetail,
                    destination: { viewModel in
                        BundlingDetailView(viewModel: viewModel.wrappedValue, isPreview: false, tabValue: $tabValue)
                    },
                    onNavigate: { _ in },
                    label: {
                        EmptyView()
                    }
                )
                
                NavigationLink(
                    unwrapping: $viewModel.route,
                    case: /HomeRouting.scheduleList,
                    destination: {viewModel in
                        ScheduleListView(mainTabSelection: $tabValue)
                            .environmentObject(viewModel.wrappedValue)
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
                
                NavigationLink(
                    unwrapping: $viewModel.route,
                    case: /HomeRouting.bookingInvoice,
                    destination: { viewModel in
                        UserInvoiceBookingView(
                            viewModel: viewModel.wrappedValue,
                            mainTabValue: $tabValue
                        )
                    },
                    onNavigate: {_ in},
                    label: {
                        EmptyView()
                    }
                )
                
                VStack(spacing: 0) {
                    
                    HeaderView(
                        title: (viewModel.talentData?.name).orEmpty(),
                        headerColor: .DinotisDefault.baseBackground,
                        textColor: .black,
                        leadingButton: {
                            DinotisElipsisButton(
                                icon: .generalBackIcon,
                                iconColor: .black,
                                bgColor: .white,
                                iconSize: 12,
                                type: .primary
                            ) {
                                dismiss()
                            }
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 0)
                        },
                        trailingButton: {
                            
                            DinotisElipsisButton(
                                icon: .talentProfileShareIcon,
                                iconColor: .DinotisDefault.primary,
                                bgColor: .white,
                                iconSize: 20,
                                type: .primary,
                                padding: 13
                            ) {
                                viewModel.shareSheet(url: "\(viewModel.config.environment.openURL)user/talent/" + (viewModel.talentData?.username).orEmpty())
                            }
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 0)
                        }
                    )
                    
                    List {
                        
                        Section {
                            HStack(alignment: .center, spacing: 20) {
                                DinotisImageLoader(urlString: (viewModel.talentData?.profilePhoto).orEmpty(), width: 86, height: 86)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        if viewModel.talentData?.isVerified ?? false {
                                            Text("\(viewModel.talentName ?? "") \(Image.Dinotis.accountVerifiedIcon)")
                                                .font(.robotoBold(size: 14))
                                                .minimumScaleFactor(0.9)
                                                .lineLimit(2)
                                                .foregroundColor(.black)
                                        } else {
                                            Text("\(viewModel.talentName ?? "")")
                                                .font(.robotoBold(size: 14))
                                                .minimumScaleFactor(0.9)
                                                .lineLimit(2)
                                                .foregroundColor(.black)
                                        }
                                        
                                        Spacer()
                                    }
                                    
                                    HStack(spacing: 8) {
                                        Image.talentProfileManagementIcon
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 13)
                                        
                                        if viewModel.talentData?.management == nil {
                                            
                                            if let professionData = viewModel.talentData?.professions {
                                                HStack(spacing: 0) {
                                                    ForEach(professionData, id: \.profession?.id) { item in
                                                        Text((item.profession?.name).orEmpty())
                                                            .font(.robotoMedium(size: 10))
                                                            .minimumScaleFactor(0.9)
                                                            .foregroundColor(.DinotisDefault.black2)
                                                        
                                                        if item != professionData.last {
                                                            Text(", ")
                                                                .font(.robotoMedium(size: 10))
                                                                .minimumScaleFactor(0.9)
                                                                .foregroundColor(.DinotisDefault.black2)
                                                        }
                                                    }
                                                }
                                            }
                                        } else {
                                            Text(LocalizableText.professionManagement)
                                                .font(.robotoMedium(size: 10))
                                                .minimumScaleFactor(0.9)
                                                .foregroundColor(.DinotisDefault.black2)
                                        }
                                    }
                                    
                                    // FIXME: Add management name, fix layout
                                    
                                    if viewModel.talentData?.management == nil {
                                        if let data = viewModel.talentData?.managements?.prefix(3), !data.isEmpty {
                                            
                                          Button {
                                            viewModel.isShowManagements = true
                                          } label: {
                                            (
                                              Text(LocalizableText.managementName)
                                                .foregroundColor(.DinotisDefault.black2)
                                              +
                                              (
                                                Text("\(data.compactMap({ $0.management?.user?.name}).joined(separator: ", ")), ")
                                                  .foregroundColor(.DinotisDefault.black2)
                                                +
                                                Text(LocalizableText.searchSeeAllLabel)
                                                  .foregroundColor(.DinotisDefault.primary)
                                              )
                                              .underline()
                                            )
                                            .font(.robotoBold(size: 10))
                                          }
                                            
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .listRowBackground(Color.DinotisDefault.baseBackground)
                        .listRowSeparator(.hidden)
                        .listSectionSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 10, trailing: 20))
                        
                        Section {
                            HStack {
                                VStack(spacing: 5) {
                                    Text(LocalizableText.talentDetailSession)
                                        .font(.robotoRegular(size: 14))
                                        .foregroundColor(.black)
                                    
                                    Text((viewModel.talentData?.meetingCount).orZero().kmbFormatter())
                                        .font(.robotoMedium(size: 18))
                                        .foregroundColor(.black)
                                }
                                
                                Spacer(minLength: 20)
                                
                                VStack(spacing: 5) {
                                    Text(LocalizableText.talentDetailFollower)
                                        .font(.robotoRegular(size: 14))
                                        .foregroundColor(.black)
                                    
                                    Text((viewModel.talentData?.followerCount).orZero().kmbFormatter())
                                        .font(.robotoMedium(size: 18))
                                        .foregroundColor(.black)
                                }
                                
                                Spacer(minLength: 20)
                                
                                VStack(spacing: 5) {
                                    Text(LocalizableText.talentDetailRating)
                                        .font(.robotoRegular(size: 14))
                                        .foregroundColor(.black)
                                    
                                    HStack(spacing: 5) {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.DinotisDefault.orange)
                                        
                                        Text((viewModel.talentData?.rating).orEmpty())
                                            .font(.robotoMedium(size: 18))
                                            .foregroundColor(.black)
                                    }
                                }
                                
                                Spacer(minLength: 30)
                                
                                if (viewModel.talentData?.isFollowed ?? false) {
                                    if viewModel.isLoadingFollow {
                                        ProgressView()
                                            .progressViewStyle(.circular)
                                            .tint(.DinotisDefault.primary)
                                            .padding(.vertical, 14.5)
                                            .frame(width: geo.size.width/3.5)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .foregroundColor(.clear)
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.DinotisDefault.primary, lineWidth: 1)
                                            )
                                    } else {
                                        DinotisSecondaryButton(
                                            text: LocalizableText.talentDetailFollowing,
                                            type: .fixed(geo.size.width/3.5),
                                            textColor: .DinotisDefault.primary,
                                            bgColor: .clear,
                                            strokeColor: .DinotisDefault.primary
                                        ) {
                                            Task {
                                                await viewModel.unfollowCreator()
                                            }
                                        }
                                    }
                                } else {
                                    if viewModel.isLoadingFollow {
                                        ProgressView()
                                            .progressViewStyle(.circular)
                                            .tint(.white)
                                            .padding(.vertical, 14.5)
                                            .frame(width: geo.size.width/3.5)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .foregroundColor(.DinotisDefault.primary)
                                            )
                                    } else {
                                        DinotisPrimaryButton(
                                            text:  LocalizableText.talentDetailFollow,
                                            type: .fixed(geo.size.width/3.5),
                                            textColor: .white,
                                            bgColor: .DinotisDefault.primary
                                        ) {
                                            Task {
                                                await viewModel.followCreator()
                                            }
                                        }
                                    }
                                    
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        }
                        .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))
                        .listRowBackground(Color.DinotisDefault.baseBackground)
                        .listRowSeparator(.hidden)
                        .listSectionSeparator(.hidden)
                        
                        Section {
                          SectionContent(viewModel: viewModel, tabValue: $tabValue, geo: geo)
                                .buttonStyle(.plain)
                        } header: {
                            SectionHeader(viewModel: viewModel)
                                .background(Color.DinotisDefault.baseBackground)
                                .buttonStyle(.plain)
                        }
                        .headerProminence(.increased)
                        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        .listRowSeparator(.hidden)
                        .listSectionSeparator(.hidden)
                        .listRowBackground(Color.white)
                        .onChange(of: viewModel.filterSelection) { newValue in
                            Task {
                                if let optionLabel = viewModel.filterOption.firstIndex(where: { query in
                                    query.label.orEmpty() == newValue
                                }) {
                                    if newValue == viewModel.filterOption[optionLabel].label.orEmpty() {
                                        if let isEnded = viewModel.filterOption[optionLabel].queries?.firstIndex(where: { option in
                                            option.name.orEmpty() == "is_ended"
                                        }) {
                                            viewModel.meetingParam.isEnded = (viewModel.filterOption[optionLabel].queries?[isEnded].value).orEmpty()
                                        } else {
                                            viewModel.meetingParam.isEnded = ""
                                        }
                                        
                                        if let isAvail = viewModel.filterOption[optionLabel].queries?.firstIndex(where: { option in
                                            option.name.orEmpty() == "is_available"
                                        }) {
                                            viewModel.meetingParam.isAvailable = (viewModel.filterOption[optionLabel].queries?[isAvail].value).orEmpty()
                                        } else {
                                            viewModel.meetingParam.isAvailable = ""
                                        }
                                    }
                                    
                                    print(viewModel.meetingParam)
                                    
                                    viewModel.bundlingData = []
                                    viewModel.meetingData = []
                                    viewModel.meetingParam.skip = 0
                                    viewModel.meetingParam.take = 15
                                    await viewModel.getTalentMeeting(by: (viewModel.talentData?.id).orEmpty(), isMore: false)
                                }
                            }
                        }
                    }
                    .onAppear {
                        UITableView.appearance().sectionHeaderTopPadding = 0
                    }
                    .onDisappear(perform: {
                        UITableView.appearance().sectionHeaderTopPadding = 25
                    })
                    .listStyle(.plain)
                    .refreshable {
                        viewModel.resetList()
                        viewModel.onScreenAppear()
                    }
                    .padding(.horizontal, -18)
                    
                    NavigationLink(
                        unwrapping: $viewModel.route,
                        case: /HomeRouting.paymentMethod,
                        destination: {viewModel in
                            PaymentMethodView(viewModel: viewModel.wrappedValue, mainTabValue: $tabValue)
                        },
                        onNavigate: {_ in},
                        label: {
                            EmptyView()
                        }
                    )
                    
                    NavigationLink(
                        unwrapping: $viewModel.route,
                        case: /HomeRouting.userScheduleDetail,
                        destination: { viewModel in
                            UserScheduleDetail(
                                viewModel: viewModel.wrappedValue,
                                mainTabValue: $tabValue
                            )
                        },
                        onNavigate: {_ in},
                        label: {
                            EmptyView()
                        }
                    )
                    
                    NavigationLink(
                        unwrapping: $viewModel.route,
                        case: /HomeRouting.rateCardServiceBookingForm,
                        destination: { viewModel in
                            RateCardServiceBookingView(
                                viewModel: viewModel.wrappedValue,
                                mainTabValue: $tabValue
                            )
                        },
                        onNavigate: {_ in},
                        label: {
                            EmptyView()
                        }
                    )
                    
                    NavigationLink(
                        unwrapping: $viewModel.route,
                        case: /HomeRouting.detailPayment,
                        destination: {viewModel in
                            DetailPaymentView(viewModel: viewModel.wrappedValue, mainTabValue: $tabValue)
                        },
                        onNavigate: {_ in},
                        label: {
                            EmptyView()
                        }
                    )
                }
                
                DinotisLoadingView(.fullscreen, hide: !viewModel.isLoading)
            }
            .onAppear(perform: {
                Task.init {
                    viewModel.onScreenAppear()
                    viewModel.getProductOnAppear()
                    AppDelegate.orientationLock = .portrait
                }
            })
            .onDisappear(perform: {
                viewModel.onDisappearView()
            })
            .valueChanged(value: viewModel.success, onChange: { value in
                if value {
                    viewModel.talentName = viewModel.talentData?.name
                    viewModel.talentPhoto = viewModel.talentData?.profilePhoto
                }
            })
            .navigationBarTitle(Text(""))
            .navigationBarHidden(true)
            .sheet(
                isPresented: $viewModel.isPresent,
                content: {
                    if #available(iOS 16.0, *) {
                        SlideOverCardView(viewModel: viewModel, tab: $tabValue)
                            .padding()
                            .padding(.vertical)
                            .padding(.top)
                            .presentationDetents([.fraction(0.8), .large])
                            .dynamicTypeSize(.large)
                    } else {
                        SlideOverCardView(viewModel: viewModel, tab: $tabValue)
                            .padding()
                            .padding(.vertical)
                            .padding(.top)
                            .dynamicTypeSize(.large)
                    }
                    
                }
            )
            .sheet(
                isPresented: $viewModel.showPaymentMenu,
                content: {
                    if #available(iOS 16.0, *) {
                        PaymentTypeOption(viewModel: viewModel)
                            .padding([.top, .horizontal])
                            .presentationDetents([.fraction(viewModel.totalPart > 1 ? 0.25 : 0.4), .large])
                            .dynamicTypeSize(.large)
                    } else {
                        PaymentTypeOption(viewModel: viewModel)
                            .padding(.top)
                            .padding()
                            .padding(.vertical)
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
                            .padding()
                            .padding(.vertical)
                            .presentationDetents([.fraction(0.8), .large])
                            .dynamicTypeSize(.large)
                    } else {
                        CoinPaymentSheetView(viewModel: viewModel)
                            .padding()
                            .padding(.vertical)
                            .dynamicTypeSize(.large)
                    }
                }
            )
            .sheet(
                isPresented: $viewModel.showAddCoin,
                content: {
                    if #available(iOS 16.0, *) {
                        AddCoinSheetView(viewModel: viewModel, geo: geo)
                            .padding()
                            .padding(.vertical)
                            .presentationDetents([.fraction(0.85), .large])
                            .dynamicTypeSize(.large)
                    } else {
                        AddCoinSheetView(viewModel: viewModel, geo: geo)
                            .padding()
                            .padding(.vertical)
                            .dynamicTypeSize(.large)
                    }
                }
            )
            .sheet(
                isPresented: $viewModel.isTransactionSucceed,
                content: {
                    if #available(iOS 16.0, *) {
                        CoinBuySucceed(geo: geo)
                            .padding()
                            .padding(.vertical)
                            .presentationDetents([.fraction(0.5), .large])
                            .dynamicTypeSize(.large)
                    } else {
                        CoinBuySucceed(geo: geo)
                            .padding()
                            .padding(.vertical)
                            .dynamicTypeSize(.large)
                    }
                    
                }
            )
            .sheet(
                isPresented: $viewModel.showingRequest,
                content: {
                    if #available(iOS 16.0, *) {
                        RequestMenuView(viewModel: viewModel)
                            .padding()
                            .padding(.vertical)
                            .presentationDetents([.medium, .large])
                            .dynamicTypeSize(.large)
                    } else {
                        RequestMenuView(viewModel: viewModel)
                            .padding()
                            .padding(.vertical)
                            .dynamicTypeSize(.large)
                    }
                    
                }
            )
            .sheet(isPresented: $viewModel.isShowCollabList, content: {
                if #available(iOS 16.0, *) {
                  SelectedCollabCreatorView(
                    isEdit: false,
                    isAudience: true,
                    arrUsername: .constant((viewModel.selectedMeeting?.meetingCollaborations ?? []).compactMap({
                      $0.username
                  })),
                    arrTalent: .constant(viewModel.selectedMeeting?.meetingCollaborations ?? [])) {
                      viewModel.isShowCollabList = false
                    } visitProfile: { item in
                      viewModel.isPresent = false
                      viewModel.routeToMyTalent(talent: item)
                    }
                    .presentationDetents([.medium, .large])
                    .dynamicTypeSize(.large)
                } else {
                  SelectedCollabCreatorView(
                    isEdit: false,
                    isAudience: true,
                    arrUsername: .constant((viewModel.selectedMeeting?.meetingCollaborations ?? []).compactMap({
                      $0.username
                  })),
                    arrTalent: .constant(viewModel.selectedMeeting?.meetingCollaborations ?? [])) {
                      viewModel.isShowCollabList = false
                    } visitProfile: { item in
                      viewModel.isPresent = false
                      viewModel.routeToMyTalent(talent: item)
                    }
                    .dynamicTypeSize(.large)
                }
            })
        }
        .dinotisAlert(
            isPresent: $viewModel.isError,
            title: LocalizableText.attentionText,
            isError: true,
            message: viewModel.isRefreshFailed ? LocalizableText.alertSessionExpired : viewModel.error.orEmpty(),
            primaryButton: .init(
                text: LocalizableText.okText,
                action: viewModel.isRefreshFailed ? {
                    viewModel.routeToRoot()
                } : {}
            )
        )
        .dinotisAlert(
            isPresent: $viewModel.requestSuccess,
            title: LocalizableText.alertSuccessRequestSessionTitle,
            isError: false,
            message: LocalizableText.alertSuccessRequestSessionMessage,
            primaryButton: .init(text: LocalizableText.okText, action: {})
        )
        .dinotisAlert(
            isPresent: $viewModel.isShowAlert,
            title: viewModel.alert.title,
            isError: viewModel.alert.isError,
            message: viewModel.alert.message,
            primaryButton: viewModel.alert.primaryButton
        )
        .sheet(isPresented: $viewModel.isShowManagements) {
            if #available(iOS 16.0, *) {
                ManagementBottomSheet(viewModel: viewModel)
                    .presentationDetents([.fraction(0.4), .fraction(0.6), .large])
                    .dynamicTypeSize(.large)
            } else {
                ManagementBottomSheet(viewModel: viewModel)
                    .dynamicTypeSize(.large)
            }
        }
    }
}

//struct TalentProfileDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        TalentProfileDetailView(viewModel: TalentProfileDetailViewModel(backToHome: {}, username: "ramzramzz"), tabValue: .constant(.agenda))
//    }
//}

extension TalentProfileDetailView {
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
}
