//
//  TalentProfileDetailView.swift
//  DinotisApp
//
//  Created by Gus Adi on 25/08/21.
//

import SwiftUI
import SlideOverCard
import CurrencyFormatter
import SDWebImageSwiftUI
import SwiftUINavigation
import Lottie

struct TalentProfileDetailView: View {
    
    @State var username: String?
    
    @ObservedObject var viewModel: TalentProfileDetailViewModel
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var stateObservable = StateObservable.shared
    @ObservedObject var bookingPayVM = BookingPayViewModel.shared
    
    @Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
    
    var viewController: UIViewController? {
        self.viewControllerHolder.value
    }
    
    @State var meetings = UserMeeting(
        id: "",
        title: "",
        meetingDescription: "",
        price: "",
        startAt: "",
        endAt: "",
        isPrivate: false,
        slots: 0, userID: "",
        startedAt: nil,
        endedAt: nil,
        createdAt: "",
        updatedAt: "",
        deletedAt: nil,
        bookings: [],
        user: User(
            id: nil,
            name: nil,
            username: nil,
            email: nil,
            profilePhoto: nil,
            isVerified: nil
        )
    )
    
    @State var payments = UserBookingPayment(
        id: "",
        amount: "",
        bookingID: "",
        paymentMethodID: 0,
        externalId: nil,
        redirectUrl: nil,
        qrCodeUrl: nil
    )
    
    @State var check = false
    
