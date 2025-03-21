//
//  TalentScheduleDetailView.swift
//  DinotisApp
//
//  Created by Gus Adi on 20/08/21.
//

import SwiftUI
import SwiftUITrackableScrollView
import CurrencyFormatter
import SwiftUINavigation
import DinotisData
import DinotisDesignSystem

struct TalentScheduleDetailView: View {
    
    @ObservedObject var viewModel: ScheduleDetailViewModel
    @ObservedObject var stateObservable = StateObservable.shared
    
    @StateObject private var customerChatManager = CustomerChatManager()
    
    @Environment(\.dismiss) var dismiss
    
    @Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
    
    private var viewController: UIViewController? {
        self.viewControllerHolder.value
    }
    
    var body: some View {
        ZStack {
            if let meetId = viewModel.dataMeeting?.id {
                NavigationLink(
                    unwrapping: $viewModel.route,
                    case: /HomeRouting.videoCall,
                    destination: {viewModel in
                        PrivateVideoCallView(
                            viewModel: viewModel.wrappedValue
                        )
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
                    case: /HomeRouting.sessionRecordingList,
                    destination: { viewModel in
                        SessionRecordingListView()
                            .environmentObject(viewModel.wrappedValue)
                    },
                    onNavigate: {_ in},
                    label: {
                        EmptyView()
                    }
                )
            }
            
            NavigationLink(
                destination: EmptyView(),
                label: {
                    EmptyView()
                })
            
            ZStack(alignment: .top) {
                Image.Dinotis.userTypeBackground
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    
                    ZStack {
                        HStack {
                            Spacer()
                            Text(LocaleText.videoCallDetailTitle)
                                .font(.robotoBold(size: 14))
                                .foregroundColor(.black)
                            
                            Spacer()
                        }
                        .padding()
                        
                        HStack {
                            Button(action: {
                                dismiss()
                            }, label: {
                                Image.Dinotis.arrowBackIcon
                                    .padding()
                                    .background(Color.white)
                                    .clipShape(Circle())
                            })
                            .padding(.leading)
                            
                            Spacer()
                        }
                        
                    }
                    .background(
                        Color.white
                            .edgesIgnoringSafeArea(.all)
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 20)
                    )
                    
                    RefreshableScrollViews(action: refreshList) {
                        
                        LazyVStack(spacing: 5) {
                            if viewModel.isLoading {
                                HStack {
                                    Spacer()
                                    
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .padding(.top)
                                    
                                    Spacer()
                                }
                            }
                            
                            RequestTimeline(viewModel: viewModel)
                                .environmentObject(customerChatManager)
                            
                            if let data = viewModel.dataMeeting {
                                TalentDetailScheduleCardView(
                                    data: .constant(data),
                                    onTapEdit: {
                                        if viewModel.dataMeeting?.meetingRequest != nil {
                                            viewModel.routeToEditRateCardSchedule()
                                        } else {
                                            viewModel.routeToEditSchedule()
                                        }
                                    }, onTapDelete: {
                                        viewModel.isDeleteShow.toggle()
                                        viewModel.typeAlert = .deleteSelector
                                        viewModel.isShowAlert = true
                                    }, onTapEnd: {
                                        viewModel.isEndShow.toggle()
                                        viewModel.typeAlert = .endSelector
                                        viewModel.isShowAlert = true
                                    }
                                )
                                .valueChanged(value: viewModel.conteOffset) { val in
                                    viewModel.tabColor = val > 0 ? Color.white : Color.clear
                                }
                                
                                if data.endedAt != nil {
                                    Button(action: {
                                        if let waurl = URL(string: "https://wa.me/6281318506068") {
                                            if UIApplication.shared.canOpenURL(waurl) {
                                                UIApplication.shared.open(waurl, options: [:], completionHandler: nil)
                                            }
                                        }
                                    }, label: {
                                        HStack {
                                            Image.Dinotis.whatsappLogo
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 28)
                                            
                                            Text(LocaleText.needHelpText)
                                                .font(.robotoRegular(size: 14))
                                                .foregroundColor(.black)
                                                .underline()
                                            +
                                            Text(LocaleText.contactUsText)
                                                .font(.robotoBold(size: 14))
                                                .foregroundColor(.black)
                                                .underline()
                                            
                                            Spacer()
                                            
                                            Image.Dinotis.chevronLeftCircleIcon
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .foregroundColor(.white)
                                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 0)
                                        )
                                        .padding(.horizontal)
                                    })
                                    .padding(.bottom, viewModel.videos.isEmpty ? 8: 0)
                                    
                                    Button(action: {
                                        if viewModel.showArchived() {
                                            viewModel.routeToSetUpVideo()
                                        } else {
                                            viewModel.routeToSessionRecordingList()
                                        }
                                    }, label: {
                                        HStack {
                                            Image.archiveDownloadDocumentIcon
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 28)
                                            
                                            Text(viewModel.showArchived() ? "Upload Rekaman Sesi" : LocalizableText.seeSessionRecordingLabel)
                                                .font(.robotoRegular(size: 14))
                                                .foregroundColor(.black)
                                            
                                            Spacer()
                                            
                                            Image.Dinotis.chevronLeftCircleIcon
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .foregroundColor(.white)
                                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 0)
                                        )
                                        .padding(.horizontal)
                                    })
                                    .padding(.vertical, 8)
                                    .isHidden(viewModel.videos.isEmpty, remove: true)
                                    
                                    VStack {
                                        Text(LocaleText.revenueSummaryText)
                                            .font(.robotoBold(size: 16))
                                        
                                        HStack {
                                            if let dataParticipant = data.participants {
                                                Text("\(dataParticipant)x")
                                                    .font(.robotoBold(size: 14))
                                                
                                                Text(LocaleText.generalParticipant)
                                                    .font(.robotoRegular(size: 14))
                                                
                                                Spacer()
                                                
                                                Text(data.price.orEmpty().toCurrency())
                                                    .font(.robotoBold(size: 14))
                                            }
                                        }
                                        .padding(.top, 15)
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .foregroundColor(.white)
                                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 0)
                                    )
                                    .padding(.horizontal)
                                    .padding(.bottom)
                                    
                                } else {
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
                                            
                                            Text(LocaleText.needHelpText)
                                                .font(.robotoRegular(size: 14))
                                                .foregroundColor(.black)
                                                .underline()
                                            +
                                            Text(LocaleText.contactUsText)
                                                .font(.robotoBold(size: 14))
                                                .foregroundColor(.black)
                                                .underline()
                                            
                                            Spacer()
                                            
                                            Image.Dinotis.chevronLeftCircleIcon
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .foregroundColor(.white)
                                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 0)
                                        )
                                        .padding(.horizontal)
                                    })
                                    .padding(.bottom)
                                }
                                
                            }
                        }
                    }
                    
                    VStack(spacing: 0) {
                        
                        Group {
                            if viewModel.dataMeeting != nil {
                                HStack {
                                    if viewModel.dataMeeting?.meetingRequest != nil && !(viewModel.dataMeeting?.meetingRequest?.isConfirmed ?? false) {
                                        if viewModel.dataMeeting?.meetingRequest?.isAccepted ?? false {
                                            HStack {
                                                HStack(spacing: 7) {
                                                    Button {
                                                        viewModel.confirmationSheet.toggle()
                                                    } label: {
                                                        HStack {
                                                            Spacer()
                                                            
                                                            Text(LocaleText.cancelText)
                                                                .font(.robotoMedium(size: 12))
                                                                .foregroundColor(.black)
                                                            
                                                            Spacer()
                                                        }
                                                        .padding()
                                                        .background(Color.secondaryViolet)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 12)
                                                                .stroke(Color.DinotisDefault.primary, lineWidth: 1)
                                                        )
                                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                                    }
                                                    
                                                    Button {
                                                        viewModel.routeToEditRateCardSchedule()
                                                    } label: {
                                                        HStack {
                                                            Spacer()
                                                            
                                                            Text(LocaleText.setTime)
                                                                .font(.robotoMedium(size: 12))
                                                                .foregroundColor(.white)
                                                            
                                                            Spacer()
                                                        }
                                                        .padding()
                                                        .background(Color.DinotisDefault.primary)
                                                        .cornerRadius(12)
                                                    }
                                                    
                                                }
                                            }
                                            .padding()
                                            .background(Color.white.edgesIgnoringSafeArea(.all))
                                            .isHidden(
                                                !(viewModel.dataMeeting?.meetingRequest?.isConfirmed ?? false) && !(viewModel.dataMeeting?.meetingRequest?.isAccepted ?? false),
                                                remove: !(viewModel.dataMeeting?.meetingRequest?.isConfirmed ?? false)
                                            )
                                        }
                                        
                                    } else if viewModel.dataMeeting?.endedAt != nil && (viewModel.dataMeeting?.meetingCollaborations != nil || !(viewModel.dataMeeting?.meetingCollaborations ?? []).isEmpty) {
                                        VStack(spacing: 5) {
                                            HStack {
                                                if let visibilty = viewModel.dataMeeting?.collaboratorAudienceVisibility, visibilty || (viewModel.dataMeeting?.user?.id).orEmpty() == stateObservable.userId {
                                                    Button {
                                                        viewModel.isDetail.toggle()
                                                    } label: {
                                                        HStack(spacing: 8) {
                                                            Text(LocalizableText.revenueDetailText)
                                                                .font(.robotoMedium(size: 14))
                                                                .foregroundStyle(Color.DinotisDefault.primary)
                                                            
                                                            Image.chevronUp
                                                                .resizable()
                                                                .frame(width: 10.5, height: 10)
                                                                .foregroundColor(Color.DinotisDefault.primary)
                                                            
                                                        }
                                                        .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                                        .background(
                                                            RoundedRectangle(cornerRadius: 42)
                                                                .stroke(Color.DinotisDefault.primary)
                                                        )
                                                        .foregroundColor(Color.DinotisDefault.primary)
                                                    }
                                                }
                                                
                                                Spacer()
                                                
                                                VStack(alignment: .trailing) {
                                                    let filteredCollaborations = viewModel.dataMeeting?.meetingCollaborations?.filter {
                                                        $0.user != nil && $0.approvedAt != nil && $0.declinedAt == nil
                                                    }
                                                    
                                                    Text(LocalizableText.totalIncomeText)
                                                        .font(.robotoMedium(size: 12))
                                                        .foregroundStyle(Color.DinotisDefault.black2)
                                                    
                                                    if let dataPrice = viewModel.dataMeeting {
                                                        if (filteredCollaborations != nil) {
                                                            if let hargaPerUser = Double(dataPrice.price.orEmpty()) {
                                                                let totalPendapatan = hargaPerUser * Double((viewModel.dataMeeting?.participants).orZero())
                                                                
                                                                Text("Rp\(totalPendapatan.toPriceFormat())")
                                                                    .font(.robotoRegular(size: 18))
                                                                    .foregroundStyle(Color.DinotisDefault.primary)
                                                            }
                                                        } else {
                                                            if (dataPrice.price.orEmpty()) == "0" {
                                                                Text(LocaleText.freeTextLabel)
                                                                    .font(.robotoBold(size: 18))
                                                                    .foregroundColor(Color.DinotisDefault.primary)
                                                            } else {
                                                                let priceText = "Rp\(dataPrice.price.orEmpty().toPriceFormat())"
                                                                Text(priceText)
                                                                    .font(.robotoBold(size: 18))
                                                                    .foregroundColor(Color.DinotisDefault.primary)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            .padding(.vertical)
                                            
                                            if viewModel.dataMeeting?.endedAt == nil {
                                                Divider()
                                                    .padding(.bottom)
                                                
                                                Button {
                                                    viewModel.startPresented.toggle()
                                                } label: {
                                                    Text(LocaleText.startNowText)
                                                        .font(.robotoMedium(size: 14))
                                                        .foregroundColor(.white)
                                                        .padding(10)
                                                        .padding(.horizontal, 5)
                                                        .padding(.vertical, 5)
                                                        .frame(maxWidth: .infinity)
                                                        .contentShape(RoundedRectangle(cornerRadius: 12))
                                                }
                                                .background(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .foregroundColor(Color.DinotisDefault.primary)
                                                )
                                                
                                            }
                                            
                                        }
                                        .padding(.horizontal, 20)
                                        .background(
                                            RoundedCorner(radius: 20, corners: [.topLeft, .topRight])
                                                .foregroundColor(.white)
                                                .shadow(color: .black.opacity(0.01), radius: 2, x: 0, y: -5)
                                                .ignoresSafeArea(.all)
                                        )
                                        
                                    } else {
                                        VStack(spacing: 5) {
                                            HStack {
                                                Spacer()
                                                
                                                VStack(alignment: .trailing) {
                                                    let filteredCollaborations = viewModel.dataMeeting?.meetingCollaborations?.filter {
                                                        $0.user != nil && $0.approvedAt != nil && $0.declinedAt == nil
                                                    }
                                                    
                                                    Text(LocalizableText.totalIncomeText)
                                                        .font(.robotoMedium(size: 12))
                                                        .foregroundStyle(Color.DinotisDefault.black2)
                                                    
                                                    if let dataPrice = viewModel.dataMeeting {
                                                        if (filteredCollaborations != nil) {
                                                            if let hargaPerUser = Double(dataPrice.price.orEmpty()) {
                                                                let totalPendapatan = hargaPerUser * Double((viewModel.dataMeeting?.participants).orZero())
                                                                
                                                                Text("Rp\(totalPendapatan.toPriceFormat())")
                                                                    .font(.robotoBold(size: 14))
                                                                    .foregroundStyle(Color.DinotisDefault.primary)
                                                            }
                                                        } else {
                                                            if (dataPrice.price.orEmpty()) == "0" {
                                                                Text(LocaleText.freeTextLabel)
                                                                    .font(.robotoBold(size: 14))
                                                                    .foregroundColor(Color.DinotisDefault.primary)
                                                            } else {
                                                                let priceText = "Rp\(dataPrice.price.orEmpty().toPriceFormat())"
                                                                Text(priceText)
                                                                    .font(.robotoBold(size: 14))
                                                                    .foregroundColor(Color.DinotisDefault.primary)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            .padding(.vertical)
                                            
                                            if viewModel.dataMeeting?.endedAt == nil {
                                                Divider()
                                                    .padding(.bottom)
                                                
                                                Button {
                                                    viewModel.startPresented.toggle()
                                                } label: {
                                                    Text(LocaleText.startNowText)
                                                        .font(.robotoMedium(size: 14))
                                                        .foregroundColor(.white)
                                                        .padding(10)
                                                        .padding(.horizontal, 5)
                                                        .padding(.vertical, 5)
                                                        .frame(maxWidth: .infinity)
                                                        .contentShape(RoundedRectangle(cornerRadius: 12))
                                                }
                                                .background(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .foregroundColor(Color.DinotisDefault.primary)
                                                )
                                                
                                            }
                                            
                                        }
                                        .padding(.horizontal, 20)
                                        .background(
                                            RoundedCorner(radius: 20, corners: [.topLeft, .topRight])
                                                .foregroundColor(.white)
                                                .shadow(color: .black.opacity(0.01), radius: 2, x: 0, y: -5)
                                                .ignoresSafeArea(.all)
                                        )
                                    }
                                    
                                }
                            }
                        }
                        
                        NavigationLink(
                            unwrapping: $viewModel.route,
                            case: /HomeRouting.setUpVideo,
                            destination: { viewModel in
                                SetUpVideoView()
                                    .environmentObject(viewModel.wrappedValue)
                            },
                            onNavigate: {_ in},
                            label: {
                                EmptyView()
                            }
                        )
					}
                    .onChange(of: viewModel.successDetail) { _ in
                        guard let meet = viewModel.dataMeeting else {return}
                    }
                    
                }
                .valueChanged(value: viewModel.successDetail, onChange: { value in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        withAnimation(.spring()) {
                            if value {
                                self.viewModel.isLoading = false
                            }
                        }
                    })
                })
                .valueChanged(value: viewModel.isLoadingDetail) { value in
                    DispatchQueue.main.async {
                        withAnimation(.spring()) {
                            if value {
                                self.viewModel.isLoading = value
                            }
                        }
                    }
                }
                
                NavigationLink(
                    unwrapping: $viewModel.route,
                    case: /HomeRouting.editRateCardSchedule,
                    destination: { viewModel in
                        TalentEditRateCardScheduleView(viewModel: viewModel.wrappedValue)
                    },
                    onNavigate: { _ in },
                    label: {
                        EmptyView()
                    }
                )
                
                NavigationLink(
                    unwrapping: $viewModel.route,
                    case: /HomeRouting.editScheduleMeeting,
                    destination: { viewModel in
                        EditTalentMeetingView(viewModel: viewModel.wrappedValue)
                    },
                    onNavigate: { _ in },
                    label: {
                        EmptyView()
                    }
                )
            }
            .sheet(unwrapping: $viewModel.route, case: /HomeRouting.scheduleNegotiationChat, onDismiss: {
                customerChatManager.hasUnreadMessage = false
            }) { viewModel in
                ScheduleNegotiationChatView(viewModel: viewModel.wrappedValue, isOnSheet: true)
                    .environmentObject(customerChatManager)
                    .dynamicTypeSize(.large)
            }
            .onDisappear {
                customerChatManager.disconnect()
            }
            
        }
        .navigationBarTitle(Text(""))
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.startPresented, content: {
            if #available(iOS 16.0, *) {
                VStack(spacing: 15) {
                    if viewModel.isLoadingStart {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
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
                                    Task {
                                        await viewModel.startMeeting()
                                        
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
                }
                .padding()
                .padding(.vertical)
                .presentationDetents([.height(450)])
                .dynamicTypeSize(.large)
            } else {
                VStack(spacing: 15) {
                    if viewModel.isLoadingStart {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
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
                                    Task {
                                        await viewModel.startMeeting()
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
                }
                .padding()
                .padding(.vertical)
                .dynamicTypeSize(.large)
            }
            
        })
        .onChange(of: viewModel.tokenConversation, perform: { value in
            customerChatManager.connect(accessToken: value, conversationName: (viewModel.dataBooking?.meeting?.meetingRequest?.id).orEmpty())
        })
        .onAppear(perform: {
            Task {
                await viewModel.getDetailMeeting()
                viewModel.onGetRecordings()
            }

            stateObservable.spotlightedIdentity = ""
            StateObservable.shared.cameraPositionUsed = .front
            StateObservable.shared.twilioRole = ""
            StateObservable.shared.twilioUserIdentity = ""
            StateObservable.shared.twilioAccessToken = ""
        })
        .onDisappear(perform: {
            viewModel.startPresented = false
        })
        .sheet(isPresented: $viewModel.confirmationSheet, content: {
            if #available(iOS 16.0, *) {
                DeclinedSheet(viewModel: viewModel, isOnSheet: true)
                    .dynamicTypeSize(.large)
            } else {
                DeclinedSheet(viewModel: viewModel, isOnSheet: false)
                    .dynamicTypeSize(.large)
            }
        })
        .sheet(isPresented: $viewModel.presentDelete, content: {
            if #available(iOS 16.0, *) {
                VStack(spacing: 15) {
                    Image.Dinotis.removeUserImage
                        .resizable()
                        .scaledToFit()
                        .frame(height: 184)
                    
                    VStack(spacing: 35) {
                        VStack(spacing: 10) {
                            Text(LocaleText.deleteParticipantAlertTitle)
                                .font(.robotoBold(size: 14))
                                .foregroundColor(.black)
                            
                            Text(LocaleText.deleteparticipantSubLabel)
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                        }
                        
                        HStack(spacing: 15) {
                            Button(action: {
                                viewModel.presentDelete.toggle()
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
                                
                            }, label: {
                                HStack {
                                    Spacer()
                                    Text(LocaleText.deleteText)
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
                .presentationDetents([.fraction(0.8), .large])
                .dynamicTypeSize(.large)
            } else {
                VStack(spacing: 15) {
                    Image.Dinotis.removeUserImage
                        .resizable()
                        .scaledToFit()
                        .frame(height: 184)
                    
                    VStack(spacing: 35) {
                        VStack(spacing: 10) {
                            Text(LocaleText.deleteParticipantAlertTitle)
                                .font(.robotoBold(size: 14))
                                .foregroundColor(.black)
                            
                            Text(LocaleText.deleteparticipantSubLabel)
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                        }
                        
                        HStack(spacing: 15) {
                            Button(action: {
                                viewModel.presentDelete.toggle()
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
                                
                            }, label: {
                                HStack {
                                    Spacer()
                                    Text(LocaleText.deleteText)
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
        .dinotisAlert(
            isPresent: $viewModel.isShowAlert,
            type: .general,
            title: viewModel.alertTitle(),
            isError: viewModel.typeAlert == .error || viewModel.typeAlert == .refreshFailed || viewModel.typeAlert == .oneHourRestricted,
            message: viewModel.alertContent(),
            primaryButton: .init(text: viewModel.alertButtonText(), action: {
                viewModel.alertAction {
                    dismiss()
                }
            }),
            secondaryButton: viewModel.typeAlert == .deleteSelector || viewModel.typeAlert == .endSelector ? .init(text: LocaleText.noText, action: {}) : nil
        )
        .sheet(isPresented: $viewModel.isDetail, content: {
            if #available(iOS 16.0, *) {
                VStack {
                    let filteredCollaborations = viewModel.dataMeeting?.meetingCollaborations?.filter {
                        $0.user != nil && $0.approvedAt != nil && $0.declinedAt == nil
                    }
                    
                    VStack(spacing: 20) {
                        HStack {
                            Text(LocalizableText.incomeDetailText)
                                .font(.robotoBold(size: 14))
                                .foregroundStyle(Color.DinotisDefault.black2)
                            Spacer()
                            Button {
                                viewModel.isDetail.toggle()
                            } label: {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .frame(width: 12, height: 12)
                                    .foregroundStyle(Color.DinotisDefault.black2)
                            }
                        }
                        
                        VStack(spacing: 10) {
                            HStack {
                                Text("\(LocalizableText.audienceTitle) :")
                                    .font(.robotoBold(size: 14))
                                    .foregroundStyle(Color.DinotisDefault.primary)
                                Spacer()
                            }
                            
                            ScrollView {
                                if !(viewModel.dataMeeting?.meetingCollaborations ?? []).isEmpty {
                                    ForEach(viewModel.dataMeeting?.meetingCollaborations ?? [], id: \.id) { item in
                                        if (filteredCollaborations != nil) {
                                            HStack {
                                                Text((item.user?.name).orEmpty())
                                                    .lineLimit(1)
                                                    .font(.robotoMedium(size: 12))
                                                    .foregroundStyle(Color.DinotisDefault.black3)
                                                
                                                Spacer()
                                                Text("\((item.bookingCount).orZero())")
                                                    .font(.robotoBold(size: 14))
                                                    .foregroundStyle(Color.DinotisDefault.black3)
                                            }
                                            .padding(.bottom, 5)
                                            
                                        }
                                    }
                                }
                            }
                            
                            Divider()
                        }
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 7) {
                        HStack {
                            Text(LocalizableText.totalAudienceText)
                                .font(.robotoBold(size: 14))
                                .foregroundStyle(Color.DinotisDefault.black2)
                            Spacer()
                            if (filteredCollaborations != nil) {
                                Text("\((viewModel.dataMeeting?.participants).orZero())")
                                    .font(.robotoRegular(size: 14))
                                    .foregroundStyle(Color.DinotisDefault.black2)
                            } else {
                                Text("0")
                                    .font(.robotoRegular(size: 14))
                                    .foregroundStyle(Color.DinotisDefault.black2)
                            }
                        }
                        
                        
                        
                        HStack {
                            Text(LocalizableText.priceLabel)
                                .font(.robotoBold(size: 14))
                                .foregroundStyle(Color.DinotisDefault.black2)
                            Spacer()
                            
                            if let dataPrice = viewModel.dataMeeting {
                                if (dataPrice.price.orEmpty()) == "0" {
                                    Text(LocaleText.freeTextLabel)
                                        .font(.robotoRegular(size: 14))
                                        .foregroundColor(.DinotisDefault.black2)
                                } else {
                                    if !(dataPrice.isPrivate ?? false) {
                                        Text("Rp\(dataPrice.price.orEmpty().toPriceFormat())")
                                            .font(.robotoRegular(size: 14))
                                            .foregroundColor(.DinotisDefault.black2)
                                    } else {
                                        Text("Rp\(dataPrice.price.orEmpty().toPriceFormat())")
                                            .font(.robotoRegular(size: 14))
                                            .foregroundColor(.DinotisDefault.black2)
                                    }
                                }
                            }
                        }
                    }
                    
                    
                    Divider()
                    
                    HStack {
                        Text(LocalizableText.totalIncomeText)
                            .font(.robotoBold(size: 14))
                            .foregroundStyle(Color.DinotisDefault.primary)
                        Spacer()
                        if (filteredCollaborations == nil) {
                            if let dataPrice = viewModel.dataMeeting {
                                if let hargaPerUser = Double(dataPrice.price.orEmpty()) {
                                    let totalPendapatan = hargaPerUser * Double((viewModel.dataMeeting?.participants).orZero())
                                    
                                    Text("Rp\(totalPendapatan.toPriceFormat())")
                                        .font(.robotoRegular(size: 14))
                                        .foregroundStyle(Color.DinotisDefault.primary)
                                }
                            }
                        }else {
                            if let dataPrice = viewModel.dataMeeting {
                                if (dataPrice.price.orEmpty()) == "0" {
                                    Text(LocaleText.freeTextLabel)
                                        .font(.robotoBold(size: 14))
                                        .foregroundColor(.DinotisDefault.primary)
                                } else {
                                    if !(dataPrice.isPrivate ?? false) {
                                        Text("Rp\(dataPrice.price.orEmpty().toPriceFormat())")
                                            .font(.robotoBold(size: 14))
                                            .foregroundColor(.DinotisDefault.primary)
                                    } else {
                                        Text("Rp\(dataPrice.price.orEmpty().toPriceFormat())")
                                            .font(.robotoBold(size: 14))
                                            .foregroundColor(.DinotisDefault.primary)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom)
                    
                    Button {
                        withAnimation {
                            viewModel.startPresented.toggle()
                        }
                        
                    } label: {
                        HStack {
                            Text(LocaleText.startNowText)
                                .font(.robotoMedium(size: 14))
                                .foregroundColor(.white)
                                .padding(10)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 5)
                        }
                        .frame(width: UIScreen.main.bounds.width - 40, height: 52)
                        .background(Color.DinotisDefault.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    
                    
                    
                    
                }
                .padding()
                .presentationDetents([.height(320), .large])
                .dynamicTypeSize(.large)
                .presentationDragIndicator(.hidden)
            } else {
                VStack {
                    let filteredCollaborations = viewModel.dataMeeting?.meetingCollaborations?.filter {
                        $0.user != nil && $0.approvedAt != nil && $0.declinedAt == nil
                    }
                    
                    VStack(spacing: 20) {
                        HStack {
                            Text(LocalizableText.incomeDetailText)
                                .font(.robotoBold(size: 14))
                                .foregroundStyle(Color.DinotisDefault.black2)
                            Spacer()
                            Button {
                                viewModel.isDetail.toggle()
                            } label: {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .frame(width: 12, height: 12)
                                    .foregroundStyle(Color.DinotisDefault.black2)
                            }
                        }
                        
                        VStack(spacing: 10) {
                            HStack {
                                Text("\(LocalizableText.audienceTitle) :")
                                    .font(.robotoBold(size: 14))
                                    .foregroundStyle(Color.DinotisDefault.primary)
                                Spacer()
                            }
                            
                            ScrollView {
                                if !(viewModel.dataMeeting?.meetingCollaborations ?? []).isEmpty {
                                    ForEach(viewModel.dataMeeting?.meetingCollaborations ?? [], id: \.id) { item in
                                        if (filteredCollaborations != nil) {
                                            HStack {
                                                Text((item.user?.name).orEmpty())
                                                    .lineLimit(1)
                                                    .font(.robotoMedium(size: 12))
                                                    .foregroundStyle(Color.DinotisDefault.black3)
                                                
                                                Spacer()
                                                Text("\((item.bookingCount).orZero())")
                                                    .font(.robotoBold(size: 14))
                                                    .foregroundStyle(Color.DinotisDefault.black3)
                                            }
                                            .padding(.bottom, 5)
                                            
                                        }
                                    }
                                }
                            }
                            
                            Divider()
                        }
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 7) {
                        HStack {
                            Text(LocalizableText.totalAudienceText)
                                .font(.robotoBold(size: 14))
                                .foregroundStyle(Color.DinotisDefault.black2)
                            Spacer()
                            if (filteredCollaborations != nil) {
                                Text("\((viewModel.dataMeeting?.participants).orZero())")
                                    .font(.robotoRegular(size: 14))
                                    .foregroundStyle(Color.DinotisDefault.black2)
                            } else {
                                Text("0")
                                    .font(.robotoRegular(size: 14))
                                    .foregroundStyle(Color.DinotisDefault.black2)
                            }
                        }
                        
                        
                        
                        HStack {
                            Text(LocalizableText.priceLabel)
                                .font(.robotoBold(size: 14))
                                .foregroundStyle(Color.DinotisDefault.black2)
                            Spacer()
                            
                            if let dataPrice = viewModel.dataMeeting {
                                if (dataPrice.price.orEmpty()) == "0" {
                                    Text(LocaleText.freeTextLabel)
                                        .font(.robotoRegular(size: 14))
                                        .foregroundColor(.DinotisDefault.black2)
                                } else {
                                    if !(dataPrice.isPrivate ?? false) {
                                        Text("Rp\(dataPrice.price.orEmpty().toPriceFormat())")
                                            .font(.robotoRegular(size: 14))
                                            .foregroundColor(.DinotisDefault.black2)
                                    } else {
                                        Text("Rp\(dataPrice.price.orEmpty().toPriceFormat())")
                                            .font(.robotoRegular(size: 14))
                                            .foregroundColor(.DinotisDefault.black2)
                                    }
                                }
                            }
                        }
                    }
                    
                    
                    Divider()
                    
                    HStack {
                        Text(LocalizableText.totalIncomeText)
                            .font(.robotoBold(size: 14))
                            .foregroundStyle(Color.DinotisDefault.primary)
                        Spacer()
                        if (filteredCollaborations == nil) {
                            if let dataPrice = viewModel.dataMeeting {
                                if let hargaPerUser = Double(dataPrice.price.orEmpty()) {
                                    let totalPendapatan = hargaPerUser * Double((viewModel.dataMeeting?.participants).orZero())
                                    
                                    Text("Rp\(totalPendapatan.toPriceFormat())")
                                        .font(.robotoRegular(size: 14))
                                        .foregroundStyle(Color.DinotisDefault.primary)
                                }
                            }
                        }else {
                            if let dataPrice = viewModel.dataMeeting {
                                if (dataPrice.price.orEmpty()) == "0" {
                                    Text(LocaleText.freeTextLabel)
                                        .font(.robotoBold(size: 14))
                                        .foregroundColor(.DinotisDefault.primary)
                                } else {
                                    if !(dataPrice.isPrivate ?? false) {
                                        Text("Rp\(dataPrice.price.orEmpty().toPriceFormat())")
                                            .font(.robotoBold(size: 14))
                                            .foregroundColor(.DinotisDefault.primary)
                                    } else {
                                        Text("Rp\(dataPrice.price.orEmpty().toPriceFormat())")
                                            .font(.robotoBold(size: 14))
                                            .foregroundColor(.DinotisDefault.primary)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom)
                    
                    Button {
                        withAnimation {
                            viewModel.startPresented.toggle()
                        }
                        
                    } label: {
                        HStack {
                            Text(LocaleText.startNowText)
                                .font(.robotoMedium(size: 14))
                                .foregroundColor(.white)
                                .padding(10)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 5)
                        }
                        .frame(width: UIScreen.main.bounds.width - 40, height: 52)
                        .background(Color.DinotisDefault.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    
                    
                    
                    
                }
                .padding()
                .dynamicTypeSize(.large)
            }
        })
    }
    
    private func refreshList() {
        Task {
            await viewModel.getDetailMeeting()
        }
    }
}

struct TalentScheduleDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TalentScheduleDetailView(viewModel: ScheduleDetailViewModel(isActiveBooking: true, bookingId: "", backToHome: {}, isDirectToHome: false))
    }
}

extension TalentScheduleDetailView {
    
    struct DeclinedSheet: View {
        
        @ObservedObject var viewModel: ScheduleDetailViewModel
        @State var selectedReason = [CancelOptionData]()
        @State var report = ""
        let isOnSheet: Bool
        
        var body: some View {
            VStack(spacing: 25) {
                HStack {
                    Text(LocaleText.cancelConfirmationText)
                        .font(.robotoBold(size: 14))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.confirmationSheet = false
                    }, label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 10)
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                    })
                }
                
                LazyVStack(spacing: 15) {
                    ForEach(viewModel.cancelOptionData.unique(), id: \.id) { item in
                        Button {
                            if isSelected(item: item, arrSelected: selectedReason) {
                                if let itemToRemoveIndex = selectedReason.firstIndex(of: item) {
                                    selectedReason.remove(at: itemToRemoveIndex)
                                }
                            } else {
                                selectedReason.append(item)
                            }
                        } label: {
                            HStack(alignment: .top) {
                                if isSelected(item: item, arrSelected: selectedReason) {
                                    Image.Dinotis.filledChecklistIcon
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 15)
                                } else {
                                    Image.Dinotis.emptyChecklistIcon
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 15)
                                }
                                
                                Text(item.name.orEmpty())
                                    .font(.robotoRegular(size: 12))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                            }
                        }
                    }
                    
                    if selectedReason.contains(where: { $0.id == 5 }) {
                        TextField(LocaleText.reportNotesPlaceholder, text: $report)
                            .font(.robotoRegular(size: 12))
                            .foregroundColor(.black)
                            .accentColor(.black)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundColor(.white)
                            )
                            .clipped()
                            .overlay(
                                RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray5), lineWidth: 1)
                            )
                            .shadow(color: Color.dinotisShadow.opacity(0.06), radius: 40, x: 0.0, y: 0.0)
                    }
                }
                
                if isOnSheet {
                    Spacer()
                }
                
                Button {
                    Task {
                        let selected = selectedReason.compactMap({ $0.id })
                        await viewModel.confirmRequest(
                            isAccepted: false,
                            reasons: selected,
                            otherReason: report
                        )
                    }
                } label: {
                    HStack {
                        
                        Spacer()
                        
                        Text(LocaleText.sendText)
                            .font(.robotoMedium(size: 12))
                            .foregroundColor(selectedReason.isEmpty || (selectedReason.contains(where: { $0.id == 5 }) && report.isEmpty) ? Color(.systemGray2) : .white)
                        
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(selectedReason.isEmpty || (selectedReason.contains(where: { $0.id == 5 }) && report.isEmpty) ? Color(.systemGray5) : .DinotisDefault.primary)
                    )
                }
                .disabled(selectedReason.isEmpty || (selectedReason.contains(where: { $0.id == 5 }) && report.isEmpty))
                
            }
            .padding()
        }
        
        func isSelected(item: CancelOptionData, arrSelected: [CancelOptionData]) -> Bool {
            arrSelected.contains(where: { $0.id == item.id })
        }
    }
    
    struct RequestTimeline: View {
        
        @ObservedObject var viewModel: ScheduleDetailViewModel
        @EnvironmentObject var customerChatManager: CustomerChatManager
        
        var body: some View {
            if viewModel.dataMeeting?.meetingRequest != nil {
                
                if let detail = viewModel.dataMeeting {
                    VStack {
                        Text(LocaleText.detailScheduleStepTitle)
                            .font(.robotoBold(size: 12))
                            .foregroundColor(.black)
                        
                        HStack(spacing: 12) {
                            if UIDevice.current.userInterfaceIdiom == .pad {
                                Spacer()
                                
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
                                                (Image.Dinotis.stepCheckmark)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 35, height: 35)
                                                    .opacity(viewModel.isPaymentDone(status: detail.status.orEmpty()) ? 1 : 0.2)
                                                
                                                Text(LocaleText.detailScheduleStepOne)
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
                                                    Image.Dinotis.stepCheckmark
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 35, height: 35)
                                                    
                                                    Text(LocaleText.waitingConfirmation)
                                                        .font(.robotoMedium(size: 10))
                                                        .foregroundColor(.DinotisDefault.primary)
                                                } else if viewModel.isWaitingCreatorConfirmationFailed(
                                                    status: detail.status.orEmpty(),
                                                    isAccepted: detail.meetingRequest?.isAccepted
                                                ) {
                                                    Image.Dinotis.xmarkIcon
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 35, height: 35)
                                                    
                                                    Text(LocaleText.waitingConfirmation)
                                                        .font(.robotoMedium(size: 10))
                                                        .foregroundColor(.red)
                                                } else {
                                                    Image.Dinotis.stepCheckmark
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 35, height: 35)
                                                        .opacity(0.2)
                                                    
                                                    Text(LocaleText.waitingConfirmation)
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
                                                    (Image.Dinotis.stepCheckmark)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 35, height: 35)
                                                    
                                                    Text(LocaleText.setSessionTime)
                                                        .font(.robotoMedium(size: 10))
                                                        .foregroundColor(.DinotisDefault.primary)
                                                } else if viewModel.isScheduleConfirmationFailed(
                                                    status: detail.status.orEmpty(),
                                                    isConfirmed: detail.meetingRequest?.isConfirmed
                                                ) {
                                                    Image.Dinotis.xmarkIcon
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 35, height: 35)
                                                    
                                                    Text(LocaleText.setSessionTime)
                                                        .font(.robotoMedium(size: 10))
                                                        .foregroundColor(.red)
                                                } else {
                                                    (Image.Dinotis.stepCheckmark)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 35, height: 35)
                                                        .opacity(0.2)
                                                    
                                                    Text(LocaleText.setSessionTime)
                                                        .font(.robotoMedium(size: 10))
                                                        .foregroundColor(Color(.systemGray4))
                                                }
                                                
                                            }
                                            .multilineTextAlignment(.center)
                                            .frame(width: 100)
                                            
                                            VStack(spacing: 6) {
                                                
                                                Image.Dinotis.stepCheckmark
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 35, height: 35)
                                                    .opacity(
                                                        viewModel.isScheduleStartedDone(status: detail.status.orEmpty()) ? 1 : 0.2
                                                    )
                                                
                                                Text(LocaleText.detailScheduleStepThree)
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
                                                Image.Dinotis.stepCheckmark
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 35, height: 35)
                                                    .opacity(viewModel.isScheduleEndedDone(status: detail.status.orEmpty()) ? 1 : 0.2)
                                                
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
                                
                                Spacer()
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
                                                    (Image.Dinotis.stepCheckmark)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 35, height: 35)
                                                        .opacity(viewModel.isPaymentDone(status: detail.status.orEmpty()) ? 1 : 0.2)
                                                    
                                                    Text(LocaleText.detailScheduleStepOne)
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
                                                        Image.Dinotis.stepCheckmark
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 35, height: 35)
                                                        
                                                        Text(LocaleText.waitingConfirmation)
                                                            .font(.robotoMedium(size: 10))
                                                            .foregroundColor(.DinotisDefault.primary)
                                                    } else if viewModel.isWaitingCreatorConfirmationFailed(
                                                        status: detail.status.orEmpty(),
                                                        isAccepted: detail.meetingRequest?.isAccepted
                                                    ) {
                                                        Image.Dinotis.xmarkIcon
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 35, height: 35)
                                                        
                                                        Text(LocaleText.waitingConfirmation)
                                                            .font(.robotoMedium(size: 10))
                                                            .foregroundColor(.red)
                                                    } else {
                                                        Image.Dinotis.stepCheckmark
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 35, height: 35)
                                                            .opacity(0.2)
                                                        
                                                        Text(LocaleText.waitingConfirmation)
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
                                                        (Image.Dinotis.stepCheckmark)
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 35, height: 35)
                                                        
                                                        Text(LocaleText.setSessionTime)
                                                            .font(.robotoMedium(size: 10))
                                                            .foregroundColor(.DinotisDefault.primary)
                                                    } else if viewModel.isScheduleConfirmationFailed(
                                                        status: detail.status.orEmpty(),
                                                        isConfirmed: detail.meetingRequest?.isConfirmed
                                                    ) {
                                                        Image.Dinotis.xmarkIcon
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 35, height: 35)
                                                        
                                                        Text(LocaleText.setSessionTime)
                                                            .font(.robotoMedium(size: 10))
                                                            .foregroundColor(.red)
                                                    } else {
                                                        (Image.Dinotis.stepCheckmark)
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 35, height: 35)
                                                            .opacity(0.2)
                                                        
                                                        Text(LocaleText.setSessionTime)
                                                            .font(.robotoMedium(size: 10))
                                                            .foregroundColor(Color(.systemGray4))
                                                    }
                                                    
                                                }
                                                .multilineTextAlignment(.center)
                                                .frame(width: 100)
                                                
                                                VStack(spacing: 6) {
                                                    
                                                    Image.Dinotis.stepCheckmark
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 35, height: 35)
                                                        .opacity(
                                                            viewModel.isScheduleStartedDone(status: detail.status.orEmpty()) ? 1 : 0.2
                                                        )
                                                    
                                                    Text(LocaleText.detailScheduleStepThree)
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
                                                    Image.Dinotis.stepCheckmark
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 35, height: 35)
                                                        .opacity(viewModel.isScheduleEndedDone(status: detail.status.orEmpty()) ? 1 : 0.2)
                                                    
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
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(.white)
                            .shadow(color: .dinotisShadow.opacity(0.08), radius: 10, x: 0, y: 0)
                    )
                    .padding([.top, .horizontal])
                }
                
                if !(viewModel.dataMeeting?.meetingRequest?.isConfirmed ?? false) {
                    HStack {
                        Image.Dinotis.noticeIcon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 23, height: 23)
                        
                        Text(LocaleText.setSessionTimeCaption)
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
                    .padding(.top)
                    .padding(.horizontal)
                }
                
                if viewModel.isShowingChatButton() {
                    Button {
                        guard let data = viewModel.dataMeeting else { return }
                        viewModel.routeToScheduleNegotiationChat(meet: viewModel.convertToUserMeet(meet: data))
                    } label: {
                        HStack {
                            Image.Dinotis.messageIcon
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                            
                            Text(LocaleText.discussWithAudience)
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
            }
        }
    }
}
