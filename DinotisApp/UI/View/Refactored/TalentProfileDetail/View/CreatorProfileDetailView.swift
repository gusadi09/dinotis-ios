//
//  CreatorProfileDetailView.swift
//  DinotisApp
//
//  Created by Irham Naufal on 07/11/23.
//

import CurrencyFormatter
import DinotisDesignSystem
import DinotisData
import Lottie
import QGrid
import StoreKit
import SwiftUI
import SwiftUINavigation

struct CreatorProfileDetailView: View {
    
    @ObservedObject var viewModel: TalentProfileDetailViewModel
    
    @Environment(\.dismiss) var dismiss
    
    @Binding var tabValue: TabRoute
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.openURL) var openURL
    
    var hasRegularWidth: Bool {
        horizontalSizeClass == .regular
    }
    
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
                    case: /HomeRouting.detailVideo,
                    destination: { viewModel in
                        DetailVideoView()
                            .environmentObject(viewModel.wrappedValue)
                    },
                    onNavigate: {_ in},
                    label: {
                        EmptyView()
                    }
                )
                
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
                        title: viewModel.isManagementView ? LocalizableText.managementProfileLabel : (viewModel.talentData?.username).orEmpty(),
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
                        }
                    )
                    
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
                        .isHidden(viewModel.isManagementView, remove: true)
                        
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
                        
                        Task {
                            await viewModel.getVideoList(isMore: false)
                        }
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
                
                DinotisLoadingView(.fullscreen, hide: !viewModel.isLoading && !viewModel.isLoadingPaySubs)
            }
            .overlay {
                ImageDetailView()
                    .isHidden(!viewModel.isShowImageDetail, remove: true)
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
            .sheet(isPresented: $viewModel.showingRequest, content: {
                    if #available(iOS 16.0, *) {
                        RequestMenuSheet()
                            .presentationDetents([.height(340)])
                            .dynamicTypeSize(.large)
                    } else {
                        RequestMenuSheet()
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
            .fullScreenCover(isPresented: $viewModel.isShowInvoice, content: {
                SubscriptionInvoice()
            })
        }
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
            primaryButton: viewModel.alert.primaryButton,
            secondaryButton: viewModel.alert.secondaryButton
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
        .sheet(isPresented: $viewModel.isShowSubscribeSheet) {
            if #available(iOS 16.0, *) {
                SubscribeSheet()
                    .presentationDetents([.height(viewModel.subsSheetHeight)])
                    .dynamicTypeSize(.large)
            } else {
                SubscribeSheet()
                    .dynamicTypeSize(.large)
            }
        }
        .sheet(isPresented: $viewModel.isShowBundlingSheet) {
            if #available(iOS 16.0, *) {
                BundlingListSheet()
                    .presentationDetents([.height(480), .fraction(0.99)])
                    .presentationDragIndicator(.hidden)
                    .dynamicTypeSize(.large)
            } else {
                BundlingListSheet()
                    .dynamicTypeSize(.large)
            }
        }
    }
}

struct CreatorProfileDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CreatorProfileDetailView(viewModel: TalentProfileDetailViewModel(backToHome: {}, username: "ramzramzz"), tabValue: .constant(.agenda))
    }
}