    var body: some View {
        
        GeometryReader { geo in
            ZStack(alignment: .center) {
                Color.secondaryBackground.edgesIgnoringSafeArea(.all)
                    .alert(isPresented: $viewModel.isRefreshFailed) {
                        Alert(
                            title: Text(LocaleText.attention),
                            message: Text(LocaleText.sessionExpireText),
                            dismissButton: .default(Text(LocaleText.returnText), action: {
                                viewModel.backToRoot()
                                stateObservable.userType = 0
                                stateObservable.isVerified = ""
                                stateObservable.refreshToken = ""
                                stateObservable.accessToken = ""
                            })
                        )
                    }
                
                VStack(spacing: 0) {
                    
                    HeaderView(viewModel: viewModel)
                        .padding(.top, 5)
                        .padding(.bottom)
                        .background(Color.clear)
                    
                    List {
                        if !viewModel.profileBannerContent.isEmpty {
                            ProfileBannerView(content: $viewModel.profileBannerContent, geo: geo)
                                .background(Color.secondaryBackground)
//                                .listStyle(.plain)
                        } else {
                            SingleProfileImageBanner(
                                profilePhoto: $viewModel.talentPhoto,
                                name: $viewModel.talentName,
                                width: geo.size.width-40,
                                height: geo.size.width-40
                            )
                            .padding(.top, -10)
                            .padding(.bottom, -30)
                            .listRowBackground(Color.clear)
                        }
                        
                        Section {
                            ScheduleTalent(viewModel: viewModel)
                                .padding(.top, 10)
                                .background(Color.secondaryBackground)
                        } header: {
                            CardProfile(viewModel: viewModel)
                                .padding(.top, -10)
                                .padding(.bottom, -12)
                        }
                    }
                    .padding(.horizontal, -20)
                    .listStyle(.plain)
                    .listRowInsets(EdgeInsets(top: -15, leading: 20, bottom: 0, trailing: 20))
                    .introspectTableView { view in
                        view.separatorStyle = .none
                        view.indicatorStyle = .white
                        view.sectionHeaderHeight = -10
                    }
                    NavigationLink(
                        unwrapping: $viewModel.route,
                        case: /HomeRouting.paymentMethod,
                        destination: {viewModel in
                            PaymentMethodView(viewModel: viewModel.wrappedValue)
                        },
                        onNavigate: {_ in},
                        label: {
                            EmptyView()
                        }
                    )
                    .alert(isPresented: $bookingPayVM.isSuccessFree) {
                        Alert(
                            title: Text(NSLocalizedString("success", comment: "")),
                            message: Text(NSLocalizedString("free_payment_success", comment: "")),
                            dismissButton: .default(Text("OK"), action: {
                                viewModel.backToHome()
                            }))
                    }
                    NavigationLink(
                        unwrapping: $viewModel.route,
                        case: /HomeRouting.userScheduleDetail,
                        destination: { viewModel in
                            UserScheduleDetail(
                                bookingId: $viewModel.bookingId,
                                viewModel: viewModel.wrappedValue
                            )
                        },
                        onNavigate: {_ in},
                        label: {
                            EmptyView()
                        }
                    )
                }
                .alert(isPresented: $bookingPayVM.isError) {
                    Alert(
                        title: Text(NSLocalizedString("attention", comment: "")),
                        message: Text(bookingPayVM.error?.errorDescription ?? ""),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .valueChanged(value: viewModel.freeTrans, onChange: { value in
                    if value {
                        viewModel.backToHome()
                    }
                })
                .slideOverCard(isPresented: $viewModel.isPresent, options: [.hideExitButton]) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            ProfileImageContainer(profilePhoto: .constant(viewModel.talentData?.profilePhoto), name: .constant(viewModel.talentData?.name), width: 40, height: 40)

                            Text(viewModel.talentData?.name ?? "")
                                .font(Font.custom(FontManager.Montserrat.bold, size: 14))
                                .minimumScaleFactor(0.01)
                                .lineLimit(1)

                            if viewModel.talentData?.isVerified ?? false {
                                Image("ic-verif-acc")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 16)
                            }

                            Spacer()

                        }
                        .padding(.bottom, 10)

                        Text(viewModel.title)
                            .font(Font.custom(FontManager.Montserrat.bold, size: 14))
                            .foregroundColor(.black)

                        Text(viewModel.desc)
                            .font(Font.custom(FontManager.Montserrat.regular, size: 12))
                            .foregroundColor(.black)
                            .padding(.bottom, 10)

                        HStack(spacing: 10) {
                            Image("ic-calendar")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 18)

                            Text(viewModel.date)
                                .font(Font.custom(FontManager.Montserrat.regular, size: 12))
                                .foregroundColor(.black)
                        }

                        HStack(spacing: 10) {
                            Image("ic-clock")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 18)

                            Text("\(viewModel.timeStart) - \(viewModel.timeEnd)")
                                .font(Font.custom(FontManager.Montserrat.regular, size: 12))
                                .foregroundColor(.black)
                        }

                        VStack(alignment: .leading, spacing: 20) {
                            HStack(spacing: 10) {
                                Image("ic-people-circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 18)

                                Text("\(viewModel.countPart)/\(viewModel.totalPart) \(NSLocalizedString("participant", comment: ""))")
                                    .font(Font.custom(FontManager.Montserrat.regular, size: 12))
                                    .foregroundColor(.black)

                                if viewModel.totalPart > 1 && !(meetings.isLiveStreaming ?? false) {
                                    Text(NSLocalizedString("group", comment: ""))
                                        .font(Font.custom(FontManager.Montserrat.regular, size: 12))
                                        .foregroundColor(.black)
                                        .padding(.vertical, 5)
                                        .padding(.horizontal)
                                        .background(Color("btn-color-1"))
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .stroke(Color("btn-stroke-1"), lineWidth: 1.0)
                                        )
                                } else if meetings.isLiveStreaming ?? false {
                                    Text(LocaleText.liveStreamText)
                                        .font(Font.custom(FontManager.Montserrat.regular, size: 12))
                                        .foregroundColor(.black)
                                        .padding(.vertical, 5)
                                        .padding(.horizontal)
                                        .background(Color("btn-color-1"))
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .stroke(Color("btn-stroke-1"), lineWidth: 1.0)
                                        )
                                } else {
                                    Text(NSLocalizedString("private", comment: ""))
                                        .font(Font.custom(FontManager.Montserrat.regular, size: 12))
                                        .foregroundColor(.black)
                                        .padding(.vertical, 5)
                                        .padding(.horizontal)
                                        .background(Color("btn-color-1"))
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .stroke(Color("btn-stroke-1"), lineWidth: 1.0)
                                        )
                                }
                            }

                            Capsule()
                                .frame(height: 1)
                                .foregroundColor(.gray)
                                .opacity(0.2)
                        }

                        VStack(spacing: 15) {
                            HStack {
                                Text(NSLocalizedString("total_cost", comment: ""))
                                    .font(Font.custom(FontManager.Montserrat.regular, size: 12))
                                    .foregroundColor(.black)

                                Spacer()

                                if let intPrice = viewModel.price.toCurrency() {
                                    Text(intPrice)
                                        .font(Font.custom(FontManager.Montserrat.semibold, size: 16))
                                        .foregroundColor(.black)
                                }
                            }

                            HStack {
                                Text(NSLocalizedString("complete_payment_before", comment: ""))
                                    .font(Font.custom(FontManager.Montserrat.regular, size: 12))
                                    .foregroundColor(.black)

                                Spacer()

                                Text("\(Date().addingTimeInterval(1800).toString(format: .HHmm))")
                                    .font(Font.custom(FontManager.Montserrat.semibold, size: 12))
                                    .foregroundColor(.black)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .background(Color("btn-color-1"))
                            .cornerRadius(4)

                            HStack {
                                Button(action: {
                                    viewModel.isPresent.toggle()
                                }, label: {
                                    HStack {
                                        Spacer()
                                        Text(NSLocalizedString("cancel", comment: ""))
                                            .font(Font.custom(FontManager.Montserrat.semibold, size: 12))
                                            .foregroundColor(.black)
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color("btn-color-1"))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color("btn-stroke-1"), lineWidth: 1.0)
                                    )
                                })

                                Spacer()

                                Button(action: {
                                    if viewModel.price == "0" {
                                        bookingPayVM.bookingPay(by: BookingPay(paymentMethod: 99, meetingId: viewModel.meetingId))
                                    } else {
                                        viewModel.routeToPaymentMethod(price: viewModel.price, meetingId: viewModel.meetingId)
                                    }
                                }, label: {
                                    HStack {
                                        Spacer()
                                        Text(NSLocalizedString("pay", comment: ""))
                                            .font(Font.custom(FontManager.Montserrat.semibold, size: 12))
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color("btn-stroke-1"))
                                    .cornerRadius(8)
                                })
                            }
                            .padding(.top)
                        }
                    }
                }

                LoadingView(isAnimating: $bookingPayVM.isLoading)
                    .isHidden(bookingPayVM.isLoading ? false : true, remove: bookingPayVM.isLoading ? false : true)
            }
            .onAppear(perform: {
                viewModel.onScreenAppear(geo: geo, username: username.orEmpty())
                UITableViewCell.appearance().backgroundColor = UIColor(named: "secondaryBackground")
                UITableViewHeaderFooterView.appearance().backgroundView = UIView()
            })
            .onDisappear(perform: {
                viewModel.talentName = ""
                viewModel.talentPhoto = ""
                viewModel.isPresent = false
                viewModel.profileBannerContent.removeAll()
            })
            .valueChanged(value: viewModel.success, onChange: { value in
                if value {
                    viewModel.talentName = viewModel.talentData?.name
                    viewModel.talentPhoto = viewModel.talentData?.profilePhoto
                    viewModel.profileBannerContent = viewModel.profileBannerContent
                }
            })
            .navigationBarTitle(Text(""))
            .navigationBarHidden(true)
            
            LoadingView(isAnimating: $viewModel.isLoading)
                .isHidden(!viewModel.isLoading, remove: !viewModel.isLoading)
        }
    }
    
    //    private func refreshList() {
    //        withAnimation(.spring()) {
    //            viewModel.onScreenAppear(geo: geo, username: username.orEmpty())
    //        }
    //    }
}

struct TalentProfileDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TalentProfileDetailView(username: "ramramzzz", viewModel: TalentProfileDetailViewModel(backToRoot: {}, backToHome: {}))
//        TalentProfileDetailView(username: "dinotisteam", viewModel: TalentProfileDetailViewModel(backToRoot: {}, backToHome: {}))
    }
}
